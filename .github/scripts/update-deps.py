#!/usr/bin/env python3
"""Weekly updater for fetchFromGitHub blocks across the repo.

Tracks every pinned GitHub dependency:
  * commit-pinned skill repos in modules/home-manager/llm/default.nix
  * commit-pinned repos in modules/home-manager/de.nix
  * tag-pinned npm packages (pkgs/pi-acp/package.nix) whose `rev` is
    derived from `version` (e.g. rev = "v${version}").

For each entry it compares the pinned rev against the latest upstream rev
(commit mode: default-branch HEAD; tag mode: latest release tag), prefetches
the new source hash with nix-prefetch-github and rewrites the nix file.
For tag-mode npm packages it additionally recomputes `npmDepsHash` from the
new package-lock.json with prefetch-npm-deps, so the resulting PR stays
buildable. If that step fails the package's update is rolled back.

Runs from the repo root. Intended for CI (GitHub Actions) but also runnable
locally with --dry-run.
"""

import json
import os
import re
import subprocess
import sys
import tempfile
import time
import urllib.error
import urllib.request

GH_TOKEN = os.environ.get("GH_TOKEN") or os.environ.get("GITHUB_TOKEN") or ""
GITHUB_OUTPUT = os.environ.get("GITHUB_OUTPUT")
NIX_PREFETCH_GITHUB = os.environ.get("NIX_PREFETCH_GITHUB", "nix-prefetch-github")
PREFETCH_NPM_DEPS = os.environ.get("PREFETCH_NPM_DEPS", "prefetch-npm-deps")
DRY_RUN = "--dry-run" in sys.argv

API = "https://api.github.com/repos/{owner}/{name}"

# (file, owner, name, hash-field-name, mode, tag-prefix)
# mode "commit": track default-branch HEAD; the nix block has a plain `rev`.
# mode "tag":    track latest release tag; the nix block has
#                rev = "<prefix>${version}", so we bump `version` and let the
#                rev line follow automatically.
REPOS = [
    (
        "modules/home-manager/llm/default.nix",
        "anthropics",
        "skills",
        "sha256",
        "commit",
        "",
    ),
    (
        "modules/home-manager/llm/default.nix",
        "anthropics",
        "claude-plugins-official",
        "sha256",
        "commit",
        "",
    ),
    (
        "modules/home-manager/llm/default.nix",
        "JuliusBrussee",
        "caveman",
        "sha256",
        "commit",
        "",
    ),
    (
        "modules/home-manager/llm/default.nix",
        "obra",
        "superpowers",
        "sha256",
        "commit",
        "",
    ),
    (
        "modules/home-manager/llm/default.nix",
        "mattpocock",
        "skills",
        "sha256",
        "commit",
        "",
    ),
    (
        "modules/home-manager/llm/default.nix",
        "DietrichGebert",
        "ponytail",
        "sha256",
        "commit",
        "",
    ),
    (
        "modules/home-manager/de.nix",
        "JackHack96",
        "EasyEffects-Presets",
        "hash",
        "commit",
        "",
    ),
    # pi-acp is tagged (rev = "v${version}"): track the latest release tag
    ("pkgs/pi-acp/package.nix", "svkozak", "pi-acp", "hash", "tag", "v"),
]


# ------------------------------------------------------------------ file io


def read_file(path):
    try:
        with open(path, encoding="utf-8") as f:
            return f.read()
    except OSError as e:
        raise RuntimeError(f"cannot read {path}: {e}") from e


def write_file(path, text):
    try:
        with open(path, "w", encoding="utf-8") as f:
            f.write(text)
    except OSError as e:
        raise RuntimeError(f"cannot write {path}: {e}") from e


# ---------------------------------------------------------------- github api


def gh_get(url, retries=3):
    headers = {
        "Accept": "application/vnd.github+json",
        "User-Agent": "update-deps",
    }
    if GH_TOKEN:
        headers["Authorization"] = f"token {GH_TOKEN}"
    req = urllib.request.Request(url, headers=headers)
    last = None
    for attempt in range(retries):
        try:
            with urllib.request.urlopen(req, timeout=30) as resp:
                return json.load(resp)
        except urllib.error.HTTPError as e:
            if not _retryable_http_error(e, attempt, retries):
                raise e
            last = e
        except (urllib.error.URLError, TimeoutError, OSError) as e:
            if attempt >= retries - 1:
                raise RuntimeError(f"GitHub API request failed for {url}: {e}") from e
            last = e
        time.sleep(10 * (attempt + 1))
    raise RuntimeError(f"GitHub API request failed for {url}: {last}")


