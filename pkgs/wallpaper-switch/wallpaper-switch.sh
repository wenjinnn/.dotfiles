#!/bin/bash
wallpaperpath=$HOME/Pictures/BingWallpaper

if [[ -n "$1" && "random" == "$1" ]]; then
    next=$(find "$wallpaperpath" -maxdepth 1 -type f -not -path '*/.*' | shuf -n 1)
else
    next=$(find "$wallpaperpath" -maxdepth 1 -type f -not -path '*/.*' -printf '%T+\t%p\n' | sort -k 1 -r | head -1 | awk '{print $NF}')
fi
echo "next wallpaper: $next"
echo "current desktop environment: $XDG_CURRENT_DESKTOP"
if [ "Hyprland" == "$XDG_CURRENT_DESKTOP" ]; then
    hyprctl hyprpaper reload ,"$next"
    hyprctl hyprpaper unload unused
    # Create symlink for hyprpaper current wallpaper
    ln -sf $next $HOME/.config/background
else
    PIDS=($(pgrep swaybg)) ;swaybg -i "$next" -m fill &
    echo "old swaybg processes: $PIDS"
    sleep 1
    for pid in "${PIDS[@]}"; do
        kill $pid
        echo "killed old swaybg process: $pid"
    done
fi
