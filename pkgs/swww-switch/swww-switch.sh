#!/bin/bash
wallpaperpath=$HOME/Pictures/BingWallpaper

if [[ -n "$1" && "random" == "$1" ]]; then
    next=$(find "$wallpaperpath" -maxdepth 1 -type f -not -path '*/.*' | shuf -n 1)
else
    next=$(find "$wallpaperpath" -maxdepth 1 -type f -not -path '*/.*' -printf '%T+\t%p\n' | sort -k 1 -r | head -1 | awk '{print $NF}')
fi
echo "next wallpaper: $next"
# wallpaper switch trigger by ags, no need to trigger by following code
# cursorpos=$(hyprctl cursorpos)
# swww img $next --transition-fps 60 --transition-type random --transition-pos "${cursorpos}"
ln -sf $next $HOME/.config/background
