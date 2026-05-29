#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# screenshot.sh — Hyprland Screenshot Helper
# ─────────────────────────────────────────────────────────────────────────────
# Dependencies: grim, slurp, wl-copy (wl-clipboard), dunst/notify-send
# Save path:    ~/Pictures/Screenshots/YYYY-MM-DD_HH-MM-SS.png
# Usage:        screenshot.sh [mode]
#
# Modes:
#   full      — Fullscreen → save to file
#   region    — Region selection → save to file
#   window    — Active window → save to file
#   region-cb — Region selection → clipboard only (no file)
#   window-cb — Active window → clipboard only (no file)
# ─────────────────────────────────────────────────────────────────────────────

SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
OUTFILE="$SCREENSHOT_DIR/${TIMESTAMP}.png"

# Ensure the screenshots directory exists
mkdir -p "$SCREENSHOT_DIR"

# Helper: send a desktop notification (graceful if notify-send missing)
notify() {
    local msg="$1"
    if command -v notify-send &>/dev/null; then
        notify-send "📸 Screenshot" "$msg" -i camera-photo -t 2000
    fi
}

# Helper: get active window geometry from Hyprland
get_window_geometry() {
    hyprctl activewindow -j \
        | python3 -c "
import sys, json
w = json.load(sys.stdin)
x, y = w['at']
W, H = w['size']
print(f'{x},{y} {W}x{H}')
"
}

MODE="${1:-full}"

case "$MODE" in
    full)
        # Capture the entire screen → save to file
        grim "$OUTFILE"
        notify "Fullscreen saved → $(basename "$OUTFILE")"
        ;;

    region)
        # Interactive region selection → save to file
        SELECTION=$(slurp 2>/dev/null)
        [[ -z "$SELECTION" ]] && exit 0   # user cancelled
        grim -g "$SELECTION" "$OUTFILE"
        notify "Region saved → $(basename "$OUTFILE")"
        ;;

    window)
        # Active window geometry → save to file
        GEOMETRY=$(get_window_geometry)
        [[ -z "$GEOMETRY" ]] && exit 1
        grim -g "$GEOMETRY" "$OUTFILE"
        notify "Window saved → $(basename "$OUTFILE")"
        ;;

    region-cb)
        # Interactive region selection → clipboard only (no file saved)
        SELECTION=$(slurp 2>/dev/null)
        [[ -z "$SELECTION" ]] && exit 0   # user cancelled
        grim -g "$SELECTION" - | wl-copy
        notify "Region copied to clipboard"
        ;;

    window-cb)
        # Active window → clipboard only (no file saved)
        GEOMETRY=$(get_window_geometry)
        [[ -z "$GEOMETRY" ]] && exit 1
        grim -g "$GEOMETRY" - | wl-copy
        notify "Window copied to clipboard"
        ;;

    *)
        echo "Usage: screenshot.sh [full|region|window|region-cb|window-cb]" >&2
        exit 1
        ;;
esac
