#!/bin/bash

# Rotating wallpaper source: bing, nasa, yande, wallhaven
# Runs every 30min, cycles through sources in order

wallpaper_base="$HOME/Pictures/Wallpaper"
datestr=$(date '+%Y%m%d')
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/wallpaper-get"
state_file="${state_dir}/source-index"
NASA_API_KEY="${NASA_API_KEY:-DEMO_KEY}"

# Source rotation
sources=(bing nasa)
mkdir -p "${state_dir}"
index=$(cat "${state_file}" 2>/dev/null || echo 0)
index=$(( index % ${#sources[@]} ))
source="${sources[$index]}"
echo $(( (index + 1) % ${#sources[@]} )) > "${state_file}"

echo "wallpaper-get: source=${source} (${index + 1}/${#sources[@]})"

wallpaper_dir="${wallpaper_base}/${source}"

# --- Common helpers ---

download() {
    local url="$1" file="$2"
    if [[ -f "${file}" ]]; then
        echo "${file} already exists, skip"
        return 0
    fi
    echo "downloading ${url}"
    mkdir -p "${wallpaper_dir}"
    if ! wget -O "${file}" "${url}" -q --read-timeout=10; then
        echo "download failed"
        rm -f "${file}"
        return 1
    fi
    echo "download success"
    wallpaper-switch -f "${file}"
}

# --- Bing ---

fetch_bing() {
    local resolution='UHD' file_type='.jpg'
    local target="${wallpaper_dir}/${datestr}*${resolution}${file_type}"
    # shellcheck disable=SC2086
    [[ -f ${target} ]] && { echo "bing wallpaper exists"; return 0; }

    local response
    response=$(wget -qO- "https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=8&mbl=1&mkt=zh-HK" --header="Accept: application/json")
    [[ $? -ne 0 ]] && { echo "bing api failed"; return 1; }

    local latest urlbase img_url file_name
    latest=$(echo "${response}" | jq -r '.images[0]')
    urlbase=$(echo "${latest}" | jq -r '.urlbase')
    img_url="https://www.bing.com${urlbase}_${resolution}${file_type}"
    file_name="${wallpaper_dir}/$(echo "${latest}" | jq -r '.startdate')-$(echo "${urlbase}" | sed 's/^.*[\\\/]//;s/th?id=OHR.//')_${resolution}.jpg"

    download "${img_url}" "${file_name}"
}

# --- NASA APOD ---

fetch_nasa() {
    local response start_date
    start_date=$(date -d '30 days ago' '+%Y-%m-%d')
    response=$(wget -qO- "https://api.nasa.gov/planetary/apod?api_key=${NASA_API_KEY}&start_date=${start_date}&end_date=$(date '+%Y-%m-%d')") || {
        echo "nasa api failed"
        return 1
    }

    local item date img_url title ext file_name tmp dimensions width height
    while IFS= read -r item; do
        date=$(echo "${item}" | jq -r '.date')
        img_url=$(echo "${item}" | jq -r '.hdurl // empty')
        [[ -z "${img_url}" ]] && continue

        title=$(echo "${item}" | jq -r '.title' | sed 's/[^a-zA-Z0-9 _-]//g;s/ /-/g')
        ext="${img_url##*.}"; ext="${ext%%\?*}"
        [[ "${ext}" =~ ^(jpg|jpeg|png|gif|webp)$ ]] || ext="jpg"
        file_name="${wallpaper_dir}/${date}-NASA-${title}.${ext}"
        [[ -f "${file_name}" ]] && continue

        mkdir -p "${wallpaper_dir}"
        tmp=$(mktemp "${wallpaper_dir}/.nasa.XXXXXX")
        if ! wget -O "${tmp}" "${img_url}" -q --read-timeout=10; then
            rm -f "${tmp}"
            continue
        fi
        dimensions=$(identify -format '%w %h' "${tmp}" 2>/dev/null) || dimensions=""
        read -r width height <<< "${dimensions}"
        if [[ "${width:-0}" -lt 1920 || "${height:-0}" -lt 1080 ]]; then
            echo "nasa image too small (${width:-0}x${height:-0}), skipping ${date}"
            rm -f "${tmp}"
            continue
        fi

        mv "${tmp}" "${file_name}"
        wallpaper-switch -f "${file_name}"
        return 0
    done < <(echo "${response}" | jq -c 'reverse[] | select(.media_type == "image")')

    echo "nasa no new image at least 1920x1080 in the last 30 days"
    return 1
}

# --- Yande.re (4K anime) ---

fetch_yande() {
    local target="${wallpaper_dir}/${datestr}-*"
    # shellcheck disable=SC2086
    [[ -f ${target} ]] && { echo "yande wallpaper exists"; return 0; }

    local response
    response=$(wget -qO- "https://yande.re/post.json?tags=width:3840+height:2160+rating:safe&limit=50")
    [[ $? -ne 0 ]] && { echo "yande api failed"; return 1; }

    local count
    count=$(echo "${response}" | jq 'length')
    [[ "${count}" -eq 0 ]] && { echo "yande no 4K wallpapers"; return 1; }

    local idx img_url tags ext file_name
    idx=$(( $(date '+%-j') % count ))
    img_url=$(echo "${response}" | jq -r ".[${idx}].file_url")
    tags=$(echo "${response}" | jq -r ".[${idx}].tags" | sed 's/[^a-zA-Z0-9 _-]//g;s/ /-/g' | head -c 60)
    ext="${img_url##*.}"; ext="${ext%%\?*}"
    [[ "${ext}" =~ ^(jpg|jpeg|png|gif|webp)$ ]] || ext="jpg"
    file_name="${wallpaper_dir}/${datestr}-${tags}.${ext}"
    download "${img_url}" "${file_name}"
}

# --- Wallhaven (4K anime daily top) ---

fetch_wallhaven() {
    local target="${wallpaper_dir}/${datestr}-*"
    # shellcheck disable=SC2086
    [[ -f ${target} ]] && { echo "wallhaven wallpaper exists"; return 0; }

    local response
    response=$(wget -qO- "https://wallhaven.cc/api/v1/search?categories=010&purity=100&sorting=toplist&topRange=1d&atleast=3840x2160")
    [[ $? -ne 0 ]] && { echo "wallhaven api failed"; return 1; }

    local img_url id ext file_name
    img_url=$(echo "${response}" | jq -r '.data[0].path // empty')
    [[ -z "${img_url}" ]] && { echo "wallhaven no anime wallpaper today"; return 1; }
    id=$(echo "${response}" | jq -r '.data[0].id')
    ext="${img_url##*.}"; ext="${ext%%\?*}"
    [[ "${ext}" =~ ^(jpg|jpeg|png|gif|webp)$ ]] || ext="jpg"
    file_name="${wallpaper_dir}/${datestr}-${id}.${ext}"

    download "${img_url}" "${file_name}"
}

# --- Dispatch ---

case "${source}" in
    bing)      fetch_bing ;;
    nasa)      fetch_nasa ;;
    yande)     fetch_yande ;;
    wallhaven) fetch_wallhaven ;;
esac
