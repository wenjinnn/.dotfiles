# Nix in WSL

WSL-specific differences when running a Nix/NixOS environment inside WSL. Load when the host is WSL.

## Environment facts

- **systemd**: recent WSL runs systemd and supports WSLg. Services declared in the NixOS-WSL config should work, but verify they actually started (`systemctl status <svc>`) — not all units survive WSL's quirks
- **/mnt/c is slow**: Windows drives are slow for build-heavy work. Put repos, build outputs, and Nix store data on the Linux filesystem, never under `/mnt/c`
- **Windows interop**: Windows executables sit on PATH via interop (`/mnt/c/...`, `wsl.exe`, `powershell.exe`). Nix tools and Windows tools coexist — but never assume a Windows tool is Nix-managed, and never "install" something with a Windows installer when the Nix mechanism exists
- **GUI**: WSLg forwards Wayland/X11, so GUI apps from `home.packages` generally work; clipboard behavior differs from the desktop
- **Windows-side config is not Nix**: `wsl.conf` / `.wslconfig` live on the Windows side and are NOT declared in the flake. Document changes there separately

## When Nix-first still applies

- Installing tools inside WSL still goes through the flake (same decision tree as the main skill) — do not fall back to `sudo apt` because "it's WSL"
- Services that must survive a WSL restart have to be Nix-declared (systemd units); anything started by hand dies with the distro

## Done when

- You can state what is Nix-declared vs Windows-side, and where the build boundary (Linux FS vs /mnt/c) is
