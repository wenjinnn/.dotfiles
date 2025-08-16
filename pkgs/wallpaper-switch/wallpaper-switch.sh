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
PIDS=($(pgrep swaybg)) ; nohup swaybg -i "$next" -m fill > /dev/null 2>&1 &
echo "new swaybg process started with PID: $!"
echo "old swaybg processes: $PIDS"
(
    sleep 1
    for pid in "${PIDS[@]}"; do
        kill $pid
        echo "killed old swaybg process: $pid"
    done
) &
