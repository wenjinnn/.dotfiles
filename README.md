# Personal NixOS configuration with Flake and Home Manager
# TODO Screenshots update
|  |  |
| :-------------: | :--------------: |
| ![application menu](https://github.com/user-attachments/assets/18995b64-8804-499a-82f1-e504ba316254 "application menu")  | ![clipboard manage](https://github.com/user-attachments/assets/c0107d3e-113c-4d48-8bc7-80e1d2ee788d "clipboard manage") |
| ![logout menu](https://github.com/user-attachments/assets/17183dc5-a355-4f3a-82f8-8fc509527e0c "logout menu") | ![OCR for screenshot](https://github.com/user-attachments/assets/cd305ebc-4a70-42fc-92d8-c078c752e77e "OCR for screenshot")

The old Arch configuration at [Arch branch](https://github.com/wenjinnn/config/tree/arch).

Recently I also replace my [ags](https://github.com/Aylur/ags) with some standalone package, But I think the old ags configurations still valuable
So you can visit it in [ags-v1](https://github.com/wenjinnn/.dotfiles/tree/ags-v1).

I don't want to spend too much time on writing about my desktop environment components,
I do most of my work in the command line and prioritize practicality,
so I want to keep my compositor desktop minimalist.

# Why NixOS?

For a lone time I'm seeking for a solution to manage my OS configurations,
The Arch branch is a way that I manage my home configurations,
but that's not enough, NixOS provided capability to manage system wide configurations, or even more,
now this repo manage my laptop, WSL, and nix-on-droid configurations together (but nix-on-droid configurations are not work well now)

Repo's structure base on [nix-starter-config#standard](https://github.com/Misterio77/nix-starter-configs/tree/main/standard),
is a good point to start with NixOS, but you should be careful to using unstable and stable nixpkgs together,
e.g. if you want to stay at stable nixpkgs branch but using unstable Hyprland, it will broken because of the mesa package version are not equal.

# Stuff here

* Editor: a well [configured nvim](https://github.com/wenjinnn/config/tree/nixos/xdg/config/nvim) (tested startup time are less than 30ms) that follows the [KISS principle](https://en.wikipedia.org/wiki/KISS_principle)

    you can try it and find more detail in my mono nvim configuration repo [wenvim](https://github.com/wenjinnn/wenvim), I'm using home-manager with `mkOutOfStoreSymlink` to symlink my nvim configurations directory, that's maybe not the nix way, but since I modify it very frequently and I store my custom snippets and spell file together with it, I don't want to compile it everytime I modified this, also I can easier to share my code with someone that not using NixOS.
* Compositor: [Hyprland](https://github.com/hyprwm/Hyprland)
* Topbar: [waybar](https://github.com/Alexays/Waybar)
* notification daemon: [dunst](https://github.com/dunst-project/dunst)
* Launcher: [rofi (wayland-fork)](https://github.com/lbonn/rofi) with some script to let it provide the ability to manage various system functions, some of them maintained by myself:
    * [cliphist-rofi-img](https://github.com/sentriz/cliphist/blob/master/contrib/cliphist-rofi-img) for clipboard manage
    * [rofi-power-menu](https://github.com/jluttine/rofi-power-menu)
    * [rofi-systemd](https://github.com/colonelpanic8/rofi-systemd) for control systemd unit
    * [rofi-bluetooth](https://github.com/nickclyde/rofi-bluetooth) with scan ability fixed [PR](https://github.com/nickclyde/rofi-bluetooth/pull/33).
    * [rofi-pass-wayland](https://github.com/Seme4eg/rofi-pass-wayland) as [pass](https://www.passwordstore.org/) frontend.
    * [rofi-pulse-select](https://gitlab.com/DamienCassou/rofi-pulse-select)
    * [rofimoji](https://github.com/fdw/rofimoji) for emoji and unicode selection
    * [rofi-network-manager](https://github.com/meowrch/rofi-network-manager)
* Terminal emulator: [foot](https://codeberg.org/dnkl/foot)
* Wallpaper: [hyprpaper](https://github.com/hyprwm/hyprpaper) and some small script, [wallpaper-switch](https://github.com/wenjinnn/.dotfiles/blob/none-ags/pkgs/wallpaper-switch/wallpaper-switch.sh) , and [bingwallpaper-get](https://github.com/wenjinnn/.dotfiles/blob/none-ags/pkgs/bingwallpaper-get/bingwallpaper-get.sh) for download daily bingwallpaper and switch to it immediately.
* style manage: [stylix](https://github.com/danth/stylix) (this is awesome!)

# Installation

> [!NOTE]
> You can not use this repo directly for I'm using [sops-nix](https://github.com/Mic92/sops-nix) to manage my secrets in some modules, you won't pass the compile, but I still give a short guide to install this to remind you and myself.
> Even you remove all the modules that using sops secrets,
> the other parts still has many custom settings that may not suitable for you machine,
> use it directly maybe damage your system.
> Please always check the code before you use it.

For NixOS users:

* This repo should be placed at `$HOME/.dotfiles` for I'm defined a [immutable value](https://github.com/wenjinnn/.dotfiles/blob/62b9f6d35c7da4e6ef44aa93ce397328f920fd43/home-manager/home.nix#L190) and refer it in some home-manager modules.

* Replace [hardware-configuration.nix](https://github.com/wenjinnn/config/blob/nixos/nixos/hosts/nixos/hardware-configuration.nix) with your own, and change the [username](https://github.com/wenjinnn/config/blob/1d08b37c56696a953e1c40c0ea9307acf0c1539d/flake.nix#L63) variable to yours

* You also need to remove this [hardware setting](https://github.com/wenjinnn/config/blob/3c58b72f83b4a4e421ef0fc72a808e2ce31ca68b/flake.nix#L94) or replace it with your hardware model

* Other modules that using sops secrets should be removed.

* Navigate to repo root then execute following command in repo root:
```
$ sudo nixos-rebuild switch --flake .#nixos
$ home-manager switch --flake .#wenjin@nixos
```

* If your machine's `$HOSTNAME` and `$USER` variables as same as that variables in `nixosConfigurations` and `homeConfigurations`, there's also a Makefile for simplified command:
```
$ make          # build system and home
$ make system   # build system
$ make home     # build home
```
