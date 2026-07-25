#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# AryanOS — High-Performance Native Clipboard Launcher
# Integration: cliphist + wl-clipboard + Rofi + Matugen
# ─────────────────────────────────────────────────────────────────────────────

ROFI_THEME="$HOME/.config/rofi/clipboard.rasi"

# Handle wipe flag if passed directly
if [[ "$1" == "wipe" ]]; then
    cliphist wipe
    notify-send -u normal -i edit-clear "Clipboard Manager" "Clipboard history wiped clean."
    exit 0
fi

# Fetch clipboard list and display via Matugen-themed Rofi dmenu
SELECTED=$(cliphist list | rofi -dmenu -theme "$ROFI_THEME" -p "📋 Clipboard")

# If an item was selected, extract item ID and restore exact original content to Wayland clipboard
if [[ -n "$SELECTED" ]]; then
    ITEM_ID=$(echo "$SELECTED" | awk '{print $1}')
    if [[ -n "$ITEM_ID" ]]; then
        cliphist decode "$ITEM_ID" | wl-copy
        notify-send -u low -i edit-paste "Clipboard Manager" "Item restored to clipboard."
    fi
fi
