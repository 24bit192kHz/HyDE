#!/usr/bin/env bash

set -euo pipefail

readonly DEFAULT_TIMEOUT_SECONDS=45
readonly MIN_SAMPLE_SECONDS=8
readonly CHECK_INTERVAL_SECONDS=8
readonly SAMPLE_RATE=44100
readonly CHANNELS=2
readonly BYTES_PER_SAMPLE=2
readonly MAX_SAMPLE_SECONDS=12
readonly RECOGNITION_TIMEOUT_SECONDS=12

recognition_outcome=""
recognition_message=""
song_info=""
temp_dir=""
capture_pid=""

notify_error() {
    notify-send "Song ID" "$1" -i dialog-error
}

parse_songrec_response() {
    local response_file=$1
    local artist title album song_link

    recognition_outcome=""
    recognition_message=""
    song_info=""

    if ! jq -e . "$response_file" >/dev/null 2>&1; then
        recognition_outcome="transient"
        recognition_message="SongRec returned malformed recognition data."
        return
    fi

    artist=$(jq -r '.track.subtitle // empty' "$response_file")
    title=$(jq -r '.track.title // empty' "$response_file")
    album=$(jq -r '
        [.track.sections[]?.metadata[]?
         | select(.title == "Album")
         | .text][0] // empty
    ' "$response_file")
    song_link=$(jq -r '.track.url // empty' "$response_file")

    if [[ -z "$artist" || -z "$title" ]]; then
        recognition_outcome="transient"
        recognition_message="SongRec returned an incomplete match."
        return
    fi

    song_info="$artist - $title"
    [[ -n "$album" ]] && song_info+=$'\n'"$album"
    [[ -n "$song_link" ]] && song_info+=$'\n'"$song_link"
    recognition_outcome="match"
}

recognize_sample() {
    local sample_wav=$1
    local request_timeout=$2
    local response_file=$3
    local error_file=$4
    local songrec_rc=0

    LC_ALL=C timeout "$request_timeout"         songrec recognize --json "$sample_wav"         >"$response_file" 2>"$error_file" || songrec_rc=$?

    if [[ -s "$response_file" ]]; then
        parse_songrec_response "$response_file"
        return
    fi

    if grep -Fq "No match for this song" "$error_file"; then
        recognition_outcome="no_match"
        recognition_message=""
        return
    fi

    recognition_outcome="transient"
    case "$songrec_rc" in
        124)
            recognition_message="SongRec recognition timed out."
            ;;
        *)
            recognition_message="SongRec could not reach Shazam."
            ;;
    esac
}

