# FHS & Immutable Store

Rules for the Nix immutable store (no `/usr`, no `/opt`, read-only store paths) when running or packaging tools. Load when a binary or build assumes a conventional filesystem layout.

## What breaks

- Binaries expecting `/usr/bin`, `/usr/lib`, `/lib`, `/opt` (hardcoded paths)
- Self-updating programs that try to write into the store
- Native addons (npm/Node, Python wheels, Go cgo) that dynamically link against system libs
- Programs calling `sudo apt-get` / `pip install` / `npm i -g` at runtime

## How to fix (prefer in this order)

1. `lib.getExe pkgs.<attr>` — get a package's binary path instead of guessing PATH
2. `makeWrapper` / `wrapProgram` — set PATH, env vars, and the dynamic linker for a wrapped binary
3. `autoPatchelfHook` — auto-patch ELF binaries for missing shared libraries (inside a derivation)
4. Declare the needed libraries as dependencies — Nix handles the transitive closure; do **not** set a global `LD_LIBRARY_PATH` to paper over holes
5. Native npm addons — keep the Node package's deps locked (see the `nix-packing` skill)

## Fixed points

- `/bin/sh` → `pkgs.bash` (shebangs like `#!/bin/sh` resolve through the shim)
- `#!/usr/bin/env` shebangs are avoided in derivations — use explicit interpreters

## Done when

- The binary runs from a fresh shell with only declared dependencies; no global `LD_LIBRARY_PATH` hacks
