# Personal NixOS config with Flake and Home Manager
# Screenshots
|  |  |
| :-------------: | :--------------: |
| ![application menu](https://github.com/user-attachments/assets/18995b64-8804-499a-82f1-e504ba316254 "application menu")  | ![clipboard manage](https://github.com/user-attachments/assets/c0107d3e-113c-4d48-8bc7-80e1d2ee788d "clipboard manage") |
| ![logout menu](https://github.com/user-attachments/assets/17183dc5-a355-4f3a-82f8-8fc509527e0c "logout menu") | ![OCR for screenshot](https://github.com/user-attachments/assets/cd305ebc-4a70-42fc-92d8-c078c752e77e "OCR for screenshot")

The old Arch config at [Arch branch](https://github.com/wenjinnn/config/tree/arch).

# Why switch to NixOS?

For a lone time I'm seeking for a solution to manage my OS config, The Arch branch is a way that I manage my home config, but that's not enough, NixOS provided capability to manage system wide config, or even more, with Flake I can manage configuration of multiple system.

Repo's structure base on [nix-starter-config#standard](https://github.com/Misterio77/nix-starter-configs/tree/main/standard)

# Stuff here

* Editor: a well [configured nvim](https://github.com/wenjinnn/config/tree/nixos/xdg/config/nvim) (tested startup time are less than 30ms) that follows the [KISS principle](https://en.wikipedia.org/wiki/KISS_principle), you can try it with my single nvim configuration repo [wenvim](https://github.com/wenjinnn/wenvim)
* Compositor: [Hyprland](https://github.com/hyprwm/Hyprland)
* Shell: [ags](https://github.com/Aylur/ags)
* Terminal emulator: [foot](https://codeberg.org/dnkl/foot)
* Wallpaper: [hyprpaper](https://github.com/hyprwm/hyprpaper) and some small script, [random choose a pic](https://github.com/wenjinnn/config/blob/4748ecfcd14b1f4c8e780789c4eb40ca1688629e/xdg/config/ags/service/wallpaper.ts#L79) to switch to it, and [fetchBing](https://github.com/wenjinnn/config/blob/4748ecfcd14b1f4c8e780789c4eb40ca1688629e/xdg/config/ags/service/wallpaper.ts#L49-L82) for download daliy bingwallpaper and switch to immediately.

The [ags config](https://github.com/wenjinnn/config/tree/nixos/xdg/config/ags) base on [Aylur/dotfiles](https://github.com/Aylur/dotfiles), with these different:

* Add hibernate button for powermenu, need to setup swap to make it work.
* Use [hyprlock](https://github.com/hyprwm/hyprlock) instead of lockscreen.js (more security, see this [issue](https://github.com/Aylur/dotfiles/issues/72))
* Add a clipboard menu depends on [cliphist](https://github.com/sentriz/cliphist), to trigger it, type `:cp` when launcher active
* Ocr for screenshot powered by [tesseract](https://github.com/tesseract-ocr/tesseract)
* Some bug fix for chinese font and [more](https://github.com/Aylur/dotfiles/issues/122)
* Remove favorite list on launcher, instead with whole applications list.
* Add scroll bar for all launcher.
* Some fix for 4k screen display.

## Known issues

1. The clipboard menu item will be truncated if your cliphist item has new line character,
this mean's that any item after this specific item will be disappear in clipboard menu,
but don't worry, the data still there, you can find that specific item via lookup the `cliphist list` output
and find the specific item id then delete it via `echo "<specific item id>" | cliphist delete`, then restart ags.
This is a known issue that related to ags, it will truncated program output if it encountered a new line character, but I'm not sure whether it's ags problem or GTK api problem currently. I'll fix it by commit some PR to upstream if I got some free time.
2. At this point, the ags config is only compatible with ags v1, I'll move to ags v2 at future.

# Must have

Almost as same as [Aylur/dotfiles](https://github.com/Aylur/dotfiles) (except asusctl) with these additional pkg:

* cliphist
* tesseract
* jq

# Installation

> [!NOTE]
> You can not use this repo directly for I'm using [sops-nix](https://github.com/Mic92/sops-nix) to manage my secrets in some modules, you won't pass the compile.
> Even you remove all the modules that using sops secrets,
> the other parts still has many custom settings that may not suitable for you machine,
> use it directly maybe damage your system.
> Please always check the code before you use it.

For NixOS users:

Replace [hardware-configuration.nix](https://github.com/wenjinnn/config/blob/nixos/nixos/hosts/nixos/hardware-configuration.nix) with your own, and change the [username](https://github.com/wenjinnn/config/blob/1d08b37c56696a953e1c40c0ea9307acf0c1539d/flake.nix#L63) variable,
you may also need remove this [line](https://github.com/wenjinnn/config/blob/3c58b72f83b4a4e421ef0fc72a808e2ce31ca68b/flake.nix#L94) and other module that using sops secrets.
from nixos hardware or replace it with your hardware model. Then execute in local repo path:
```
$ sudo nixos-rebuild switch --flake .#nixos
$ home-manager switch --flake .#wenjin@nixos
```

Also you may need to unset some [substituters](https://github.com/wenjinnn/config/blob/1d08b37c56696a953e1c40c0ea9307acf0c1539d/nixos/configuration.nix#L96) if download speed to slow.

For other distributions, things under [xdg](https://github.com/wenjinnn/config/tree/main/xdg) could directly put on [xdg base dir](https://wiki.archlinux.org/title/XDG_Base_Directory) (e.g. you should put the file under `xdg/config` to $XDG_CONFIG_HOME).
