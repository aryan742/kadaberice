#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────
# Hyprland Plugin Self-Healing Auto-Update Script
# ─────────────────────────────────────────────────────────────────

# 1. Attempt standard fast reload
hyprpm reload -n

# 2. Verify if hyprexpo plugin loaded cleanly
if ! hyprctl plugin list | grep -qi "hyprexpo"; then
    notify-send -u low "Hyprland Plugins" "Hyprland version update detected. Rebuilding plugins automatically..."
    
    # Auto-compile plugins against the current Hyprland headers
    hyprpm update
    hyprpm reload -n
    
    if hyprctl plugin list | grep -qi "hyprexpo"; then
        notify-send -u normal "Hyprland Plugins" "HyprExpo rebuilt & loaded successfully!"
    else
        notify-send -u critical "Hyprland Plugins" "HyprExpo failed to load. Run 'hyprpm update' manually to inspect errors."
    fi
fi
