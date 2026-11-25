#!/bin/sh
set -eu

episode="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
project="$episode/motion"
capture="$(mktemp -d)"
trap 'rm -rf "$capture"' EXIT
output="$episode/late_morning_episode_04_westbound.mp4"
partial="$episode/late_morning_episode_04_westbound.partial.mp4"
"${GODOT:-godot}" --headless --editor --path "$project" --import
"${GODOT:-godot}" --path "$project" --write-movie "$capture/episode.avi" --fixed-fps 24 --resolution 540x960 -- --capture
ffmpeg -hide_banner -loglevel error -y -i "$capture/episode.avi" -i "$project/assets/mix.wav" \
  -map 0:v:0 -map 1:a:0 -vf tpad=stop_mode=clone:stop_duration=1 -t 80 -c:v libx264 -preset fast -crf 19 -pix_fmt yuv420p \
  -c:a aac -b:a 128k -movflags +faststart "$partial"
mv "$partial" "$output"
