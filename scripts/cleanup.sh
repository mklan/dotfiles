#!/usr/bin/env bash
#
# cleanup.sh — reclaim disk space from caches and throwaway data
#
# Steps (nothing here touches personal files):
#   1. pacman package cache      paccache -rk2  (keeps the 2 newest versions)
#   2. yay / AUR build cache     yay -Sc        (also runs pacman -Sc)
#   3. npm cache                 npm cache clean --force
#   4. Chrome on-device AI model OptGuideOnDeviceModel (silently downloaded, ~4G)
#   5. Trash                     empty ~/.local/share/Trash
#   6. systemd journal           journalctl --vacuum-size=200M
#
# Usage: cleanup.sh [--dry-run] [--help]
#   -n, --dry-run   only show what would be removed, change nothing
#
# Note: steps 1, 2 and 6 need sudo (fingerprint/password is asked once).
#       yay -Sc ends with pacman -Sc, which trims the cache down to the
#       currently installed versions - i.e. step 2 is the stricter of the two.

set -uo pipefail

# ---------------------------------------------------------------- options ---
DRY_RUN=0

usage() {
	sed -n '2,18p' "$0" | sed 's/^# \{0,1\}//'
}

for arg in "$@"; do
	case "$arg" in
		-n | --dry-run) DRY_RUN=1 ;;
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

# ----------------------------------------------------------------- output ---
if [ -t 1 ]; then
	BOLD=$'\033[1m' DIM=$'\033[2m' GREEN=$'\033[32m' YELLOW=$'\033[33m'
	RED=$'\033[31m' RESET=$'\033[0m'
else
	BOLD='' DIM='' GREEN='' YELLOW='' RED='' RESET=''
fi

FAILED=0
SKIPPED=0

step() { printf '\n%s==> %s%s\n' "$BOLD" "$1" "$RESET"; }
ok() { printf '  %sok%s  %s\n' "$GREEN" "$RESET" "$1"; }
note() { printf '      %s%s%s\n' "$DIM" "$1" "$RESET"; }
skip() {
	printf '  %sskip%s %s\n' "$DIM" "$RESET" "$1"
	SKIPPED=$((SKIPPED + 1))
}
fail() {
	printf '  %sFAIL%s %s\n' "$RED" "$RESET" "$1"
	FAILED=1
}

# run <description> <command...>
run() {
	local desc=$1
	shift
	if ((DRY_RUN)); then
		printf '  %splan%s %s\n' "$YELLOW" "$RESET" "$desc"
		note "\$ $*"
		return 0
	fi
	if "$@"; then
		ok "$desc"
	else
		fail "$desc"
	fi
}

# show <path> — print the size a cleanup target currently occupies
show() {
	[ -e "$1" ] && du -sh "$1" 2>/dev/null | sed 's/^/      currently: /'
}

# ------------------------------------------------------------------ sizes ---
root_used() { df -B1 --output=used / | tail -1 | tr -d ' '; }
USED_BEFORE=$(root_used)

printf '%sdisk cleanup%s' "$BOLD" "$RESET"
((DRY_RUN)) && printf ' %s(dry run)%s' "$YELLOW" "$RESET"
printf '  —  / is at %s\n' "$(df -h / | awk 'NR==2 {print $5 " used (" $4 " free)"}')"

# ------------------------------------------------------- 1. pacman cache ----
step "1/6  pacman package cache"
if command -v paccache >/dev/null 2>&1; then
	show /var/cache/pacman/pkg
	run "pruned pacman cache (kept 2 newest versions)" sudo paccache -rk2
elif command -v pacman >/dev/null 2>&1; then
	show /var/cache/pacman/pkg
	run "cleaned pacman cache" sudo pacman -Sc
else
	skip "pacman not found"
fi

# ---------------------------------------------------------- 2. yay cache ----
step "2/6  yay / AUR build cache"
if command -v yay >/dev/null 2>&1; then
	show "${XDG_CACHE_HOME:-$HOME/.cache}/yay"
	run "cleaned AUR build cache" yay -Sc
else
	skip "yay not found"
fi

# ----------------------------------------------------------- 3. npm cache ---
step "3/6  npm cache"
if command -v npm >/dev/null 2>&1; then
	show "$(npm config get cache 2>/dev/null)"
	run "cleared npm cache" npm cache clean --force
else
	skip "npm not found"
fi

# --------------------------------------------- 4. Chrome on-device model ----
step "4/6  Chrome on-device AI model"
found=0
for dir in "$HOME"/.config/google-chrome*/OptGuideOnDeviceModel \
	"$HOME"/.config/chromium*/OptGuideOnDeviceModel; do
	[ -d "$dir" ] || continue
	found=1
	show "$dir"
	run "removed ${dir#"$HOME"/}" rm -rf -- "$dir"
done
((found)) || skip "nothing to do"

# ------------------------------------------------------------- 5. Trash -----
step "5/6  Trash"
TRASH="${XDG_DATA_HOME:-$HOME/.local/share}/Trash"
if [ -d "$TRASH" ] && [ -n "$(ls -A "$TRASH" 2>/dev/null)" ]; then
	show "$TRASH"
	run "emptied trash" find "$TRASH" -mindepth 1 -delete
else
	skip "trash is already empty"
fi

# ----------------------------------------------------- 6. systemd journal ---
step "6/6  systemd journal"
if command -v journalctl >/dev/null 2>&1; then
	((DRY_RUN)) || journalctl --disk-usage 2>/dev/null | sed 's/^/      /'
	run "vacuumed journal to 200M" sudo journalctl --vacuum-size=200M
else
	skip "journalctl not found"
fi

# ---------------------------------------------------------------- summary ---
USED_AFTER=$(root_used)
FREED=$(((USED_BEFORE - USED_AFTER) / 1048576))

printf '\n%s==>%s ' "$BOLD" "$RESET"
if ((DRY_RUN)); then
	printf 'dry run finished - nothing was changed\n'
else
	printf 'done - freed %s%ldM%s  (/ is now at %s)\n' \
		"$GREEN" "$FREED" "$RESET" \
		"$(df -h / | awk 'NR==2 {print $5 " used (" $4 " free)"}')"
fi

if ((FAILED)); then
	printf '%ssome steps failed - see above%s\n' "$RED" "$RESET"
	exit 1
fi
exit 0
