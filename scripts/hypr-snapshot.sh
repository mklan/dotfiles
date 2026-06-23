#!/usr/bin/env bash
# Snapshot Hyprland workspace windows and try to record commands
# Usage: hypr-snapshot.sh <name>
set -euo pipefail
name="$1"
OUTDIR="${XDG_DATA_HOME:-$HOME/.local/share}/hypr-snapshots"
mkdir -p "$OUTDIR"
if ! command -v hyprctl >/dev/null 2>&1; then
  echo "hyprctl is required" >&2; exit 2
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required" >&2; exit 2
fi
# try to get active workspace via activewindow, fallback to monitors
WS=$(hyprctl activewindow -j 2>/dev/null | jq -r '.workspace // empty')
if [ -z "$WS" ]; then
  WS=$(hyprctl -j monitors 2>/dev/null | jq -r '.[] | select(.active==true).activeWorkspace // empty' | head -n1)
fi
if [ -z "$WS" ]; then
  echo "Could not determine active workspace" >&2; exit 3
fi
clients_json=$(hyprctl -j clients)
# select clients for the workspace: workspace may be number or string; match contains
selected=$(echo "$clients_json" | jq --arg ws "$WS" '[.[] | select((.workspace|tostring) == $ws or (.workspace|tostring|test($ws)))]')

# helper: get cmdline for pid and try to find non-terminal child
get_cmd_for_pid(){
  local pid=$1
  local exe=$(readlink -f /proc/$pid/exe 2>/dev/null || true)
  local cmd=$(tr '\0' ' ' < /proc/$pid/cmdline 2>/dev/null | sed -e 's/ $//')
  # if pid points to a terminal emulator, try find a non-shell descendant
  local terminals='alacritty|kitty|wezterm|st|urxvt|xterm|gnome-terminal|konsole|foot'
  if echo "$exe" | grep -Eiq "$terminals"; then
    # breadth-first search for first descendant that is not a shell
    local q="$pid"
    while [ -n "$q" ]; do
      local next=""
      for c in $(pgrep -P $q 2>/dev/null || true); do
        # read cmdline
        local ccmd=$(tr '\0' ' ' < /proc/$c/cmdline 2>/dev/null || true)
        if [ -z "$ccmd" ]; then
          next+="$c "
          continue
        fi
        # ignore shells
        if echo "$ccmd" | grep -Eiq '\b(bash|zsh|sh|fish)\b'; then
          next+="$c "
          continue
        fi
        # found candidate
        echo "$ccmd"
        return
      done
      q="$next"
    done
  fi
  echo "$cmd"
}

now=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
outfile="$OUTDIR/${name:-snapshot}_$now.json"
# build output
jq -n --arg created_at "$now" --arg workspace "$WS" --argjson clients "$selected" '{created_at:$created_at,workspace:$workspace,clients: $clients}' \
  | jq '.clients |= map(. + {pid:(.pid // null)})' \
  > "$outfile.tmp"
# enhance with cmdlines
python3 - <<'PY'
import json,sys,subprocess
fn='''"$outfile.tmp"'''
fn=fn.strip('"')
with open(fn) as f:
    data=json.load(f)
for c in data['clients']:
    pid=c.get('pid')
    if not pid:
        c['cmdline']=None
        c['recovered_cmd']=None
        continue
    try:
        with open(f'/proc/{pid}/cmdline','rb') as g:
            raw=g.read().rstrip(b'\x00')
            cmdline=b' '.join(raw.split(b'\x00')).decode('utf-8',errors='ignore')
    except Exception:
        cmdline=None
    c['cmdline']=cmdline
    # attempt to recover child command if terminal
    recovered=None
    try:
        # use pgrep -P to get children
        out=subprocess.check_output(['pgrep','-P',str(pid)]).decode().strip()
        if out:
            for child in out.split():
                try:
                    with open(f'/proc/{child}/cmdline','rb') as h:
                        crow=h.read().rstrip(b'\x00')
                        ccmd=b' '.join(crow.split(b'\x00')).decode('utf-8',errors='ignore')
                        if ccmd and not any(sh in ccmd for sh in ['bash','zsh','sh','fish']):
                            recovered=ccmd
                            break
                except Exception:
                    pass
    except Exception:
        pass
    c['recovered_cmd']=recovered
with open(fn.replace('.tmp',''), 'w') as out:
    json.dump(data,out,indent=2)
print('Snapshot saved to', fn.replace('.tmp',''))
PY
mv "$OUTDIR/${name:-snapshot}_$now.json" "$outfile" 2>/dev/null || true
mv "$outfile.tmp" "$outfile" 2>/dev/null || true
chmod 600 "$outfile"
echo "$outfile"