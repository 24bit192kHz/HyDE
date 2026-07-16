#!/usr/bin/env bash

set -euo pipefail

readonly DEFAULT_TIMEOUT_SECONDS=45
readonly MIN_SAMPLE_SECONDS=6
readonly CHECK_INTERVAL_SECONDS=3
readonly SAMPLE_RATE=44100
readonly CHANNELS=2
readonly BYTES_PER_SAMPLE=2
readonly MAX_SAMPLE_SECONDS=20
readonly API_REQUEST_TIMEOUT_SECONDS=10
readonly API_CONNECT_TIMEOUT_SECONDS=4
readonly API_URL=${AUDD_API_URL:-https://api.audd.io/}
readonly TOKEN_FILE=${AUDD_TOKEN_FILE:-$HOME/.config/songid/audd.env}

api_outcome=""
api_message=""
song_info=""

notify_error() {
    notify-send "Song ID" "$1" -i dialog-error
}

load_api_token() {
    local line token=""

    if [[ ! -f "$TOKEN_FILE" ]]; then
        api_message="AudD token is missing: $TOKEN_FILE"
        return 1
    fi
    if [[ $(stat -c '%a' "$TOKEN_FILE") != "600" ]]; then
        api_message="AudD token file must have mode 0600: $TOKEN_FILE"
        return 1
    fi

    while IFS= read -r line || [[ -n "$line" ]]; do
        line=${line%$'\r'}
        if [[ "$line" == AUDD_API_TOKEN=* ]]; then
            token=${line#AUDD_API_TOKEN=}
            break
        fi
    done <"$TOKEN_FILE"

    if [[ -z "$token" || ! "$token" =~ ^[^[:space:]]+$ ]]; then
        api_message="AUDD_API_TOKEN is missing or invalid in $TOKEN_FILE"
        return 1
    fi

    AUDD_API_TOKEN=$token
    readonly AUDD_API_TOKEN
}

parse_audd_response() {
    local response_file=$1
    local status error_code artist title album song_link

    api_outcome=""
    api_message=""
    song_info=""

    if ! jq -e . "$response_file" >/dev/null 2>&1; then
        api_outcome="transient"
        api_message="AudD returned malformed JSON."
        return
    fi

    status=$(jq -r '.status // empty' "$response_file")
    if [[ "$status" == "success" ]]; then
        if jq -e '.result == null or .result == []' "$response_file" >/dev/null; then
            api_outcome="no_match"
            return
        fi

        artist=$(jq -r '.result.artist // empty' "$response_file")
        title=$(jq -r '.result.title // empty' "$response_file")
        album=$(jq -r '.result.album // empty' "$response_file")
        song_link=$(jq -r '.result.song_link // empty' "$response_file")
        if [[ -z "$artist" || -z "$title" ]]; then
            api_outcome="transient"
            api_message="AudD returned an incomplete match."
            return
        fi

        song_info="$artist - $title"
        [[ -n "$album" ]] && song_info+=$'\n'"$album"
        [[ -n "$song_link" ]] && song_info+=$'\n'"$song_link"
        api_outcome="match"
        return
    fi

    if [[ "$status" == "error" ]]; then
        error_code=$(jq -r '.error.error_code // .error.code // empty' "$response_file")
        api_message=$(jq -r '.error.error_message // .error.message // "AudD API error."' "$response_file")
        case "$error_code" in
            900)
                api_outcome="auth"
                ;;
            901)
                api_outcome="quota"
                ;;
            *)
                api_outcome="permanent"
                ;;
        esac
        return
    fi

    api_outcome="transient"
    api_message="AudD returned an unrecognized response."
}

