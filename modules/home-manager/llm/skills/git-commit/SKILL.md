---
name: git-commit
description: Write git commits in the current repo's commit voice — sample ~10 recent commits by the user and ~10 by other authors, absorb the repo's style and human language, split the changeset into logical commits, and write detailed messages matching the repo's format. Commits only: never push, always hand off for manual review and push.
disable-model-invocation: true
---

# Git Commit

Take over commit writing: re-derive the repo's *voice* from live history, chunk the
changeset into logical commits, and write detailed messages a maintainer would accept.

## When to Use

- User asks to commit / stage / write a message: "commit", "提交", "git commit", "commit this", "整理提交"
- Work is finished and the tree holds changes that need committing
- User asks why the split is what it is, or wants the messages reviewed

## Prerequisites

- A git repository with staged, unstaged, or untracked changes (`git status` shows anything)
- `git config user.name` / `user.email` resolve (they identify "my" commits)

## Procedure

### Step 1: Absorb the repo's commit voice

The author census picks the sampling mode — team or solo:

```bash
git shortlog -sne HEAD | head -20   # who commits here — one author, or a team?
```

**Team mode** (2+ distinct committers): the ~10-by-others sample is the primary voice — match
the *team's* style and language, not your own. Your own sample is secondary (your personal
drift is not the house style); the path-local sample counts as team voice too.

```bash
git log -10 --format='%h|%s' --author="$(git config user.name)"   # mine (secondary)
git log -40 --format='%h|%ae|%s' | grep -v "$(git config user.email)" | head -10   # others (primary)
git log -5 --format='%h|%s' -- <paths-you-are-changing>   # voice is path-local — sample here too
```

**Solo mode** (one author): the voice belongs to the repo, not an author split — widen the
window to the last 30–50 commits and lean on the path-local samples.

Either way, read the actual subjects (and any bodies: `git log -5 --format='%h%n%n%b'`),
extract the **voice profile** (template in Reference), and check AGENTS.md / CLAUDE.md /
CONTRIBUTING.md / commitlint / PR templates for written commit rules — they **override** the
profile when they conflict.

**Team-workflow branch**: find how commits reach the main branch — direct pushes, or
feature-branch + PR (squash or rebase on merge)? If PR-based, work on a feature branch
(`git switch -c <topic>`), keep commits local and review-sized, and hand the branch off for
the PR — never commit to a shared branch or rewrite pushed history. If the team squashes on
merge, the PR description carries the detail; if it rebases, your individual commits are the
history — write for whichever the team keeps.

**No-format branch**: if history has no consistent `type(scope):` pattern (gitmoji, plain
imperative, mixed), mirror the dominant pattern; a genuinely mixed or empty history defaults
to `type(scope): subject`, and you say so to the user.

**Done when:** you can state the profile's type vocabulary, scope vocabulary, subject grammar,
language, and body style — each illustrated by a quoted real commit — and you know whether
the repo is team or solo, and how commits reach main.

### Step 2: Map the changeset

```bash
git status --short
git diff --stat && git diff                 # unstaged — read the diffs, not just names
git diff --cached --stat && git diff --cached
git ls-files --others --exclude-standard    # untracked files that belong to the change
```

**Done when:** you can name every changed file (staged, unstaged, untracked) and say what
each change does, from the diff content.

### Step 3: Chunk into logical commits

Apply the chunking rules in Reference. One commit = one scope + one intent, at the repo's
observed granularity. **Present the plan (chunk → files → message) before executing when the
changeset has 3+ chunks or touches secret files**; otherwise proceed straight through.

**Done when:** every changed file sits in exactly one chunk; each chunk has one scope and one
intent; chunks are ordered so each is reviewable alone.

### Step 4: Write the messages

- **Subject** — `type(scope): subject` in the profile's exact voice: observed type, observed
  scope, profile's case/mood/punctuation, ≤72 chars when the repo observes that limit.
- **Body** — every non-trivial chunk gets one: a short *why* paragraph, then `-` bullets of
  what changed, in the profile's body style. Explain the decision and impact, never recap the
  diff line by line. Trivial changes (typo, one-line toggle) keep a bare subject — that is
  the profile's own majority pattern.
- **Language** — the profile's human language (this skill's home repo writes English, often
  with loose grammar that is itself part of the voice; match it, don't "fix" it). In a team
  repo the team's dominant language wins even when it differs from the user's.

**Done when:** every chunk has a subject in the observed format with an observed type and
scope; every non-trivial chunk has a why-body; the language matches the history.

### Step 5: Stage, commit, verify

For each chunk in order:

```bash
git add <paths>          # or git add -p when one file mixes two intents
git diff --cached --check   # whitespace gate before committing
git commit -F - <<'EOF'
<subject>

<body>
EOF
```

