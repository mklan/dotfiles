while true; do
  pos=$(hyprctl cursorpos | awk '{print $2, $4}' | tr -d ',')
  x=${pos% *}; y=${pos#* }
  if (( x < 10 && y < 10 )); then
    notify-send "Cursor in top-left corner!"
  fi
  sleep 0.1
done