recognize_sample() {
    local sample_wav=$1
    local request_timeout=$2
    local response_file=$3
    local error_file=$4
    local curl_rc=0 http_code=""

    http_code=$(curl --silent --show-error --fail-with-body \
        --connect-timeout "$API_CONNECT_TIMEOUT_SECONDS" \
        --max-time "$request_timeout" \
        --output "$response_file" \
        --write-out '%{http_code}' \
        --form-string "api_token=$AUDD_API_TOKEN" \
        --form "file=@$sample_wav;type=audio/wav" \
        "$API_URL" 2>"$error_file") || curl_rc=$?

    if [[ -s "$response_file" ]]; then
        parse_audd_response "$response_file"
        if [[ "$api_outcome" != "transient" ]]; then
            return
        fi
    fi

    case "$http_code" in
        401|403)
            api_outcome="auth"
            api_message="AudD rejected the API token."
            ;;
        429)
            api_outcome="quota"
            api_message="AudD recognition quota is exhausted."
            ;;
        5??|000|"")
            api_outcome="transient"
            api_message="AudD is temporarily unreachable."
            ;;
        *)
            if (( curl_rc != 0 )); then
                api_outcome="transient"
                api_message="AudD request failed."
            elif [[ -z "$api_outcome" ]]; then
                api_outcome="permanent"
                api_message="AudD request failed with HTTP $http_code."
            fi
            ;;
    esac
}

main() {
    local timeout_seconds=${1:-$DEFAULT_TIMEOUT_SECONDS}
    local command audio_source temp_dir raw_file sample_raw sample_wav
    local response_file error_file capture_pid="" raw_size remaining_seconds
    local request_timeout deadline next_check last_transient_message=""
    local saw_no_match=false

    if [[ ! "$timeout_seconds" =~ ^[1-9][0-9]*$ ]] || (( timeout_seconds > 600 )); then
        printf 'Usage: %s [timeout-seconds: 1-600]\n' "${0##*/}" >&2
        return 2
    fi

    for command in curl ffmpeg flock jq notify-send pactl stat tail wl-copy; do
        if ! command -v "$command" >/dev/null; then
            printf 'Missing dependency: %s\n' "$command" >&2
            command -v notify-send >/dev/null && notify_error "Missing dependency: $command"
            return 2
        fi
    done

    if ! load_api_token; then
        notify_error "$api_message"
        printf '%s\n' "$api_message" >&2
        return 3
    fi

    exec {lock_fd}>"${XDG_RUNTIME_DIR:?}/songid.lock"
    if ! flock -n "$lock_fd"; then
        notify-send "Song ID" "Already listening." -i audio-input-microphone
        return 0
    fi

    temp_dir=$(mktemp -d --tmpdir songid.XXXXXX)
    raw_file="$temp_dir/capture.s16le"
    sample_raw="$temp_dir/sample.s16le"
    sample_wav="$temp_dir/sample.wav"
    response_file="$temp_dir/audd-response.json"
    error_file="$temp_dir/audd-error.log"

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

        if ! ffmpeg -y -hide_banner -loglevel error \
            -f s16le -ar "$SAMPLE_RATE" -ac "$CHANNELS" \
            -i "$sample_raw" -c:a pcm_s16le "$sample_wav"; then
            continue
        fi

        remaining_seconds=$((deadline - SECONDS))
        (( remaining_seconds > 0 )) || break
        request_timeout=$API_REQUEST_TIMEOUT_SECONDS
        (( request_timeout <= remaining_seconds )) || request_timeout=$remaining_seconds

        : >"$response_file"
        : >"$error_file"
        recognize_sample "$sample_wav" "$request_timeout" "$response_file" "$error_file"
        case "$api_outcome" in
            match)
                printf '%s' "$song_info" | wl-copy
                notify-send "Song Found!" "$song_info" -i audio-x-generic
                printf '%s\n' "$song_info"
                return 0
                ;;
            no_match)
                saw_no_match=true
                ;;
            auth)
                notify_error "AudD authentication failed: $api_message"
                return 3
                ;;
            quota)
                notify_error "AudD quota error: $api_message"
                return 4
                ;;
            permanent)
                notify_error "AudD API error: $api_message"
                return 4
                ;;
            transient)
                last_transient_message=$api_message
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
