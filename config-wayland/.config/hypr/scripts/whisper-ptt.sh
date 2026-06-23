#!/usr/bin/env bash
# Push-to-talk transcription via whisper.cpp
# Usage: whisper-ptt.sh start | stop
#
# bind  = SUPER, V, exec, ~/.config/hypr/scripts/whisper-ptt.sh start
# bindr = SUPER, V, exec, ~/.config/hypr/scripts/whisper-ptt.sh stop

PIDFILE=/tmp/whisper-ptt.pid
AUDIOFILE=/tmp/whisper-ptt.wav
MODEL="${WHISPER_MODEL:-$HOME/.local/share/whisper/ggml-base.bin}"
LANGUAGE="${WHISPER_LANG:-auto}"

case "${1:-}" in
  start)
    # Kill any stale recording session
    if [ -f "$PIDFILE" ]; then
      kill "$(cat "$PIDFILE")" 2>/dev/null
      rm -f "$PIDFILE" "$AUDIOFILE"
    fi

    notify-send -t 2000 -i microphone "Whisper PTT" "🎙 Recording…" 2>/dev/null || true

    # Record mono 16 kHz WAV – whisper.cpp native format.
    # pw-record is available on PipeWire systems; arecord falls back on plain ALSA.
    if command -v pw-record &>/dev/null; then
      pw-record --format=s16 --rate=16000 --channels=1 "$AUDIOFILE" &
    else
      arecord -f S16_LE -r 16000 -c 1 -q "$AUDIOFILE" &
    fi
    echo $! > "$PIDFILE"
    ;;

  stop)
    if [ ! -f "$PIDFILE" ]; then
      exit 0
    fi

    # Stop the recording process
    kill "$(cat "$PIDFILE")" 2>/dev/null
    sleep 0.2
    rm -f "$PIDFILE"

    if [ ! -f "$AUDIOFILE" ] || [ ! -s "$AUDIOFILE" ]; then
      notify-send -t 2000 "Whisper PTT" "No audio captured" 2>/dev/null || true
      exit 0
    fi

    notify-send -t 3000 -i system-search "Whisper PTT" "⏳ Transcribing…" 2>/dev/null || true

    # Transcribe with whisper-cli
    RESULT=$(
      whisper-cli \
        -m "$MODEL" \
        -f "$AUDIOFILE" \
        -l "$LANGUAGE" \
        -nt \
        --no-prints \
        2>/dev/null \
      | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//'
    )

    rm -f "$AUDIOFILE"

    if [ -z "$RESULT" ]; then
      notify-send -t 2000 "Whisper PTT" "Nothing transcribed" 2>/dev/null || true
      exit 0
    fi

    # Copy to clipboard and type into the focused window
    printf '%s' "$RESULT" | wl-copy
    wtype "$RESULT"

    notify-send -t 3000 "Whisper PTT" "✅ $RESULT" 2>/dev/null || true
    ;;

  *)
    echo "Usage: $0 start | stop" >&2
    exit 1
    ;;
esac