def _retryable_http_error(e, attempt, retries):
    """True when a transient HTTP error should be retried."""
    return (
        e.code != 404
        and e.code in (403, 429, 500, 502, 503, 504)
        and attempt < retries - 1
    )


def latest_rev(owner, name, mode, prefix):
    base = API.format(owner=owner, name=name)
    if mode == "tag":
        try:
            rel = gh_get(f"{base}/releases/latest")
            tag = rel.get("tag_name") or ""
        except urllib.error.HTTPError as e:
            if e.code != 404:
                raise
            tag = ""
        if not tag:  # no releases: fall back to the newest tag
            tags = gh_get(f"{base}/tags")
            tag = tags[0]["name"] if tags else ""
        if not tag:
            raise RuntimeError(f"{owner}/{name}: no releases or tags found")
        return tag
    head = gh_get(f"{base}/commits/HEAD")
    sha = head.get("sha") or ""
    if not sha:
        raise RuntimeError(f"{owner}/{name}: no default-branch HEAD found")
    return sha


# ------------------------------------------------------------- nix file parse


def iter_blocks(text):
    """Yield the body of each `fetchFromGitHub { ... };` block."""
    for part in text.split("fetchFromGitHub")[1:]:
        brace = part.find("{")
        if brace == -1:
            continue
        rest = part[brace + 1 :]
        end = rest.find("};")
        if end == -1:
            continue
        yield rest[:end]


def block_fields(block):
    """Extract the block's fields; missing fields become the empty string."""
    out = {}
    for name in ("owner", "repo", "rev", "sha256", "hash"):
        m = re.search(r"\b" + name + r'\s*=\s*"([^"]*)"', block)
        out[name] = m.group(1) if m else ""
    return out


def find_block(text, owner, name):
    for block in iter_blocks(text):
        fields = block_fields(block)
        if fields["owner"] == owner and fields["repo"] == name:
            return block, fields
    raise RuntimeError(f"no fetchFromGitHub block for {owner}/{name}")


def file_field(text, name):
    m = re.search(r"\b" + name + r'\s*=\s*"([^"]*)"', text)
    return m.group(1) if m else None


# ------------------------------------------------------------------- prefetch


def prefetch_src_hash(owner, name, rev):
    last = None
    for attempt in range(3):
        try:
            proc = subprocess.run(
                [NIX_PREFETCH_GITHUB, owner, name, "--rev", rev],
                capture_output=True,
                text=True,
                check=True,
                timeout=600,
            )
            data = json.loads(proc.stdout)
            h = (data.get("hash") or "").strip()
            if h and h != "null":
                return h
            last = RuntimeError(f"empty hash in output: {proc.stdout[:200]!r}")
        except (
            subprocess.CalledProcessError,
            json.JSONDecodeError,
            OSError,
            RuntimeError,
        ) as e:
            last = e
        print(f"  ⚠️  prefetch attempt {attempt + 1}/3 failed: {last}")
        if attempt < 2:
            time.sleep(15 * (attempt + 1))
    raise RuntimeError(f"could not prefetch {owner}/{name}@{rev}: {last}")


def update_npm_deps_hash(path, owner, name, tag):
    """Recompute npmDepsHash from the new tag's package-lock.json."""
    tarball = f"https://github.com/{owner}/{name}/archive/refs/tags/{tag}.tar.gz"
    with tempfile.TemporaryDirectory(prefix="update-deps-") as tmp:
        tgz = os.path.join(tmp, "src.tar.gz")
        urllib.request.urlretrieve(tarball, tgz)
        subprocess.run(
            ["tar", "xzf", tgz, "-C", tmp, "--strip-components=1"], check=True
        )
        lockfile = os.path.join(tmp, "package-lock.json")
        if not os.path.exists(lockfile):
            raise RuntimeError(f"{owner}/{name}@{tag} has no package-lock.json")
        proc = subprocess.run(
            [PREFETCH_NPM_DEPS, lockfile],
            capture_output=True,
            text=True,
            check=True,
            timeout=600,
        )
        npm_hash = proc.stdout.strip().splitlines()[-1] if proc.stdout.strip() else ""
        if not re.fullmatch(r"sha256-[A-Za-z0-9+/=]{44}", npm_hash):
            raise RuntimeError(
                f"unexpected prefetch-npm-deps output: {proc.stdout[:200]!r}"
            )
    text = read_file(path)
    if not re.search(r"\bnpmDepsHash\s*=", text):
        raise RuntimeError(f"{path} has no npmDepsHash field")
    new_text = re.sub(
        r'\bnpmDepsHash\s*=\s*"[^"]*"', f'npmDepsHash = "{npm_hash}"', text, count=1
    )
    write_file(path, new_text)
    return npm_hash


