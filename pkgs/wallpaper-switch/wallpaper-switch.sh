#!/bin/bash
wallpaperpath=$HOME/Pictures/BingWallpaper

if [[ -n "$1" && "random" == "$1" ]]; then
    next=$(find "$wallpaperpath" -maxdepth 1 -type f -not -path '*/.*' | shuf -n 1)
elif  [[ -n "$1" && "-f" == "$1" && -n "$2" ]]; then
    next="$2"
else
    next=$(find "$wallpaperpath" -maxdepth 1 -type f -not -path '*/.*' -printf '%T+\t%p\n' | sort -k 1 -r | head -1 | awk '{print $NF}')
fi
echo "next wallpaper: $next"
echo "current desktop environment: $XDG_CURRENT_DESKTOP"
dms ipc call wallpaper set "$next"
ln -sf "$next" "${XDG_DATA_HOME:-$HOME/.local/share}/.wallpaper"
