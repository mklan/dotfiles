#!/usr/bin/env bash
# Usage: ffmpeg-merge.sh [--convert] FILE1 FILE2 ... OUTPUT
#   Merge videos into one file. The LAST argument is the output file.
#
#   Inputs that already share the same video/audio parameters are merged
#   by stream copy (fast, lossless).
#   If parameters differ (codec, resolution, fps, audio...), each input
#   is re-encoded to a common H.265/AAC format (uniform resolution/fps/
#   audio) and then concatenated. Missing audio tracks are filled with
#   silent audio so stream layout stays consistent.
#
#   --convert   force the re-encode path even if inputs look compatible
set -euo pipefail

force_convert=0
case "${1:-}" in
    --convert) force_convert=1; shift ;;
    -h|--help)
        cat <<'EOF'
Usage: ffmpeg-merge.sh [--convert] FILE1 FILE2 ... OUTPUT

Merges videos into one file. The LAST argument is the output file.

Inputs that already share the same video/audio parameters are merged
by stream copy (fast, lossless).
If parameters differ (codec, resolution, fps, audio...), each input is
re-encoded to a common H.265/AAC format (uniform resolution/fps/audio)
and then concatenated. Missing audio tracks are filled with silent
audio so stream layout stays consistent.

  --convert   force the re-encode path even if inputs look compatible
EOF
        exit 0
        ;;
    -*) echo "error: unknown option: $1" >&2; exit 1 ;;
esac

(( $# >= 3 )) || {
    echo "error: need at least 2 input files and an output file" >&2
    exit 1
}

inputs=("${@:1:$#-1}")
output="${!#}"

for f in "${inputs[@]}"; do
    [[ -f "$f" ]] || { echo "error: input not found: $f" >&2; exit 1; }
    [[ "$f" != "$output" ]] || {
        echo "error: output file must differ from inputs: $output" >&2
        exit 1
    }
done

# --- probe all inputs -------------------------------------------------------
v_info=()   # codec,width,height,pix_fmt,avg_frame_rate per input
a_info=()   # codec,sample_rate,channels per input (or "none")
duration=() # seconds per input
max_w=0; max_h=0; max_fps=0.0

for f in "${inputs[@]}"; do
    vi="$(ffprobe -v error -select_streams v:0 \
          -show_entries stream=codec_name,width,height,pix_fmt,avg_frame_rate \
          -of csv=p=0 "$f")" \
        || { echo "error: cannot read video stream of: $f" >&2; exit 1; }
    [[ -n "$vi" ]] || { echo "error: no video stream in: $f" >&2; exit 1; }
    v_info+=("$vi")

    ai="$(ffprobe -v error -select_streams a:0 \
          -show_entries stream=codec_name,sample_rate,channels \
          -of csv=p=0 "$f" 2>/dev/null || true)"
    a_info+=("${ai:-none}")

    duration+=("$(ffprobe -v error -show_entries format=duration \
                  -of csv=p=0 "$f")")

    w="$(cut -d, -f2 <<<"$vi")"
    h="$(cut -d, -f3 <<<"$vi")"
    fps="$(cut -d, -f5 <<<"$vi")"
    fps_float="$(awk -F/ '{print ($1==0 ? 0 : $1/$2)}' <<<"$fps")"
    [[ -n "$w" && -n "$h" ]] || { echo "error: broken probe for: $f" >&2; exit 1; }

    (( w > max_w )) && max_w=$w
    (( h > max_h )) && max_h=$h
    awk -v a="$fps_float" -v b="$max_fps" 'BEGIN{if (a>b) print a}' \
        | grep -q . && max_fps="$fps_float"
done

# hm: keep even dimensions for H.265 4:2:0
(( max_w % 2 )) && (( max_w-- ))
(( max_h % 2 )) && (( max_h-- ))

# --- decide: compatible (copy) or differing (re-encode) ---------------------
same=true
for i in "${!inputs[@]}"; do
    [[ "${v_info[$i]}" == "${v_info[0]}" && "${a_info[$i]}" == "${a_info[0]}" ]] || same=false
done

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

if $same && (( ! force_convert )); then
    echo "inputs compatible -> stream-copy concat"
    list="$tmpdir/list.txt"
    for f in "${inputs[@]}"; do printf "file '%s'\n" "$(realpath "$f")" >>"$list"; done
    ffmpeg -y -f concat -safe 0 -i "$list" -c copy -movflags +faststart "$output"
else
    if $same; then
        echo "forcing re-encode -> each input to common H.265/AAC ($max_w x $max_h, ${max_fps}fps)"
    else
        echo "inputs differ -> re-encoding each to common H.265/AAC ($max_w x $max_h, ${max_fps}fps)"
    fi
    vf="scale=$max_w:$max_h:force_original_aspect_ratio=decrease,\
pad=$max_w:$max_h:(ow-iw)/2:(oh-ih)/2:color=black,setsar=1,\
fps=$max_fps,format=yuv420p"
    list="$tmpdir/list.txt"
    for i in "${!inputs[@]}"; do
        f="${inputs[$i]}"
        out="$tmpdir/in_$i.mp4"
        echo "  encoding [$((i+1))/${#inputs[@]}]: $f"
        printf "file '%s'\n" "$out" >>"$list"
        common=( -vf "$vf" -c:v libx265 -preset slow -crf 23 -tag:v hvc1
                 -c:a aac -b:a 192k -ar 48000 -ac 2 )
        if [[ "${a_info[$i]}" != "none" ]]; then
            ffmpeg -y -i "$f" -map 0:v:0 -map 0:a:0 \
                "${common[@]}" "$out"
        else
            # no audio track -> add silent stereo so stream layout matches
            ffmpeg -y -i "$f" -f lavfi -i anullsrc=r=48000:cl=stereo \
                -map 0:v:0 -map 1:a:0 -shortest \
                "${common[@]}" "$out"
        fi
    done
    ffmpeg -y -f concat -safe 0 -i "$list" -c copy -movflags +faststart "$output"
fi

total="$(printf '%s\n' "${duration[@]}" | awk '{s+=$1} END {printf "%.1f", s}')"
echo "done: $output (total source duration ~${total}s)"