# --------------------------------------------------------------------- main


def set_output(name, value):
    if GITHUB_OUTPUT:
        try:
            with open(GITHUB_OUTPUT, "a", encoding="utf-8") as f:
                f.write(f"{name}={value}\n")
        except OSError as e:
            print(f"⚠️  could not write GITHUB_OUTPUT: {e}")
    print(f"[output] {name}={value}")


def main():
    updated_repos = []
    warnings = []

    for path, owner, name, hash_field, mode, prefix in REPOS:
        print(f"::group::Checking {owner}/{name}")
        try:
            orig = read_file(path)
            block, fields = find_block(orig, owner, name)

            if mode == "tag":
                version = file_field(orig, "version")
                if not version:
                    raise RuntimeError(f"no top-level `version` in {path}")
                expected_rev = f"{prefix}${{version}}"
                if fields["rev"] != expected_rev:
                    raise RuntimeError(
                        f"unexpected rev {fields['rev']!r} in {path} "
                        f"(expected {expected_rev!r})"
                    )
                current = prefix + version
            else:
                current = fields["rev"]
                if not current:
                    raise RuntimeError(f"no rev in {path} for {owner}/{name}")

            hash_val = fields[hash_field]
            if not hash_val:
                raise RuntimeError(f"no {hash_field} in {path} for {owner}/{name}")

            latest = latest_rev(owner, name, mode, prefix)
            if latest == current:
                print(f"  ✅ up to date ({current})")
                print("::endgroup::")
                continue

            print(f"  🔄 {current[:12]}… → {latest[:12]}…")
            if DRY_RUN:
                print("  (dry run — no prefetch, no file writes)")
                print("::endgroup::")
                continue

            new_hash = prefetch_src_hash(owner, name, latest)

            text = orig
            if mode == "tag":
                new_version = (
                    latest[len(prefix) :] if latest.startswith(prefix) else latest
                )
                text = re.sub(
                    r'\bversion\s*=\s*"[^"]*"',
                    f'version = "{new_version}"',
                    text,
                    count=1,
                )
            else:
                block2 = block.replace(f'rev = "{current}"', f'rev = "{latest}"')
                text = text.replace(block, block2, 1)

            # re-locate the block (positions shifted) and swap the hash field
            block, fields = find_block(text, owner, name)
            block2 = block.replace(
                f'{hash_field} = "{hash_val}"', f'{hash_field} = "{new_hash}"'
            )
            text = text.replace(block, block2, 1)

            # tag-pinned npm packages: recompute npmDepsHash so the PR builds;
            # on failure roll back this package's edits entirely
            if mode == "tag" and re.search(r"\bnpmDepsHash\s*=", text):
                try:
                    npm_hash = update_npm_deps_hash(path, owner, name, latest)
                    print(f"  ✅ npmDepsHash updated ({npm_hash[:24]}…)")
                except Exception as e:
                    write_file(path, orig)
                    print(
                        f"  ❌ npmDepsHash recompute failed for {owner}/{name}: {e} — update rolled back"
                    )
                    print("::endgroup::")
                    warnings.append(
                        f"{owner}/{name}: npmDepsHash recompute failed ({e}); update rolled back"
                    )
                    continue

            write_file(path, text)
            updated_repos.append(f"{owner}/{name}")
            print(f"  ✅ updated (rev + {hash_field})")
        except Exception as e:
            print(f"  ❌ ERROR: {e}")
            warnings.append(f"{owner}/{name}: {e}")
        print("::endgroup::")

    updated = len(updated_repos) > 0
    set_output("updated", "true" if updated else "false")
    if updated_repos:
        set_output("repos", " ".join(updated_repos))
    if warnings:
        set_output("warnings", "; ".join(warnings))

    if not updated_repos:
        if warnings:
            print("⚠️  No repos were updated; errors:")
            for w in warnings:
                print(f"   - {w}")
            return 1
        print("All dependencies are up to date.")
        return 0
    if warnings:
        print("Partial success — PR will note these warnings:")
        for w in warnings:
            print(f"   - {w}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
