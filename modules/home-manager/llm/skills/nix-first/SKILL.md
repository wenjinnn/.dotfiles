---
name: nix-first
description: Operate a NixOS/Nix environment the Nix way. Use when the user wants to install or update packages/tools, run system commands or services, modify the flake or coding-agent (pi/omp) config, work inside WSL, or debug a failed rebuild — whenever a capability should be declared in Nix instead of installed ad hoc.
---

# Nix-First

Run Nix environments the Nix way: before any install, command, or service change, answer *who owns this — Nix or the runtime?*

## When to Use

- Installing or updating packages/tools ("装 X", "install X", "update X")
- Running system commands or managing services
- Modifying the flake, home-manager, or coding-agent (pi/omp) configuration
- Working inside WSL on a Nix-managed host
- Debugging a failed `nixos-rebuild` / `home-manager switch` / `nix build`
- Any capability that could be declared in Nix instead of installed ad hoc

## Prerequisites

- Nix with flakes enabled
- A Nix-managed environment: NixOS, Nix-in-WSL, or home-manager on another OS

## Procedure

### Step 1: Identify the environment

- Host type: NixOS desktop / NixOS-WSL / other (home-manager on non-NixOS)
- Agent: pi, omp, or another coding agent — each has its own config dir (`~/.pi`, `~/.omp`) and plugin store; never mix them

**Done when:** you can state the host type, which agent config dir is authoritative, and whether native addons / GUI / GPU are available (see `fhs-store.md` for native-addon implications).

### Step 2: Judge ownership

Classify the request:

| Class | Example | Owner |
| --- | --- | --- |
| System capability | service, port, user, firewall | NixOS module |
| User CLI | a tool used in the shell | `home.packages` |
| Project dependency | deps of a repo being worked on | the project's own lockfile / devShell |
| Ephemeral | one-off tool, scratch command | `nix shell` / `nix run` |

**Done when:** you can name the ownership class. If it is a *project dependency*, stop and follow the project's own workflow — never convert `npm install` / `cargo build` / `uv sync` into system Nix packages.

### Step 3: Find the declaration source

Before editing, locate the single source of truth and check the actual runtime state:

- **Nix-managed** (symlinked into the store, e.g. `mkOutOfStoreSymlink` configs) → edit the flake/repo, rebuild to activate
- **Copy-mode file** (re-synced every rebuild, writable between rebuilds) → edit the declaration; runtime edits are overwritten on next switch
- **Pure runtime state** (sessions DB, agent memory, caches) → NOT declared in Nix; never move it into the store

Verify what is actually loaded today (e.g. installed version vs declared version) — do not assume declaration matches runtime.

**Done when:** you know which file is authoritative (or that it is runtime-only), and you confirmed the runtime state.

### Step 4: Pick the Nix mechanism (decision tree)

- One-off tool → `nix shell nixpkgs#<pkg>` / `nix run nixpkgs#<pkg>`; never install globally for a single use
- Project tooling → `nix develop` / direnv; obey the project's own lockfiles
- User CLI → add to `home.packages`; find the attribute first (`nix search nixpkgs <term>`, or `nix-index` + `nix-locate <binary>` for which package provides a binary)
- System capability → NixOS module or `environment.systemPackages`
- Package not in nixpkgs → see the `nix-packing` skill

**Done when:** the mechanism is chosen and the attribute name is verified to exist (`nix eval nixpkgs#<attr>.name` succeeds or search shows it).

### Step 5: Build and activate

1. Run `nix fmt` if the repo has a formatter (nixfmt)
2. Dry-run before switching: `nixos-rebuild build --flake .#<host>` / `nix build .#<attr>` / `home-manager build --flake .#<user>@<host>`
3. Switch only when the dry run passes: `nixos-rebuild switch` / `home-manager switch`
4. Use fast paths: configs symlinked via `mkOutOfStoreSymlink` (e.g. nvim config) take effect immediately — no rebuild needed
5. Untracked files are invisible to flakes — `git add` before building

**Done when:** the dry run succeeds and the switch completes without error.

### Step 6: Verify in a new process

A switch does not update already-running processes:

- Restart the shell / agent after a home-manager switch; old processes keep the old PATH
- Confirm the tool resolves: `which <tool>`
- For agent config/plugin changes, restart the agent and confirm it loads (skill/plugin visible in its list)

**Done when:** a fresh process resolves the new command or loads the new config.

## Branches

Load these only when the situation matches:

- **WSL host** → read `wsl.md` before Step 1 (systemd-in-WSL, /mnt/c, WSLg, Windows interop)
- **Secrets, tokens, or runtime data** (API keys, sops, agent memory, DBs) → read `secrets.md`
- **FHS / immutable-store assumptions** (native addons, dynamic libs, `/usr/bin` expectations, self-updating binaries) → read `fhs-store.md`

## Reference (inline knowledge)

### Service boundary

Services, ports, users, timers are **declared** in Nix. `systemctl start/restart` and `journalctl` are for checking or temporary recovery only — a reboot or switch reverts them.

### Network layering

When a download fails, diagnose per layer — they have separate networks:

1. Shell/tool network (npm, curl, pip) — proxy vars, DNS
2. Nix daemon network — nix-daemon settings, `networking.proxy`
3. Substituters / binary caches — cache availability, `nix.conf`

Don't change global proxy settings because one layer fails.

### GC and rollback window

- Old generations are garbage-collected automatically (commonly ~7 days). Verify a rollback (`nixos-rebuild --rollback`, boot into the previous generation) **before** old generations are collected
- `nix-collect-garbage` is usually automated — only run manually when disk is critical

### Hash mismatch discipline

Fix by updating inputs/locks (`nix flake update <input>`, re-prefetch the hash) — never by disabling the sandbox or relaxing fixed-output downloads.

## Pitfalls

- Global installs always go through the flake + rebuild — never `sudo apt`, system-wide `pip install`, or `npm i -g` on a Nix-managed machine
- A switch does not change running processes (see Step 6)
- Untracked files are invisible to flakes (see Step 5)
- Don't convert project-local dependency workflows into system Nix packages (see Step 2)

## Verification

- `nix fmt --check` passes (or the repo formatter)
- Dry-run build succeeds before any switch
- A fresh process resolves the new command (`which`) or loads the new config
