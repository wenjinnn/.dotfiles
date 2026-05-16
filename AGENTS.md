# Repository Guidelines

## Project Structure & Module Organization

This is a Nix flake-based NixOS + home-manager configuration repo, based on [nix-starter-configs/standard](https://github.com/Misterio77/nix-starter-configs/tree/main/standard).

- **`flake.nix`** — Entrypoint: defines inputs, overlays, and exports `nixosConfigurations`, `homeConfigurations`, and `nixOnDroidConfigurations` per host.
- **`nixos/`** — System-level configs (`configuration.nix` for shared, `hosts/<name>/` for per-host hardware/services).
- **`home-manager/`** — User-level configs (`home.nix` for shared, `hosts/<name>.nix` for per-host overrides).
- **`modules/nixos/`** — Reusable NixOS modules (~30: docker, tailscale, k3s, mihomo, ollama, etc.).
- **`modules/home-manager/`** — Reusable home-manager modules (~35: neovim, zsh, git, ghostty, mpd, etc.).
- **`pkgs/`** — Custom Nix packages (bingwallpaper-get, wallpaper-switch, rofi-screenshot-wayland, fhs).
- **`overlays/default.nix`** — Package additions and modifications.
- **`xdg/config/`** — XDG config files (Neovim config symlinked via `mkOutOfStoreSymlink` for fast iteration).

The repo must live at `$HOME/.dotfiles` — some home-manager modules reference this absolute path.

## Build, Test, and Development Commands

```sh
make          # Build and switch both system + home (auto-detects $HOSTNAME / $USER)
make system   # NixOS system only (sudo nixos-rebuild switch --flake .#<host>)
make home     # home-manager only (home-manager switch --flake .#<user>@<host>)
make host=nixos user=wenjin   # Override auto-detected host/user
nix fmt       # Format all Nix files with nixfmt
```

For direct nix commands:
```sh
sudo nixos-rebuild switch --flake .#<hostname>
home-manager switch --flake .#<user>@<hostname> -b backup
```

## Coding Style & Naming Conventions

- **Formatter**: `nixfmt` — run `nix fmt` before committing.
- **Indentation**: 2 spaces in Nix files.
- **Module naming**: `modules/<nixos|home-manager>/<service-name>.nix` (lowercase, kebab-case where needed).
- **Host configs**: `nixos/hosts/<hostname>/` and `home-manager/hosts/<hostname>.nix`.
- **`specialArgs`**: Pass `me`, `inputs`, and `outputs` via `specialArgs` to all configurations. The `me` attrset in `flake.nix` holds shared user identity.

## Commit & Pull Request Guidelines

- Follow **conventional commits**: `feat(nix):`, `fix:`, `chore(nix):`, `chore(neovim):` with the scope indicating the affected area.
- Keep commits focused — one logical change per commit.
- Update `flake.lock` in a separate commit when bumping inputs.

## Security & Configuration Tips

- **Secrets**: Managed via [sops-nix](https://github.com/Mic92/sops-nix) with age keys in `secrets.yaml`. Each host has its own key defined in `.sops.yaml`. The repo will not build without the age keys.
- **Nix channels**: Disabled — everything goes through flakes.
- **GC**: Garbage collection runs weekly, deleting generations older than 7 days.
- **Warnings**: Never use this repo directly on your machine without reviewing and removing sops-dependent modules first.

## Agent-Specific Instructions

- When adding a new module, place it in `modules/nixos/` or `modules/home-manager/` and import it in the appropriate host or `default.nix`.
- When modifying `flake.nix` inputs, always run `nix flake update <input>` rather than editing `flake.lock` manually.
- The `result` symlink is a Nix build artifact — it's gitignored, do not commit it.
- Neovim config changes in `xdg/config/nvim/` take effect immediately (no rebuild needed) due to `mkOutOfStoreSymlink`.
