#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────
# Matugen Wallpaper Hook — Triggered automatically by Waypaper
# ─────────────────────────────────────────────────────────────────

WP="$1"

# Fallback: if waypaper didn't pass path directly, read from config.ini
if [ -z "$WP" ] || [ ! -f "$WP" ]; then
    WP=$(grep "^wallpaper =" ~/.config/waypaper/config.ini | cut -d'=' -f2 | xargs)
fi

# Expand tilde if present
WP="${WP/#\~/$HOME}"

if [ -f "$WP" ]; then
    matugen image "$WP" --source-color-index 0 --mode dark
fi
