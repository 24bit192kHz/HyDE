#!/usr/bin/env bash
# rofi.websearch fast path (user-owned shadow of ~/.local/lib/hyde/rofi.websearch.sh).
# Resolved first via HYDE_SCRIPTS_PATH (~/.config/hyde/scripts before lib dir),
# so this file shadows the share backend without editing HyDE-managed code.
#
# Contract: with no `engine:` prefix and no -s/--site/--clear-cache/-h/--help
# flag, skip the engine-picker dmenu by exec'ing the backend with --site
# resolved (env ROFI_WEBSEARCH_DEFAULT_SITE, else MRU top of recent.sites,
# else google). Exactly one rofi spawn (query pass) occurs. Anything else
# falls through to the backend byte-for-byte (two-pass) behavior.
set -e
# NOTE: the share backend dies silently under `set -e` when
# ~/.local/state/hyde/config is missing (export_hyde_config returns 1).
# Ensure it exists so both fast-path and fall-through execs survive.
state_file="${XDG_STATE_HOME:-$HOME/.local/state}/hyde/config"
[ -f "$state_file" ] || : > "$state_file" 2>/dev/null || true
BACKEND="${ROFI_WEBSEARCH_BACKEND:-$HOME/.local/lib/hyde/rofi.websearch.sh}"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/hyde/landing/websearch"

trim_hist() {
    # Bound per-engine query histories so the query-pass dmenu seed stays small.
    # Runs BEFORE exec: the backend prepends the new query afterwards (+1 row max).
    if command -v perl >/dev/null 2>&1; then
        # `close ARGV if eof` resets $. per file; without it only the first
        # history file would be trimmed.
        perl -i -ne 'print if $. <= 200; close ARGV if eof' "$CACHE_DIR"/*.txt 2>/dev/null || true
    else
        for f in "$CACHE_DIR"/*.txt; do
            [ -f "$f" ] || continue
            head -200 "$f" > "$f.tmp" && mv "$f.tmp" "$f"
        done
    fi
}

trim_hist

has_site_prefix=false
for a in "$@"; do
    case "$a" in
        -s|--site|--clear-cache|-h|--help|*:*) has_site_prefix=true; break ;;
    esac
done

if ! $has_site_prefix; then
    def="${ROFI_WEBSEARCH_DEFAULT_SITE:-}"
    if [ -z "$def" ] && [ -f "$CACHE_DIR/recent.sites" ]; then
        # recent.sites holds bare site names (one per line); tolerate `a | b` form.
        def=$(head -1 "$CACHE_DIR/recent.sites" 2>/dev/null | awk -F'|' '{print $1}' | xargs 2>/dev/null || true)
    fi
    def="${def:-google}"
    exec bash "$BACKEND" --site "$def" "$@"
fi
exec bash "$BACKEND" "$@"
