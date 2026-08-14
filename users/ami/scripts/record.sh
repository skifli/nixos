#!/usr/bin/env bash
set -euo pipefail

RECORDINGS_DIR="${HOME}/Videos/Recordings"
PID_FILE="/tmp/gpu-screen-recorder.pid"
INFO_FILE="/tmp/gpu-screen-recorder.info"
LOG_FILE="/tmp/gpu-screen-recorder.log"

FONT="${FONT_MONOSPACE:-Monospace}"
FONT_SIZE="${FONT_SIZE_APPLICATIONS:-12}"

mkdir -p "$RECORDINGS_DIR"

fuzzel_styled() {
    local prompt="$1"
    local lines="$2"
    local width="${3:-40}"

    fuzzel --dmenu \
        --font="$FONT:size=$FONT_SIZE" \
        --prompt="$prompt" \
        --background-color=1e1e2eff \
        --text-color=cdd6f4ff \
        --input-color=cdd6f4ff \
        --selection-color=585b70ff \
        --selection-text-color=cdd6f4ff \
        --width="$width" \
        --lines="$lines" \
        --horizontal-pad=12 \
        --border-radius=10
}

is_recording() {
    if [ -f "$PID_FILE" ]; then
        return 0
    fi

    if pgrep -f "gpu-screen-recorder" >/dev/null 2>&1; then
        return 0
    fi

    return 1
}

stop_recording() {
    notify-send -e -a "gpu-screen-recorder" -i "/home/${USER}/.local/share/misc/68747470733a2f2f64656330356562612e636f6d2f696d616765732f6770755f73637265656e5f7265636f726465725f6c6f676f5f736d616c6c2e706e67.png" -u low "Screen recorder" "Stopping recording..."

    pkill -SIGINT -f "gpu-screen-recorder" 2>/dev/null || true

    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        kill -2 "$PID" 2>/dev/null || true
    fi

    WAIT_COUNT=0 # 50/0.2=10s max
    while pgrep -f "gpu-screen-recorder" >/dev/null 2>&1 && [ "$WAIT_COUNT" -lt 50 ]; do
        sleep 0.2
        ((WAIT_COUNT++))
    done

    if pgrep -f "gpu-screen-recorder" >/dev/null 2>&1; then
        pkill -SIGTERM -f "gpu-screen-recorder" 2>/dev/null || true
        sleep 0.5
    fi

    if pgrep -f "gpu-screen-recorder" >/dev/null 2>&1; then
        pkill -SIGKILL -f "gpu-screen-recorder" 2>/dev/null || true
    fi

    RAW_FILE=""
    if [ -f "$INFO_FILE" ]; then
        RAW_FILE=$(cat "$INFO_FILE" 2>/dev/null || echo "")
    fi

    rm -f "$PID_FILE" "$INFO_FILE"

    if [ -z "$RAW_FILE" ] || [ ! -f "$RAW_FILE" ]; then
        ERR_MSG=$(tail -n 3 "$LOG_FILE" 2>/dev/null | tr '\n' ' ')
        notify-send -e -a "gpu-screen-recorder" -u critical "Screen recorder" "Recording failed to save:\n${ERR_MSG:-File missing or cancelled}"
        exit 1
    fi

    FINAL_FILE="$RAW_FILE"

    ACTION_CHOICE=$(printf "1. Copy raw recording\n2. Compress and copy (H.265)\n3. Save recording (nothing more)\n4. Delete recording" | fuzzel_styled "Recording saved: " 4 45)

    case "${ACTION_CHOICE,,}" in
        *compress*)
            COMPRESSED_FILE="${RAW_FILE%.mp4}_compressed.mp4"
            notify-send -e -a "gpu-screen-recorder" -u low "Screen recorder" "Compressing video with FFmpeg..."

            ffmpeg -i "$RAW_FILE" -vcodec libx265 -crf 26 -preset fast -acodec aac -b:a 128k "$COMPRESSED_FILE" -y

            rm -f "$RAW_FILE"

            FINAL_FILE="$COMPRESSED_FILE"
            echo -n "file://$FINAL_FILE" | wl-copy -t text/uri-list

            notify-send -e -a "gpu-screen-recorder" -i "/home/${USER}/.local/share/misc/68747470733a2f2f64656330356562612e636f6d2f696d616765732f6770755f73637265656e5f7265636f726465725f6c6f676f5f736d616c6c2e706e67.png" -u normal \
                "Recording saved" "Compressed file copied to clipboard:\n$FINAL_FILE"
            ;;
        *delete*)
            rm -f "$RAW_FILE"
            notify-send -e -a "gpu-screen-recorder" -u low "Screen recorder" "Recording deleted."
            exit 0
            ;;
        *nothing*|*save*)
            notify-send -e -a "gpu-screen-recorder" -i "/home/${USER}/.local/share/misc/68747470733a2f2f64656330356562612e636f6d2f696d616765732f6770755f73637265656e5f7265636f726465725f6c6f676f5f736d616c6c2e706e67.png" -u normal \
                "Recording saved" "File saved to:\n$FINAL_FILE"
            ;;
        *)
            echo -n "file://$FINAL_FILE" | wl-copy -t text/uri-list

            notify-send -e -a "gpu-screen-recorder" -i "/home/${USER}/.local/share/misc/68747470733a2f2f64656330356562612e636f6d2f696d616765732f6770755f73637265656e5f7265636f726465725f6c6f676f5f736d616c6c2e706e67.png" -u normal \
                "Recording saved" "File path copied to clipboard:\n$FINAL_FILE"
            ;;
    esac

    FOLDER_CHOICE=$(printf "1. Yes\n2. No" | fuzzel_styled "Open Folder? " 2 28)

    if [[ "${FOLDER_CHOICE,,}" == *yes* ]]; then
        xdg-open "$RECORDINGS_DIR" >/dev/null 2>&1 & # disown and pipe stdout to avoid blocking the script
    fi
}

