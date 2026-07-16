#!/usr/bin/env bash

set -euo pipefail

readonly DEFAULT_TIMEOUT_SECONDS=45
readonly MIN_SAMPLE_SECONDS=6
readonly CHECK_INTERVAL_SECONDS=3
readonly SAMPLE_RATE=44100
readonly CHANNELS=2
readonly BYTES_PER_SAMPLE=2
readonly MAX_SAMPLE_SECONDS=20
readonly MATCH_TIMEOUT_SECONDS=10

timeout_seconds=${1:-$DEFAULT_TIMEOUT_SECONDS}
if [[ ! "$timeout_seconds" =~ ^[1-9][0-9]*$ ]] || (( timeout_seconds > 600 )); then
    printf 'Usage: %s [timeout-seconds: 1-600]\n' "${0##*/}" >&2
    exit 2
fi

readonly SONGID_BIN=${SONGID_BIN:-$HOME/mhm/scripts/songid}
if [[ ! -x "$SONGID_BIN" ]]; then
    notify-send "Song ID" "Matcher not found: $SONGID_BIN" -i dialog-error
    exit 1
fi

for command in ffmpeg flock notify-send pactl timeout wl-copy; do
    if ! command -v "$command" >/dev/null; then
        printf 'Missing dependency: %s\n' "$command" >&2
        exit 1
    fi
done

exec {lock_fd}>"${XDG_RUNTIME_DIR:?}/songid.lock"
if ! flock -n "$lock_fd"; then
    notify-send "Song ID" "Already listening." -i audio-input-microphone
    exit 0
fi

temp_dir=$(mktemp -d --tmpdir songid.XXXXXX)
raw_file="$temp_dir/capture.s16le"
sample_raw="$temp_dir/sample.s16le"
sample_wav="$temp_dir/sample.wav"
capture_pid=""

cleanup() {
    if [[ -n "$capture_pid" ]] && kill -0 "$capture_pid" 2>/dev/null; then
        kill -TERM "$capture_pid" 2>/dev/null || true
        wait "$capture_pid" 2>/dev/null || true
    fi
    rm -rf -- "$temp_dir"
}
trap cleanup EXIT INT TERM

audio_source="$(pactl get-default-sink).monitor"
notify-send \
    "Listening..." \
    "Identifying continuously for up to ${timeout_seconds}s." \
    -i audio-input-microphone

ffmpeg -y -hide_banner -loglevel error \
    -f pulse -i "$audio_source" \
    -t "$timeout_seconds" \
    -af "silenceremove=start_periods=1:start_threshold=-50dB" \
    -ar "$SAMPLE_RATE" -ac "$CHANNELS" -f s16le \
    "$raw_file" &
capture_pid=$!

readonly bytes_per_second=$((SAMPLE_RATE * CHANNELS * BYTES_PER_SAMPLE))
readonly minimum_bytes=$((MIN_SAMPLE_SECONDS * bytes_per_second))
readonly maximum_bytes=$((MAX_SAMPLE_SECONDS * bytes_per_second))
deadline=$((SECONDS + timeout_seconds))
next_check=$((SECONDS + MIN_SAMPLE_SECONDS))
song_info=""

while (( SECONDS < deadline )); do
    if (( SECONDS < next_check )); then
        sleep 0.2
        continue
    fi
    next_check=$((SECONDS + CHECK_INTERVAL_SECONDS))

    raw_size=$(stat -c %s "$raw_file" 2>/dev/null || printf '0')
    if (( raw_size < minimum_bytes )); then
        if ! kill -0 "$capture_pid" 2>/dev/null; then
            break
        fi
        continue
    fi

    if (( raw_size > maximum_bytes )); then
        tail -c "$maximum_bytes" "$raw_file" >"$sample_raw"
    else
        cp -- "$raw_file" "$sample_raw"
    fi

    if ! ffmpeg -y -hide_banner -loglevel error \
        -f s16le -ar "$SAMPLE_RATE" -ac "$CHANNELS" \
        -i "$sample_raw" -c:a pcm_s16le "$sample_wav"; then
        continue
    fi

    remaining_seconds=$((deadline - SECONDS))
    if (( remaining_seconds <= 0 )); then
        break
    fi
    match_timeout=$MATCH_TIMEOUT_SECONDS
    if (( match_timeout > remaining_seconds )); then
        match_timeout=$remaining_seconds
    fi
    song_info=$(timeout "$match_timeout" "$SONGID_BIN" "$sample_wav" 2>/dev/null || true)
    if [[ -n "$song_info" ]]; then
        break
    fi

    if ! kill -0 "$capture_pid" 2>/dev/null; then
        break
    fi
done

if [[ -n "$song_info" ]]; then
    printf '%s' "$song_info" | wl-copy
    notify-send "Song Found!" "$song_info" -i audio-x-generic
    printf '%s\n' "$song_info"
else
    notify-send \
        "Song ID" \
        "No match found within ${timeout_seconds}s." \
        -i dialog-error
    exit 1
fi
