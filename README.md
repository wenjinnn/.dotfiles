# Personal NixOS configuration with Flake and Home Manager
# Screenshot

![Niri screenshot](https://github.com/wenjinnn/.dotfiles/releases/download/0.1.0/Screenshot.png)

The old Arch configuration can be found in the [Arch branch](https://github.com/wenjinnn/config/tree/arch).

~~I don't want to spend too much time writing about my desktop environment components. I do most of my work in the command line and prioritize practicality, so I want to keep my compositor desktop minimalist.~~

Forget about it. That was just because there wasn't a friendly and awesome shell before. Now we have dms, noctalia-shell, etc.

# Why NixOS?

For a long time, I have been seeking a solution to manage my OS configurations. The Arch branch was one way I managed my home configurations, but it wasn't enough. NixOS provides the capability to manage system-wide configurations and more. Now, this repo manages my laptop, WSL, AWS, Aliyun, Raspberry Pi 5, and nix-on-droid configurations all together (though nix-on-droid configurations do not work well yet).

The repository structure is based on [nix-starter-config#standard](https://github.com/Misterio77/nix-starter-configs/tree/main/standard). it is a good starting point for learning NixOS, but you should be careful when using unstable and stable nixpkgs together. For example, if you want to stay on the stable nixpkgs branch but use an unstable Hyprland, it may break because the Mesa package versions do not match.

# Stuff here

* Editor: A well-configured [Neovim](https://github.com/wenjinnn/config/tree/nixos/xdg/config/nvim) (tested startup time is less than 35ms) that follows the [KISS principle](https://en.wikipedia.org/wiki/KISS_principle).

    You can try it and find more details in my standalone Neovim configuration repo, [wenvim](https://github.com/wenjinnn/wenvim). I use home-manager with `mkOutOfStoreSymlink` to symlink my Neovim configurations directory. This might not be the "pure" Nix way, but since I modify it very frequently and store my custom snippets and spell files with it, I don't want to recompile it every time I make a change. This also makes it easier to share my code with those who are not using NixOS.
* Compositor: [niri](https://github.com/YaLTeR/niri)
* Shell: [noctalia-shell](https://github.com/noctalia-dev/noctalia); configuration can be found in [de.nix](modules/home-manager/de.nix).
* Terminal emulator: [ghostty](https://github.com/ghostty-org/ghostty)
* Wallpaper: [wallpaper-switch](pkgs/wallpaper-switch) and [wallpaper-get](pkgs/wallpaper-get) with noctalia integration.
* Music player: [MPD](https://www.musicpd.org) and [ncmpcpp](https://github.com/ncmpcpp/ncmpcpp)
* Mail client: [neomutt](https://neomutt.org/)

# Installation

> [!NOTE]
> You cannot use this repo directly because I use [sops-nix](https://github.com/Mic92/sops-nix) to manage secrets in some modules, so it will not compile without them. I have included a short guide for installation as a reminder for both you and myself.
>
> Even if you remove all modules that use sops secrets, other parts still contain many custom settings that may not be suitable for your machine. Using it directly may damage your system.
>
> Please always review the code before use.

For NixOS users:

* This repo should be placed at `$HOME/.dotfiles` because I have defined an [absolute path](home-manager/home.nix#L13) and referred to it in some home-manager modules.

* Replace [hardware-configuration.nix](nixos/hosts/nixos/hardware-configuration.nix) with your own, and change the [username](flake.nix#L118) variable to your own.

* Other modules using sops secrets should be removed.

* Navigate to the repo root and execute the following commands:
```sh
$ sudo nixos-rebuild switch --flake .#nixos
$ home-manager switch --flake .#wenjin@nixos
```

* If your machine's `$HOSTNAME` and `$USER` variables are the same as those in `nixosConfigurations` and `homeConfigurations`, you can use the Makefile for simplified commands. You can also override them with `host=` and `user=`:
```sh
$ make                    # build system and home
$ make system             # build system
$ make home               # build home
$ make host=aliyun        # build system for a specific host
$ make user=wenjin home   # build home for a specific user
