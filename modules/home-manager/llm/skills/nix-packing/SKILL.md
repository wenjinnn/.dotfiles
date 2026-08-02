---
name: nix-packing
description: Add a package to a Nix flake the reproducible way. Use when the user wants to install a package that is not in nixpkgs, package a pi/npm extension for Nix, provides a pi.dev/packages URL, or asks to write a derivation or update an existing package with new hashes. Covers attribute lookup, derivation writing, dependency lock generation, hash computation, and build verification.
disable-model-invocation: true
---

# Nix Packing

Add any package to a Nix repository — a nixpkgs-existing reference, a pi/npm extension, or a hand-written derivation — through one reproducible loop.

## When to Use

- User provides a `pi.dev/packages/<name>` or `npmjs.org/package/<name>` URL
- User asks to "add", "package", or "打包" a package/extension for Nix
- A tool needed in the flake is not in nixpkgs (or the attribute name is unknown)
- Updating an existing package: new version, hash mismatch, or new dependencies

## Prerequisites

- Working directory: a flake repository root (contains `flake.nix`; pi packages live under `pkgs/pi-packages/`)
- Nix with flakes enabled
- npm (only for npm-dependency packages, to generate lock files)

## Procedure

### Step 1: Locate the package

- nixpkgs already has it (`nix search nixpkgs <term>`, or `nix eval nixpkgs#<attr>.name` succeeds) → **stop**: reference the existing attribute in `home.packages` / `environment.systemPackages` / an overlay. No packaging needed
- Otherwise, classify the source:
  - npm extension (pi plugin, etc.) → Step 2 with the npm flow
  - GitHub or other tarball source → Step 2 with the `fetchFromGitHub` flow

### Step 2: Write the definition

**npm extension:**

1. Get metadata:

   ```bash
   curl -s "https://registry.npmjs.org/<scope>/<name>/latest" | jq '{name, version, dependencies, peerDependencies}'
   ```

2. Decision: no real `dependencies` (only `peerDependencies` or none) → simple extraction (`npmDepsHash = ""`); has `dependencies` → `buildNpmPackage` with a real `npmDepsHash`
3. Get the tarball hash:

   ```bash
   HASH=$(nix-prefetch-url --unpack "https://registry.npmjs.org/<scope>/<name>/-/<name>-<version>.tgz")
   nix hash to-sri --type sha256 "$HASH"
   ```

**fetchFromGitHub:**

```nix
pkgs.fetchFromGitHub {
  owner = "...";
  repo = "...";
  rev = "<commit>";
  hash = "<sri-hash>"; # via: nix-prefetch-url --unpack <tarball-url>
}
```

### Step 3: Lock dependencies (npm packages only)

1. Extract the tarball to a scratch dir and run `npm install --package-lock-only`
2. **Clean the lock file** — remove private/unpublished deps. Pi-internal `@earendil-works/*` packages are not on npm, and `prefetch-npm-deps` fails on them without integrity:

   ```bash
   jq '.packages |= with_entries(select(.key == "" or (.key | test("node_modules/@earendil-works") | not)))' \
     package-lock.json > package-lock-cleaned.json
   ```

3. Copy it to the repo's lock dir (e.g. `pkgs/pi-packages/locks/<name>-<version>.json`, per repo convention)
4. Discover `npmDepsHash`: build with a placeholder hash and read the `got:` value from the error

### Step 4: Single-package build

- `nix build .#<pkg-attr>` (e.g. `nix build .#piPackages."<scope>/<name>"`) — NOT a full system rebuild
- Hash mismatch → update with the `got:` value and rebuild; never disable the sandbox or relax fixed-output downloads
- Verify the output: `ls result/`, and `ls result/node_modules/` when it has dependencies

### Step 5: Wire into the declaration source

- Add the package entry to the repo's package set (`pkgs/pi-packages/default.nix` for pi packages; overlays for custom packages)
- Add it to the repo's update checker if one exists (`scripts/check-updates.sh` PACKAGE_SOURCES)
- Back up runtime data owned by the package BEFORE switching (see `secrets.md` in nix-first: runtime data never goes into the store)

### Step 6: Update loop

- New version: bump `version`, re-fetch `hash`, regenerate the lock, rebuild
- Flake input bumps go through `nix flake update <input>` — never edit `flake.lock` by hand
- Lock changes go in a separate commit from code changes

## Pitfalls

- **Hash mismatch**: always use the `got:` value from the error — the `nix-prefetch-url` hash can differ from the build hash
- **`lib.fakeHash`** (all-A hash) means "no dependencies" to some helpers — never use it for packages with real dependencies
- **Untracked lock files**: flakes ignore untracked files — `git add` the lock file before building
- Never disable the sandbox or relax pinned downloads to fix a hash

## Verification

- `nix build .#<pkg>` succeeds from a clean checkout
- The update checker (if any) lists the new package
- `git log -1` shows the commit with the right message
