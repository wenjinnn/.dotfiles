#!/bin/bash

# Wallpaper source: "bing" (default) or "nasa"
WALLPAPER_SOURCE="${WALLPAPER_SOURCE:-bing}"
# NASA API key (get yours at https://api.nasa.gov/ ; DEMO_KEY works but has low rate limits)
NASA_API_KEY="${NASA_API_KEY:-DEMO_KEY}"

wallpaper_dir="$HOME/Pictures/BingWallpaper/"
datestr=$(date '+%Y%m%d')

fetch_bing() {
    local bing_url='https://www.bing.com'
    local bing_img_url="${bing_url}/HPImageArchive.aspx"
    local bing_img_params='format=js&idx=0&n=8&mbl=1&mkt=zh-HK'
    local bing_img_headers='Accept: application/json'
    local resolution='UHD'
    local file_type='.jpg'

    local target_file="${wallpaper_dir}${datestr}*${resolution}${file_type}"
    # shellcheck disable=SC2086
    if [[ -f ${target_file} ]]; then
        echo "Today wallpaper ${target_file} exist, abort"
        return 0
    fi

    echo "starting query ${datestr} bing wallpaper"
    local response
    response=$(wget -qO- "${bing_img_url}?${bing_img_params}" --header="${bing_img_headers}")
    if [[ $? -ne 0 ]]; then
        echo "Bing request failed with status code: $?"
        return 1
    fi

    local images latest startdate urlbase img_url file_prefix file_name
    images=$(echo "${response}" | jq -r '.images')
    if [[ -f "${images}" ]]; then
        echo "get image failed"
        return 1
    fi
    latest=$(echo "${images}" | jq -r '.[0]')
    startdate=$(echo "${latest}" | jq -r '.startdate')
    urlbase=$(echo "${latest}" | jq -r '.urlbase')
    img_url="${bing_url}${urlbase}_${resolution}${file_type}"
    file_prefix=$(echo "${img_url}" | sed 's/^.*[\\\/]//;s/th?id=OHR.//')
    file_name="${wallpaper_dir}${startdate}-${file_prefix}"

    if [[ -f ${file_name} ]]; then
        echo "${file_name} wallpaper exist, abort"
        return 0
    fi

    echo "Bing wallpaper prepare download from ${img_url} to ${file_name}"
    mkdir -p "${wallpaper_dir}"
    wget -O "${file_name}" "${img_url}" -q --read-timeout=10
    if [[ $? -ne 0 ]]; then
        echo "Download error with status code: $?"
        rm -f "${file_name}"
        return 1
    fi
    echo 'Download success'
    wallpaper-switch
}

fetch_nasa() {
    local nasa_api='https://api.nasa.gov/planetary/apod'
    local today
    today=$(date '+%Y-%m-%d')

    local target_file="${wallpaper_dir}${datestr}-NASA*"
    # shellcheck disable=SC2086
    if [[ -f ${target_file} ]]; then
        echo "Today wallpaper ${target_file} exist, abort"
        return 0
    fi

    echo "starting query ${datestr} NASA APOD wallpaper"
    local response
    response=$(wget -qO- "${nasa_api}?api_key=${NASA_API_KEY}&date=${today}")
    if [[ $? -ne 0 ]]; then
        echo "NASA request failed with status code: $?"
        return 1
    fi

    local media_type title img_url ext file_name
    media_type=$(echo "${response}" | jq -r '.media_type')
    if [[ "${media_type}" != "image" ]]; then
        echo "NASA APOD today is not an image (type: ${media_type}), skipping"
        return 1
    fi

    title=$(echo "${response}" | jq -r '.title' | sed 's/[^a-zA-Z0-9 _-]//g;s/ /-/g')
    img_url=$(echo "${response}" | jq -r '.hdurl // .url')
    ext="${img_url##*.}"
    ext="${ext%%\?*}"
    [[ "${ext}" =~ ^(jpg|jpeg|png|gif|webp)$ ]] || ext="jpg"
    file_name="${wallpaper_dir}${datestr}-NASA-${title}.${ext}"

    if [[ -f "${file_name}" ]]; then
        echo "${file_name} wallpaper exist, abort"
        return 0
    fi

    echo "NASA APOD prepare download from ${img_url} to ${file_name}"
    mkdir -p "${wallpaper_dir}"
    wget -O "${file_name}" "${img_url}" -q --read-timeout=10
    if [[ $? -ne 0 ]]; then
        echo "Download error with status code: $?"
        rm -f "${file_name}"
        return 1
    fi
    echo 'Download success'
    wallpaper-switch
}

case "${WALLPAPER_SOURCE}" in
    nasa) fetch_nasa ;;
    *)    fetch_bing ;;
esac
