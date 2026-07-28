#!/bin/bash
wallpaperpath=$HOME/Pictures/Wallpaper

if [[ -n "$1" && "random" == "$1" ]]; then
    next=$(find "$wallpaperpath" -type f \( -name '*.jpg' -o -name '*.png' -o -name '*.webp' \) | shuf -n 1)
elif [[ -n "$1" && "-f" == "$1" && -n "$2" ]]; then
    next="$2"
else
    next=$(find "$wallpaperpath" -type f \( -name '*.jpg' -o -name '*.png' -o -name '*.webp' \) -printf '%T@\t%p\n' | sort -rn | head -1 | cut -f2)
fi
echo "next wallpaper: $next"
echo "current desktop environment: $XDG_CURRENT_DESKTOP"
noctalia msg wallpaper-set "$next"
ln -sf "$next" "${XDG_DATA_HOME:-$HOME/.local/share}/.wallpaper"
