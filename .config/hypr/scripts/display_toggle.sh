#!/usr/bin/env bash

# ─────────────────────────────────────────────────────────────────
# AryanOS — Presentation & External Display Manager
# Quickly toggles HDMI / Projector modes between Mirror, Extend, and Projector Only.
# ─────────────────────────────────────────────────────────────────

PRIMARY="eDP-1"

# Find first connected external monitor (excluding primary eDP-1)
EXTERNAL=$(hyprctl monitors all | grep -oP 'Monitor \K[A-Za-z0-9-]+' | grep -v "$PRIMARY" | head -n 1)

if [ -z "$EXTERNAL" ]; then
    # Fallback check via sysfs if monitor is plugged but disabled
    EXTERNAL=$(ls /sys/class/drm/ | grep -E 'card[0-9]+-(HDMI-A|DP)-[0-9]+' | sed 's/card[0-9]+-//' | head -n 1)
fi

if [ -z "$EXTERNAL" ]; then
    notify-send -u low -i display "Display Manager" "No external projector or monitor detected."
    exit 0
fi

STATE_FILE="/tmp/hypr_display_mode"
CURRENT_MODE=$(cat "$STATE_FILE" 2>/dev/null || echo "mirror")

case "$CURRENT_MODE" in
    "mirror")
        # Switch to Extended Mode
        hyprctl keyword monitor "$PRIMARY,preferred,auto,1"
        hyprctl keyword monitor "$EXTERNAL,preferred,auto-right,1"
        echo "extend" > "$STATE_FILE"
        notify-send -u normal -i display "Display Mode: Extended" "Projector set to Extended Desktop ($EXTERNAL on right)"
        ;;
    "extend")
        # Switch to External Only Mode
        hyprctl keyword monitor "$PRIMARY,disable"
        hyprctl keyword monitor "$EXTERNAL,preferred,auto,1"
        echo "external_only" > "$STATE_FILE"
        notify-send -u normal -i display "Display Mode: Projector Only" "Laptop display disabled. Projector active ($EXTERNAL)"
        ;;
    *)
        # Default: Switch to Mirror Mode (Best for Presentations!)
        hyprctl keyword monitor "$PRIMARY,preferred,auto,1"
        hyprctl keyword monitor "$EXTERNAL,preferred,auto,1,mirror,$PRIMARY"
        echo "mirror" > "$STATE_FILE"
        notify-send -u normal -i display "Display Mode: Presentation Mirror" "Projector mirroring laptop screen ($EXTERNAL = $PRIMARY)"
        ;;
esac
