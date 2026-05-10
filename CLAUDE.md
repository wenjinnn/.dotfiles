# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal NixOS dotfiles repository managing system and user configurations across multiple hosts (laptop, WSL, AWS, Aliyun, Raspberry Pi 5, nix-on-droid) using Nix flakes and home-manager. Based on [nix-starter-configs/standard](https://github.com/Misterio77/nix-starter-configs/tree/main/standard).

The repo must live at `$HOME/.dotfiles` — some home-manager modules reference this absolute path.

## Build Commands

```sh
# Build both system and home configuration (uses $HOSTNAME and $USER automatically)
make

# Build only NixOS system configuration
make system

# Build only home-manager configuration
make home

# Override host/user
make host=nixos user=wenjin

# Format nix files
nix fmt

# Evaluate a flake output
nix eval .#nixosConfigurations.nixos.config.system.build.toplevel
```

For direct nix commands:
```sh
sudo nixos-rebuild switch --flake .#<hostname>
home-manager switch --flake .#<user>@<hostname> -b backup
```

## Architecture

### Entrypoint: `flake.nix`

Defines all inputs (nixpkgs, home-manager, sops-nix, niri, disko, nixos-raspberrypi, etc.), custom overlays, and exports:
- `nixosConfigurations` — one per host (nixos, nixos-wsl, aws, aliyun, rpi5)
- `homeConfigurations` — per user@host (wenjin@nixos, wenjin@nixos-wsl)
- `nixOnDroidConfigurations` — Android device config
- `overlays`, `nixosModules`, `homeManagerModules` — reusable exports

The `me` attrset in flake.nix holds shared user identity (username, email) passed via `specialArgs` to all configurations.

### Directory Structure

- **`nixos/`** — NixOS system configurations
  - `configuration.nix` — shared base system config (nix settings, pipewire, openssh, etc.)
  - `users.nix` — user account definitions
  - `hosts/<hostname>/` — per-host configs (hardware, host-specific services). Each host's `default.nix` imports `configuration.nix` and adds host-specific modules.

- **`home-manager/`** — home-manager user configurations
  - `home.nix` — shared home config (packages, programs, session variables, overlays)
  - `hosts/<hostname>.nix` — per-host home overrides (e.g., nixos.nix adds desktop-specific modules like niri, ghostty, de)

- **`modules/nixos/`** — reusable NixOS modules (~30 modules: docker, mihomo, tailscale, k3s, ollama, niri, headscale, etc.)
- **`modules/home-manager/`** — reusable home-manager modules (~35 modules: neovim, zsh, git, ghostty, mpd, mail, llm, etc.)

- **`pkgs/`** — custom Nix packages (fhs, bingwallpaper-get, wallpaper-switch, rofi-screenshot-wayland)
- **`overlays/default.nix`** — package additions (imports `pkgs/`) and modifications (nautilus, rss2email, vscode extensions, wireshark)
- **`xdg/config/`** — XDG config files (notably `nvim/` for Neovim config, symlinked via `mkOutOfStoreSymlink` for fast iteration)
- **`secrets.yaml`** — sops-encrypted secrets (age keys defined in `.sops.yaml`)

### Key Patterns

- **`specialArgs`**: The `me` object and `inputs`/`outputs` are passed through `specialArgs` to all module configurations.
- **Module imports**: Both `nixos/configuration.nix` and `home-manager/home.nix` import from `outputs.nixosModules` and `outputs.homeManagerModules` respectively. Per-host files add host-specific modules on top.
- **Neovim config**: Uses `mkOutOfStoreSymlink` to symlink `xdg/config/nvim` into the Nix store — this avoids rebuilds on every config change. The Neovim config is also available standalone at [wenvim](https://github.com/wenjinnn/wenvim).
- **Secrets**: Managed via sops-nix with age keys. Each host has its own key. The `.sops.yaml` file defines which keys can decrypt `secrets.yaml`.

## Important Notes

- This repo uses **sops-nix** for secrets — it will not build without the age keys. Remove sops-dependent modules if adapting for your own use.
- The `result` symlink in the repo root is a Nix build artifact and is gitignored.
- Formatter is `nixfmt` (run via `nix fmt`).
- Nix channels are disabled — everything goes through flakes.
- Garbage collection runs weekly, deleting generations older than 7 days.