The skill's contract: **commit only, never push.** Pushing is the user's manual step — in a
solo repo and in a team repo alike (in a team repo that means the user pushes the feature
branch and opens the PR). Run the repo's formatter (e.g. `nix fmt`) before committing Nix
changes so formatting noise doesn't pollute the diff.

**Hand off — the deliverable is a review, not a push.** After the last chunk, present the
result for manual review and push:

- `git log --oneline -<n>` — the commits you created, in order
- `git status --short` — what's left (should be only intentionally-untouched files)
- per commit, `git show --stat <sha>` — subject, body, and the files it contains
- close by stating plainly: the commits are ready for the user's review; **pushing is theirs**

**Done when:** every chunk is committed with its message; the tree holds only
intentionally-left files; the union of committed files equals the original changeset; the
new commits pass `git log --oneline -<n>` inspection; and the commits have been handed to
the user with the commit list and per-commit file sets — with no push performed.

## Reference

### Voice profile template

| Field | What to extract |
| --- | --- |
| Type vocabulary | which of feat/fix/chore/refactor/docs/perf/... appear, relative frequency |
| Scope vocabulary | which scopes, and which paths each maps to |
| Subject grammar | mood (imperative vs descriptive), case, trailing punctuation, length range |
| Language | English / Chinese / mixed; domain jargon |
| Body style | how often bodies appear; structure (why-paragraph + bullets?); what they explain |
| Special forms | Revert / merge lines, breaking-change markers, trailers |

### Chunking rules

- A chunk is one scope + one intent, small enough to review in one sitting.
- Group by path first (files under one module dir usually share a scope), then split by
  intent within a path-group when a file genuinely mixes changes.
- Match the repo's granularity, not your taste: repos that commit tiny units (this one does —
  separate commits for a keybind, a tray toggle, a theming enable) get small chunks; repos
  that batch big rewrites get big ones.
- Order dependencies first: a rename before its consumers, a lockfile bump with its feature.
- Every changed file lands in exactly one chunk — nothing dropped. Untracked files that are
  part of the change belong to a chunk (flake builds need them `git add`ed).
- Secret edits (sops-encrypted files like `secrets.yaml`, already tracked in this repo) form
  their own chunk when the secret change is the point of the commit; otherwise leave them
  uncommitted for the user. Never stage plaintext keys or tokens in any commit.

### Worked example — this repo (dotfiles)

A Step-1 profile for `~/.dotfiles` (solo, as of 2026-08 — re-derive it live; this only
calibrates the shape of a profile, and it shows the solo case; team repos follow the
team-mode sampling in Step 1):

- Types: feat, fix, chore (dominant), refactor; `Revert "..."` lines appear verbatim
- Scopes: nix (`nixos/`, `modules/nixos/`), neovim/nvim (`xdg/config/nvim/`), llm
  (`modules/home-manager/llm/`, pi/omp config), plus niri, hyprland, ags, mihomo, mail, ...
- Subject: `type(scope): subject`, lowercase, descriptive noun phrase, no trailing period,
  ~30–70 chars
- Language: English, terse, sometimes loose grammar ("cursor to big in xwayland application")
- Body: rare; when present a short why-paragraph + `-` bullets
  (see `feat(nix): guard dangerous bash commands with pi-permission-system`)
- Special: sops-encrypted `secrets.yaml` edits ride inside feature commits

A mixed changeset touching `modules/home-manager/niri.nix`, `modules/home-manager/llm/default.nix`
and a new `pkgs/foo/` dir chunks into three commits: `fix(nix): ...`, `feat(llm): ...`,
`feat(nix): add foo package` — never one commit spanning niri + llm + a new package.

## Pitfalls

- Re-derive the voice on every run — history drifts, and writing from memory of "how this
  repo commits" produces messages that no longer match.
- In a team repo the others-sample is the house style — match it even when your own commits
  have drifted, and never "fix" the team's grammar or language.
- Write bodies from the diff's *why* — a file-by-file recap duplicates the diff and says
  nothing.
- Keep the subject in the profile's grammar even when your own taste differs — the goal is a
  history a maintainer recognizes as this repo's.
- Match the repo's granularity even when you'd split or batch differently.
- In a PR-based team repo, keep commits on a feature branch, review-sized, and never commit
  to or rewrite shared branches.
- Never push — under any circumstances, in any repo mode; pushing is always the user's
  manual step, and the final hand-off states that explicitly.
- Show the plan before executing anything with 3+ chunks or secrets.

## Verification

- `git log --oneline -<n>` reads like the repo's own history — spot-check that every subject
  matches the profile's format (observed type, observed scope, case, length).
- `git status --short` shows only intentionally-left changes.
- The union of files in the new commits equals the original changeset (staged + unstaged +
  untracked), no file in two commits.
- `git diff --check` passes on every commit.
- No plaintext secret material in any new commit's diff.
- No `git push` was run — the commits were handed off for the user's manual review and push.
