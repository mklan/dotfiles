#!/usr/bin/env bash
#
# link-scripts.sh — put the repo's scripts on your $PATH via symlinks
#
# Replaces the old copy-scripts.sh (sudo cp -r into /usr/local/bin):
#   * no sudo  -> links into ~/.local/bin (user-owned, already on your PATH)
#   * no drift -> symlinks instead of copies, so edits take effect immediately
#   * tidy     -> re-running prunes links to scripts that were deleted
#
# Usage: link-scripts.sh [--dry-run] [--remove]
#   -n, --dry-run   show what would be linked, change nothing
#   -r, --remove    unlink everything again
#
# New script? Just drop it into scripts/ and re-run this.

set -euo pipefail

REPO="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${XDG_BIN_HOME:-$HOME/.local/bin}"

# --ignore is matched against the entry name inside the package:
#   README* / *.txt / *.md   docs, not commands
#   session-selector         already linked by hand to its compiled binary
IGNORE=(
	--ignore='^README'
	--ignore='\.txt$'
	--ignore='\.md$'
	--ignore='^session-selector$'
)

ACTION=--restow
SIMULATE=()

usage() {
	sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'
}

for arg in "$@"; do
	case "$arg" in
		-n | --dry-run) SIMULATE=(--simulate --verbose) ;;
		-r | --remove) ACTION=--delete ;;
		-h | --help)
			usage
			exit 0
			;;
		*)
			echo "unknown option: $arg (try --help)" >&2
			exit 1
			;;
	esac
done

mkdir -p "$TARGET"
stow --dir="$REPO" --target="$TARGET" "$ACTION" "${SIMULATE[@]}" "${IGNORE[@]}" scripts

case ":$PATH:" in
	*":$TARGET:"*) ;;
	*) echo "warning: $TARGET is not on your PATH" >&2 ;;
esac

if ((${#SIMULATE[@]})); then
	echo "dry run - nothing was changed"
elif [ "$ACTION" = "--delete" ]; then
	echo "removed the script links from $TARGET"
else
	COUNT=0
	for link in "$TARGET"/*; do
		[ -L "$link" ] || continue
		case "$(readlink -f "$link")" in
			"$REPO/scripts"/*) COUNT=$((COUNT + 1)) ;;
		esac
	done
	echo "$COUNT script(s) linked into $TARGET"
fi
