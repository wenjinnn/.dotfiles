---
name: init-pi-agentsmd
description: Generate a pi-flavored AGENTS.md for the current project — the pi equivalent of Claude Code's /init. Scans repo structure, build/test/lint commands and conventions, then appends a Pi Agent Notes section describing this machine's pi capabilities (web access, subagents, memory, context-mode KB, pi-lens diagnostics, goal/loop tracking, permission guardrails, telegram, nixos MCP). Use when the user asks to init/initialize a project for AI agents, generate an AGENTS.md, or says "/init".
disable-model-invocation: true
---

# Init Pi AGENTS.md

Scaffold an `AGENTS.md` for the current repository, tuned for the pi coding
agent running on this machine. Unlike a generic `/init` (which only extracts
build commands), this one also documents the pi capabilities available in the
environment, so future pi sessions know what they can reach for.

## When to Use

- User asks to "init this project" / "generate AGENTS.md" / "add agent context" / "/init"
- A freshly cloned repo needs agent context for pi sessions
- Existing AGENTS.md is stale and the user wants it refreshed

## Prerequisites

- Working directory: the repository root (or run from anywhere inside the repo — resolve with `git rev-parse --show-toplevel`)
- Existing AGENTS.md (if any) must be merged, not blindly replaced

## Procedure

### Step 1: Locate the project root

```bash
git rev-parse --show-toplevel  # fall back to cwd if not a git repo
```

### Step 2: Inventory the repo

List top-level entries and look for:

- **Manifests / build files**: `README*`, `package.json` (+ lockfile), `pyproject.toml`, `Cargo.toml`, `go.mod`, `flake.nix`, `Makefile`, `justfile`, `Taskfile`, `docker-compose*`
- **CI**: `.github/workflows/`, `.gitlab-ci.yml`, `azure-pipelines.yml` — the real build/test/lint commands live here
- **Config / style**: `.editorconfig`, `.prettierrc*`, `.eslintrc*`, `ruff.toml`, `clang-format`, `biome.json`
- **Conventions**: `CONTRIBUTING.md`, commitlint / `.gitmessage`, CHANGELOG policy, branch/PR rules from CI checks
- **Security-relevant**: secret handling (sops, `.env`, vault), destructive commands (migrations), pre-commit hooks

### Step 3: Extract commands from real configs — never invent

- `package.json` scripts → `npm run build|test|lint`
- Makefile / justfile targets → read the actual target list
- CI workflow steps → the exact commands the project runs in production
- README quickstart → dev/run commands

If a command cannot be found anywhere, write `unknown — ask the user` rather than guessing.

### Step 4: Detect conventions

- Code style from formatter/linter configs (spaces vs tabs, trailing commas, max line length, naming)
- Commit style: conventional commits? (check commitlint config, `.gitmessage`, or `git log --oneline` history)
- Branch / PR requirements if enforced by CI

### Step 5: Write the AGENTS.md

Match the file language to the project (Chinese README → Chinese AGENTS.md). Structure, ≤60 lines, every line must earn its place:

```markdown
# <Project> — Agent Instructions

<one-line description of what this repo is>

## Commands
- build: ...
- test:  ...
- lint:  ...
- dev:   ...
- <any repo-specific helper (format, check, deploy)>

## Project Structure
- <key-dir>: <what lives there>        # only the 3-8 dirs that matter

## Conventions
- Style: <formatter rules, naming>
- Commits: <conventional commits? how to word messages>
- <PR/branch rules only if CI enforces them>

## Security & Gotchas
- <secrets handling; commands that must NOT run locally>
- <destructive commands; anything requiring sudo>

## Pi Agent Notes
<insert the Pi Environment block from "Step 5b" below, verbatim>
```

### Step 5b: Append the Pi Environment block

This is what makes it "pi-flavored" — copy the following block into the
`## Pi Agent Notes` section, trimmed to the capabilities that matter for the
project (drop irrelevant lines, keep the section tight):

```markdown
This repository is edited with **pi** (AI coding assistant). This machine's pi
ships with these capabilities:

- **Web access**: `web_search` / `source_check` / `fetch_content` — external research, docs, source verification
- **Subagents**: pi-subagents — parallel / chain / async delegation with isolated worktrees
- **Memory**: pi-hermes-memory — `memory` / `memory_search` for cross-session facts; project conventions go to the `project` target
- **Context knowledge base**: context-mode — `ctx_index` / `ctx_search` to index docs, `ctx_execute` to process large outputs without polluting context
- **Code intelligence**: pi-lens — `lsp_diagnostics` / `lens_diagnostics` (LSP + tree-sitter/ast-grep rules), ast-grep structural search, review graph (`project_report` / `module_report`); run diagnostics before declaring work done
- **Goals & loops**: pi-goal-list-loop-audit — `/goal` / `/list` / `/loop` for multi-step or iterative work
- **Structured questions**: `ask_user_question` when requirements are ambiguous
- **Task tracking**: `todo` for step-by-step progress
- **Permission guardrails**: pi-permission-system — destructive/privileged commands (`rm -rf`, `mkfs`, `git reset --hard`, `sudo`, `git push`) are blocked or require confirmation
- **MCP**: the `nixos` MCP server (`mcp-nixos`) is available for NixOS/Nix operations
- **Token usage**: pi-usage tracks per-session usage

Project-level pi config:
- `.pi/SYSTEM.md` / `.pi/APPEND_SYSTEM.md` — replace / append the system prompt
- `.pi/skills/` — project skills (add `disable-model-invocation: true` to keep them slash-only)
- `.pi/prompts/` — prompt templates (`/name` to expand)
- `.pi/settings.json` — project settings (loaded after trust)

pi auto-loads AGENTS.md / CLAUDE.md from the current directory and all parent
directories. Run `/reload` (or restart pi) after editing this file.
```

### Step 6: Handle an existing AGENTS.md

- Read it first. **Merge** new findings into it — preserve custom instructions.
- Ask the user before wholesale overwriting a large or hand-maintained file.

### Step 7: Finish

- Tell the user the file was written, and that pi needs `/reload` (or restart) to pick it up.
- Note the same AGENTS.md is read by other harnesses (Claude Code, Cursor, Copilot), so one file serves everywhere.

## Pitfalls

- **Never copy the README verbatim** — AGENTS.md is agent context, not documentation. Extract commands and conventions only.
- **Never fabricate commands** — every command must be observed in a config/CI file, or explicitly flagged unknown.
- **No secrets** — no tokens, keys, or machine-specific paths.
- **Keep it ≤60 lines** — this file is injected into every pi session; deep per-task detail belongs in skills, not here.
- **Don't add aspirational process** — commit/branch rules belong only if CI enforces them.
- **Don't clobber** — existing AGENTS.md gets merged, not replaced, unless the user asks for a rewrite.
- **The Pi Agent Notes block is a default, not doctrine** — trim it to what the project actually needs.

## Verification

- `AGENTS.md` exists at the project root.
- Every listed command was observed in a real config/CI file (spot-check two actually run).
- No secrets/tokens in the file (grep for `key|secret|token` patterns).
- File ≤60 lines and every section has content.
- Existing instructions were preserved (if an AGENTS.md already existed).
- `/reload` or a new pi session loads the file (visible in the startup header or `/context`).