main() {
    local timeout_seconds=${1:-$DEFAULT_TIMEOUT_SECONDS}
    local command audio_source raw_file sample_raw sample_wav
    local response_file error_file raw_size remaining_seconds
    local request_timeout deadline next_check last_transient_message=""
    local saw_no_match=false

    if [[ ! "$timeout_seconds" =~ ^[1-9][0-9]*$ ]] || (( timeout_seconds > 600 )); then
        printf 'Usage: %s [timeout-seconds: 1-600]\n' "${0##*/}" >&2
        return 2
    fi

    for command in ffmpeg flock grep jq notify-send pactl songrec stat tail timeout wl-copy; do
        if ! command -v "$command" >/dev/null; then
            printf 'Missing dependency: %s\n' "$command" >&2
            command -v notify-send >/dev/null && notify_error "Missing dependency: $command"
            return 2
        fi
    done

    exec {lock_fd}>"${XDG_RUNTIME_DIR:?}/songid.lock"
    if ! flock -n "$lock_fd"; then
        notify-send "Song ID" "Already listening." -i audio-input-microphone
        return 0
    fi

    temp_dir=$(mktemp -d --tmpdir songid.XXXXXX)
    raw_file="$temp_dir/capture.s16le"
    sample_raw="$temp_dir/sample.s16le"
    sample_wav="$temp_dir/sample.wav"
    response_file="$temp_dir/songrec-response.json"
    error_file="$temp_dir/songrec-error.log"

    cleanup() {
        if [[ -n "$capture_pid" ]] && kill -0 "$capture_pid" 2>/dev/null; then
            kill -TERM "$capture_pid" 2>/dev/null || true
            wait "$capture_pid" 2>/dev/null || true
        fi
        rm -rf -- "$temp_dir"
    }
    trap cleanup EXIT
    trap 'exit 130' INT
    trap 'exit 143' TERM

    if ! audio_source="$(pactl get-default-sink).monitor"; then
        notify_error "Could not determine the default audio output."
        return 2
    fi

    notify-send         "Listening..."         "Identifying continuously for up to ${timeout_seconds}s."         -i audio-input-microphone

    ffmpeg -y -hide_banner -loglevel error         -f pulse -i "$audio_source"         -t "$timeout_seconds"         -af "silenceremove=start_periods=1:start_threshold=-50dB"         -ar "$SAMPLE_RATE" -ac "$CHANNELS" -f s16le         "$raw_file" &
    capture_pid=$!

    readonly bytes_per_second=$((SAMPLE_RATE * CHANNELS * BYTES_PER_SAMPLE))
    readonly minimum_bytes=$((MIN_SAMPLE_SECONDS * bytes_per_second))
    readonly maximum_bytes=$((MAX_SAMPLE_SECONDS * bytes_per_second))
    deadline=$((SECONDS + timeout_seconds))
    next_check=$((SECONDS + MIN_SAMPLE_SECONDS))

    while (( SECONDS < deadline )); do
        if (( SECONDS < next_check )); then
            sleep 0.2
            continue
        fi
        next_check=$((SECONDS + CHECK_INTERVAL_SECONDS))

        raw_size=$(stat -c %s "$raw_file" 2>/dev/null || printf '0')
        if (( raw_size < minimum_bytes )); then
            if ! kill -0 "$capture_pid" 2>/dev/null; then
                notify_error "Audio capture stopped unexpectedly."
                return 2
            fi
            continue
        fi

        if (( raw_size > maximum_bytes )); then
            tail -c "$maximum_bytes" "$raw_file" >"$sample_raw"
        else
            cp -- "$raw_file" "$sample_raw"
        fi

        if ! ffmpeg -y -hide_banner -loglevel error             -f s16le -ar "$SAMPLE_RATE" -ac "$CHANNELS"             -i "$sample_raw" -c:a pcm_s16le "$sample_wav"; then
            continue
        fi

        remaining_seconds=$((deadline - SECONDS))
        (( remaining_seconds > 0 )) || break
        request_timeout=$RECOGNITION_TIMEOUT_SECONDS
        (( request_timeout <= remaining_seconds )) || request_timeout=$remaining_seconds

        : >"$response_file"
        : >"$error_file"
        recognize_sample "$sample_wav" "$request_timeout" "$response_file" "$error_file"

        case "$recognition_outcome" in
            match)
                printf '%s' "$song_info" | wl-copy
                notify-send "Song Found!" "$song_info" -i audio-x-generic
                printf '%s\n' "$song_info"
                return 0
                ;;
            no_match)
                saw_no_match=true
                ;;
            transient)
                last_transient_message=$recognition_message
                ;;
        esac

        if ! kill -0 "$capture_pid" 2>/dev/null && (( SECONDS < deadline )); then
            notify_error "Audio capture stopped unexpectedly."
            return 2
        fi
    done

    if [[ "$saw_no_match" == true ]]; then
        notify_error "No match found within ${timeout_seconds}s."
        return 1
    fi

    if [[ -n "$last_transient_message" ]]; then
        notify_error "Recognition service failed: $last_transient_message"
        return 5
    fi

    notify_error "No usable audio was captured within ${timeout_seconds}s."
    return 2
}

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    main "$@"
fi
