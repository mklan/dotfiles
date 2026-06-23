hypr-snapshot.sh & hypr-restore.sh

Usage:
  scripts/hypr-snapshot.sh <name>
    - Saves a JSON snapshot of the current active Hyprland workspace to
      ~/.local/share/hypr-snapshots/<name>_TIMESTAMP.json

  scripts/hypr-restore.sh <name|path>
    - Restores by switching to the snapshot's workspace and launching recorded
      commands. Set HYPR_SNAPSHOT_TERMINAL if you prefer a terminal emulator
      (default: alacritty). Note: exact tiling/layout may not be fully
      reconstructed; this opens the applications recorded in the snapshot.

Notes:
 - Requires hyprctl and jq and (for best recovered terminal commands) python3
 - The snapshot attempts to recover commands running inside terminal emulators
   by inspecting child processes; this is heuristic and may not always work.
 - Restoring uses common -e terminal flags for alacritty/kitty/st/urxvt; if
   your terminal uses a different flag, set HYPR_SNAPSHOT_TERMINAL to a
   compatible emulator or edit the restore script.
