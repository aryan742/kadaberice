#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────
# AryanOS — High-Performance Modular Wallpaper Rotation Engine
# ─────────────────────────────────────────────────────────────────

WALLPAPERS_DIR="$HOME/Pictures/Wallpapers"
RAW_DIR="$HOME/Pictures/raw"
HYPRPAPER_CONF="$HOME/.config/hypr/hyprpaper.conf"

# ── Step 1: Create Category Folders ──────────────────────────────
categories=("Hanuman" "Shiva" "Krishna" "Warriors" "Minimal" "Art")

for cat in "${categories[@]}"; do
    mkdir -p "$WALLPAPERS_DIR/$cat"
done

# ── Step 2: Dynamically Distribute Raw Images ────────────────────
# If category folders are empty and raw images exist, distribute them
if [ -d "$RAW_DIR" ]; then
    raw_images=("$RAW_DIR"/*)
    if [ ${#raw_images[@]} -gt 0 ] && [ "$(find "$WALLPAPERS_DIR" -type f | wc -l)" -eq 0 ]; then
        echo "Distributing raw wallpapers into artistic categories..."
        idx=0
        for img in "${raw_images[@]}"; do
            [ -f "$img" ] || continue
            cat_folder="${categories[$((idx % 6))]}"
            cp "$img" "$WALLPAPERS_DIR/$cat_folder/"
            idx=$((idx + 1))
        done
    fi
fi

# ── Step 3: Select Initial Wallpaper ─────────────────────────────
# Find all wallpapers recursively
all_wallpapers=($(find "$WALLPAPERS_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" \)))

if [ ${#all_wallpapers[@]} -eq 0 ]; then
    echo "No wallpapers found!"
    exit 1
fi

# Pick a random one
initial_wall="${all_wallpapers[RANDOM % ${#all_wallpapers[@]}]}"

# Initialize hyprpaper config if missing or empty
echo "preload = $initial_wall" > "$HYPRPAPER_CONF"
echo "wallpaper = ,$initial_wall" >> "$HYPRPAPER_CONF"
echo "ipc = on" >> "$HYPRPAPER_CONF"

# Make sure hyprpaper is running
if ! pgrep -x "hyprpaper" > /dev/null; then
    hyprpaper &
    sleep 1
else
    # Daemon is already running, switch dynamically
    hyprctl hyprpaper preload "$initial_wall"
    hyprctl hyprpaper wallpaper ",$initial_wall"
fi

# ── Step 4: Wallpaper Rotation Loop ─────────────────────────────
# Rotation interval (15 minutes = 900 seconds)
INTERVAL=900

while true; do
    sleep "$INTERVAL"
    
    # Select a new random wallpaper from the collection
    new_wall="${all_wallpapers[RANDOM % ${#all_wallpapers[@]}]}"
    
    # Fast native transition using hyprctl hyprpaper IPC
    hyprctl hyprpaper preload "$new_wall"
    hyprctl hyprpaper wallpaper ",$new_wall"
    
    # Performance Optimization: Unload older preloaded wallpapers to keep idle RAM under 1.5GB
    sleep 2
    hyprctl hyprpaper unload all
done
