#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────
# Hyprland Plugin Load & Auto-Update Script
# ─────────────────────────────────────────────────────────────────

# Wait for Hyprland desktop environment to settle on boot
sleep 2

# 1. Attempt standard plugin reload
if hyprpm reload; then
    exit 0
fi

# 2. If reload failed (e.g. Hyprland core ABI update), attempt auto-rebuild
notify-send -u low "Hyprland Plugins" "Hyprland version update detected. Rebuilding plugins..."

# Wait briefly for network if booting
sleep 3

if hyprpm update && hyprpm reload; then
    notify-send -u normal "Hyprland Plugins" "Plugins rebuilt & loaded successfully!"
else
    notify-send -u critical "Hyprland Plugins" "Plugins failed to load. Run 'hyprpm update' manually to inspect errors."
fi