if is_recording || [ "${1:-}" = "--stop" ]; then
    stop_recording
    exit 0
fi

TARGET_CHOICE=$(printf "1. Select via portal\n2. Focused monitor\n3. Draw region (with mouse)" | fuzzel_styled "Record Target: " 3 45)

if [ -z "$TARGET_CHOICE" ]; then exit 0; fi

AUDIO_CHOICE=$(printf "1. System audio + Microphone\n2. System audio only\n3. Microphone only\n4. No audio" | fuzzel_styled "Record Audio: " 4 40)

if [ -z "$AUDIO_CHOICE" ]; then exit 0; fi

AUDIO_ARGS=()
case "${AUDIO_CHOICE,,}" in
    *system*microphone*)
        AUDIO_ARGS=(-a "default_output" -a "default_input")
        ;;
    *system*)
        AUDIO_ARGS=(-a "default_output")
        ;;
    *microphone*)
        AUDIO_ARGS=(-a "default_input")
        ;;
    *)
        AUDIO_ARGS=()
        ;;
esac

IS_PORTAL=0
TARGET_ARGS=()
case "${TARGET_CHOICE,,}" in
    *portal*)
        IS_PORTAL=1
        TARGET_ARGS=(-w "portal" -restore-portal-session no)
        ;;
    *region*)
        REGION=$(slurp -f "%wx%h+%x+%y" 2>/dev/null || echo "")

        if [ -z "$REGION" ]; then
            notify-send -e -a "gpu-screen-recorder" -i "/home/${USER}/.local/share/misc/68747470733a2f2f64656330356562612e636f6d2f696d616765732f6770755f73637265656e5f7265636f726465725f6c6f676f5f736d616c6c2e706e67.png" -u low "Screen recorder" "Selection cancelled."
            exit 0
        fi

        TARGET_ARGS=(-w "$REGION")
        ;;
    *monitor*|*screen*)
        FOCUSED_MONITOR=$(niri msg --json focused-output 2>/dev/null | jq -r '.name // empty')

        if [ -n "$FOCUSED_MONITOR" ]; then
            TARGET_ARGS=(-w "$FOCUSED_MONITOR")
        else
            TARGET_ARGS=(-w "screen")
        fi
        ;;
esac

TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
OUTPUT_FILE="${RECORDINGS_DIR}/Recording_${TIMESTAMP}.mp4"

> "$LOG_FILE"

stdbuf -o0 -e0 gpu-screen-recorder \
    "${TARGET_ARGS[@]}" \
    "${AUDIO_ARGS[@]}" \
    -fallback-cpu-encoding yes \
    -f 60 \
    -o "$OUTPUT_FILE" >"$LOG_FILE" 2>&1 &

REC_PID=$!

echo "$REC_PID" > "$PID_FILE"
echo "$OUTPUT_FILE" > "$INFO_FILE"

sleep 0.5

if ! kill -0 "$REC_PID" 2>/dev/null; then
    rm -f "$PID_FILE" "$INFO_FILE"
    ERR_MSG=$(tail -n 3 "$LOG_FILE" 2>/dev/null | tr '\n' ' ')
    notify-send -e -a "gpu-screen-recorder" -i "/home/${USER}/.local/share/misc/68747470733a2f2f64656330356562612e636f6d2f696d616765732f6770755f73637265656e5f7265636f726465725f6c6f676f5f736d616c6c2e706e67.png" -u critical "Screen recorder" "Failed to start:\n${ERR_MSG:-Unknown error}"
    exit 1
fi

(
    if [ "$IS_PORTAL" -eq 1 ]; then
        while kill -0 "$REC_PID" 2>/dev/null; do
            if grep -q "negotiated format:" "$LOG_FILE" 2>/dev/null; then
                notify-send -e -a "gpu-screen-recorder" -i "/home/${USER}/.local/share/misc/68747470733a2f2f64656330356562612e636f6d2f696d616765732f6770755f73637265656e5f7265636f726465725f6c6f676f5f736d616c6c2e706e67.png" -u low \
                    "Recording started" "Use hotkey / bar module to stop.\nOutput: $OUTPUT_FILE"
                break
            fi
            sleep 0.2
        done
    else
        notify-send -e -a "gpu-screen-recorder" -i "/home/${USER}/.local/share/misc/68747470733a2f2f64656330356562612e636f6d2f696d616765732f6770755f73637265656e5f7265636f726465725f6c6f676f5f736d616c6c2e706e67.png" -u low \
            "Recording started" "Use hotkey / bar module to stop.\nOutput: $OUTPUT_FILE"
    fi
) &