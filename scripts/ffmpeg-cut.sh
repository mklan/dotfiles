#!/usr/bin/env bash
# Usage: ffmpeg-cut.sh [--copy|--hw] [from] [to] [output]
#   from      start time, e.g. 01:03:00
#   to        end time,   e.g. 01:10:00
#   output    output file name (defaults to <input>.cut.mp4)
# Options:
#   --copy    fast, lossless cut via stream copy (default is re-encode)
#   --hw      use VAAPI hardware encode (fast, runs on GPU)
# Missing arguments are prompted interactively.
#
# Default mode: frame-accurate cut + encode to H.265/HEVC in MP4
#   - H.265: state-of-the-art codec, decodable on phones/TVs/devices
#   - hvc1 tag: required so Apple devices (iPhone/iPad/Safari) play it
#   - yuv420p 8-bit: maximum device compatibility
#   - AAC-LC audio + faststart: universal playback, progressive streaming
set -euo pipefail

mode="convert"
while (($#)); do
    case "$1" in
        --copy|-c) mode="copy"; shift ;;
        --hw|--vaapi) mode="hw"; shift ;;
        --) shift; break ;;
        -*) echo "error: unknown option: $1" >&2; exit 1 ;;
        *) break ;;
    esac
done

from="${1:-}"
to="${2:-}"
output="${3:-}"

read -rp "Input file: " input

if [[ -z "$from" ]]; then
    read -rp "Start time (e.g. 01:03:00): " from || { echo "aborted" >&2; exit 1; }
fi
if [[ -z "$to" ]]; then
    read -rp "End time (e.g. 01:10:00): " to || { echo "aborted" >&2; exit 1; }
fi
if [[ -z "$output" ]]; then
    default="${input%.*}.cut.mp4"
    read -rp "Output file [$default]: " output
    output="${output:-$default}"
fi

[[ -n "$from" && -n "$to" ]] || {
    echo "error: from and to are required" >&2
    exit 1
}
[[ -f "$input" ]] || {
    echo "error: input file not found: $input" >&2
    exit 1
}

case "$mode" in
    copy)
        # Fast lossless cut: copy streams, no re-encode.
        # -ss/-to as input options: demuxer seeks straight to the cut
        # (starts at nearest keyframe before "from").
        ffmpeg -y -ss "$from" -to "$to" -i "$input" \
            -map 0:v:0 -map 0:a:0? -c copy "$output"
        ;;
    hw)
        # Re-encode to H.265 using GPU (VAAPI).
        va_device="$(ls /dev/dri/renderD* 2>/dev/null | head -1 || true)"
        [[ -n "$va_device" ]] || {
            echo "error: no VAAPI render node found (/dev/dri/renderD*)" >&2
            exit 1
        }
        ffmpeg -y -ss "$from" -to "$to" -vaapi_device "$va_device" -i "$input" \
            -map 0:v:0 -map 0:a:0? \
            -vf "format=nv12,hwupload" \
            -c:v hevc_vaapi -qp 23 -tag:v hvc1 \
            -c:a aac -b:a 192k \
            -movflags +faststart "$output"
        ;;
    convert)
        # One-pass frame-accurate cut + H.265/HEVC encode.
        # -ss/-to as input options: -to is counted from -ss, so it reads
        # input exactly from "from" to "to" (duration = to - from).
        ffmpeg -y -ss "$from" -to "$to" -i "$input" \
            -map 0:v:0 -map 0:a:0? \
            -c:v libx265 -preset slow -crf 23 -tag:v hvc1 -pix_fmt yuv420p \
            -c:a aac -b:a 192k \
            -movflags +faststart "$output"
        ;;
esac