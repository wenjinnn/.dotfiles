#!/bin/bash
wallpaperpath=$HOME/Pictures/BingWallpaper

if [[ -n "$1" && "random" == "$1" ]]; then
    next=$(find "$wallpaperpath" -maxdepth 1 -type f -not -path '*/.*' | shuf -n 1)
else
    next=$(find "$wallpaperpath" -maxdepth 1 -type f -not -path '*/.*' -printf '%T+\t%p\n' | sort -k 1 -r | head -1 | awk '{print $NF}')
fi
echo "next wallpaper: $next"
hyprctl hyprpaper preload "$next"
# sleep here is because hyprctl sometimes throws errors if the interval between the two commands we send is too short.
sleep 1
hyprctl hyprpaper wallpaper ",$next"
sleep 1
hyprctl hyprpaper unload all
