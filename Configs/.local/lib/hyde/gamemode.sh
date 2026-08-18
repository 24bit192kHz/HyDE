#!/usr/bin/env bash
# Toggle HyDE gaming workflow. Lua Hyprland cannot `keyword source` the
# hyprlang file; on-path requires workflows.gaming. Off-path must fully
# reload — `reload config-only` leaves opaque/blur=false layer rules in place.
set -euo pipefail
LOCK_FILE="${XDG_RUNTIME_DIR:?}/hyde/gamemode.lck"

if [[ -f $LOCK_FILE ]]; then
	hyprctl reload >/dev/null
	rm -f "$LOCK_FILE"
	notify-send -a "HyDE" "Game mode" "Off — blur and gaps restored" || true
else
	mkdir -p "${XDG_RUNTIME_DIR}/hyde"
	hyprctl eval 'require("workflows.gaming")' >/dev/null
	touch "$LOCK_FILE"
	notify-send -a "HyDE" "Game mode" "On — compositor effects disabled" || true
fi
