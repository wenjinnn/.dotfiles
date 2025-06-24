#!/bin/bash

bing_url='https://www.bing.com'
bing_img_url="${bing_url}/HPImageArchive.aspx"
bing_img_params='format=js&idx=0&n=8&mbl=1&mkt=zh-HK'
bing_img_headers='Accept: application/json'
resolution='UHD'
file_type='.jpg'
bing_wallpaper_dir="$HOME/Pictures/BingWallpaper/"

datestr=$(date '+%Y%m%d')
target_file="${bing_wallpaper_dir}${datestr}*${resolution}${file_type}"
if [[ -f "${target_file}" ]]; then
    echo "Today wallpaper ${target_file} exist, abort"
    exit 0
fi

echo "starting query ${datestr} wallpaper"
response=$(wget -qO- "${bing_img_url}?${bing_img_params}" --header="${bing_img_headers}")

if [[ $? -eq 0 ]]; then
    images=$(echo "${response}" | jq -r '.images')
    if [[ -f "${images}" ]]; then
        echo "get image failed"
        exit 1
    fi
    latest=$(echo "${images}" | jq -r '.[0]')
    startdate=$(echo "${latest}" | jq -r '.startdate')
    urlbase=$(echo "${latest}" | jq -r '.urlbase')
    img_url="${bing_url}${urlbase}_${resolution}${file_type}"
    file_prefix=$(echo "${img_url}" | sed 's/^.*[\\\/]//;s/th?id=OHR.//')
    file_name="${bing_wallpaper_dir}${startdate}-${file_prefix}"

    if [[ -f ${file_name} ]]; then
        echo "${file_name} wallpaper exist, abort"
        exit 0
    fi

    echo "Bing wallpaper prepare download from ${img_url} to ${file_name}"
    mkdir -p "${bing_wallpaper_dir}"
    wget -O "${file_name}" "${img_url}" -q --read-timeout=10
    if [ $? -ne 0 ]; then
        echo "Download error with status code: ${?}"
        rm -f "${file_name}"
    else
        echo 'Download success'
        wallpaper-switch
    fi
    exit 0
else
    echo "Request failed with status code: ${?}"
fi
