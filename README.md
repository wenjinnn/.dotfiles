# Personal NixOS config with Flake and Home Manager
![screenshot](./screenshot.png)

The old Arch config at [Arch branch](https://github.com/wenjinnn/config/tree/arch).

# Why switch to NixOS?

For a lone time I'm seeking for a solution to manage my OS config, The Arch branch is a way that I manage my home config, but that's not enough, NixOS provided capability to manage system wide config, or even more, with Flake I can manage configuration of multiple system.

repo's structure base on [nix-starter-config#standard](https://github.com/Misterio77/nix-starter-configs/tree/main/standard)

# Stuff here

* Editor: a well [configured nvim](https://github.com/wenjinnn/config/tree/nixos/xdg/config/nvim) (tested startup time are less than 30ms) that follows the [KISS principle](https://en.wikipedia.org/wiki/KISS_principle)
* Compositor: [Hyprland](https://github.com/hyprwm/Hyprland)  
* Shell: [ags](https://github.com/Aylur/ags)  
* Terminal emulator: [foot](https://codeberg.org/dnkl/foot)  
* Wallpaper: [swww](https://github.com/LGFae/swww) and two small script, [swww-switch](https://github.com/wenjinnn/config/blob/nixos/pkgs/swww-switch/swww-switch.sh) for pick a random Wallpaper to switch, and [bingwallpaper-get](https://github.com/wenjinnn/config/blob/nixos/pkgs/bingwallpaper-get/bingwallpaper-get.sh) for download daliy bingwallpaper, set [timer](https://github.com/wenjinnn/config/blob/1d08b37c56696a953e1c40c0ea9307acf0c1539d/modules/home-manager/hyprland.nix#L69-L115) via systemd timer.

The [ags config](https://github.com/wenjinnn/config/tree/nixos/xdg/config/ags) base on [Aylur/dotfiles](https://github.com/Aylur/dotfiles), with these different:

* add hibernate button for powermenu, need to setup swap to make it work.  
* use [hyprlock](https://github.com/hyprwm/hyprlock) instead of lockscreen.js (more security, see this [issue](https://github.com/Aylur/dotfiles/issues/72))  
* add a clipboard menu depends on [cliphist](https://github.com/sentriz/cliphist), to trigger it, type `:cp` when launcher active
* ocr for screenshot powered by [tesseract](https://github.com/tesseract-ocr/tesseract)
* some bug fix for chinese font and [more](https://github.com/Aylur/dotfiles/issues/122)
* remove favorite list on launcher, instead with whole applications list.
* add scroll bar for all launcher.

# Must have

Almost as same as [Aylur/dotfiles](https://github.com/Aylur/dotfiles) (except asusctl) with these additional pkg:

* cliphist  
* tesseract
* jq

# Installation

For NixOS users:

replace [hardware-configuration.nix](https://github.com/wenjinnn/config/blob/nixos/nixos/hosts/nixos/hardware-configuration.nix) with your own, and change the [username](https://github.com/wenjinnn/config/blob/1d08b37c56696a953e1c40c0ea9307acf0c1539d/flake.nix#L63) variable, you may also need remove this [line](https://github.com/wenjinnn/config/blob/3c58b72f83b4a4e421ef0fc72a808e2ce31ca68b/flake.nix#L94) from nixos hardware or replace it with your hardware model. then execute in local repo path:
```
$ sudo nixos-rebuild switch --flake .#nixos
$ home-manager switch --flake .#wenjin@nixos
```

Also you may need to unset some [substituters](https://github.com/wenjinnn/config/blob/1d08b37c56696a953e1c40c0ea9307acf0c1539d/nixos/configuration.nix#L96) if download speed to slow.

For other distributions, things under [xdg](https://github.com/wenjinnn/config/tree/main/xdg) could directly put on [xdg base dir](https://wiki.archlinux.org/title/XDG_Base_Directory) (e.g. you should put the file under `xdg/config` to $XDG_CONFIG_HOME).
