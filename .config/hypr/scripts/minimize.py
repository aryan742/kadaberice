#!/usr/bin/env python3
import sys
import os
import json
import subprocess

CACHE_DIR = os.path.expanduser("~/.cache/hypr")
CACHE_FILE = os.path.join(CACHE_DIR, "minimized.json")

ICON_MAP = {
    "kitty": "󰄛",
    "alacritty": "",
    "foot": "󰞷",
    "firefox": "󰈹",
    "zen": "󰈹",
    "zen-browser": "󰈹",
    "google-chrome": "",
    "chromium": "",
    "vivaldi-stable": "󰖟",
    "vivaldi": "󰖟",
    "thunar": "󰉋",
    "nautilus": "󰉋",
    "dolphin": "󰉋",
    "code": "󰨞",
    "code-oss": "󰨞",
    "vscodium": "󰨞",
    "antigravity-ide": "󰨞",
    "discord": "󰙯",
    "vesktop": "󰙯",
    "webcord": "󰙯",
    "telegramdesktop": "",
    "spotify": "󰓇",
    "steam": "󰓓",
    "mpv": "",
    "vlc": "󰕼",
}

def get_icon(cls):
    cls_lower = (cls or "").lower()
    for key, icon in ICON_MAP.items():
        if key in cls_lower:
            return icon
    return "󰘚"

def run_hyprctl(cmd, is_json=True):
    try:
        args = ["hyprctl"]
        if is_json:
            args.append("-j")
        args.extend(cmd if isinstance(cmd, list) else cmd.split())
        res = subprocess.run(args, capture_output=True, text=True, check=True)
        if is_json:
            return json.loads(res.stdout)
        return res.stdout
    except Exception:
        return None

def notify_waybar():
    try:
        subprocess.run(["pkill", "-RTMIN+8", "waybar"], check=False)
    except Exception:
        pass

def load_minimized():
    if not os.path.exists(CACHE_FILE):
        return []
    try:
        with open(CACHE_FILE, "r") as f:
            data = json.load(f)
            if isinstance(data, list):
                clients = run_hyprctl("clients") or []
                live_addresses = {c.get("address") for c in clients if c.get("address")}
                valid_data = [w for w in data if w.get("address") in live_addresses]
                if len(valid_data) != len(data):
                    save_minimized(valid_data)
                return valid_data
    except Exception:
        pass
    return []

def save_minimized(data):
    os.makedirs(CACHE_DIR, exist_ok=True)
    try:
        with open(CACHE_FILE, "w") as f:
            json.dump(data, f, indent=2)
    except Exception:
        pass

def minimize_active():
    active = run_hyprctl("activewindow")
    if not active or not active.get("address"):
        return
    
    ws_name = active.get("workspace", {}).get("name", "")
    if ws_name in ("minimized", "special:minimized"):
        return

    addr = active["address"]
    cls = active.get("class", "")
    title = active.get("title", "")
    current_ws_id = str(active.get("workspace", {}).get("id", 1))

    minimized = load_minimized()
    minimized = [w for w in minimized if w.get("address") != addr]
    minimized.append({
        "address": addr,
        "class": cls,
        "title": title,
        "prev_ws": current_ws_id
    })
    save_minimized(minimized)

    # Unfullscreen active window if needed
    if active.get("fullscreen", 0) != 0:
        subprocess.run(["hyprctl", "eval", "hl.dispatch(hl.dsp.window.fullscreen(0))"], check=False, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    # Move active window to clean hidden workspace "minimized" and ensure current workspace remains active
    lua_code = (
        'hl.dispatch(hl.dsp.window.move({ workspace = "name:minimized", silent = true })) '
        f'hl.dispatch(hl.dsp.focus({{ workspace = "{current_ws_id}" }}))'
    )
    subprocess.run(["hyprctl", "eval", lua_code], check=False, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    notify_waybar()

def restore_window(target_addr=None):
    minimized = load_minimized()
    if not minimized:
        return

    if target_addr:
        target = next((w for w in minimized if w.get("address") == target_addr), None)
    else:
        target = minimized[-1]

    if not target:
        return

    minimized = [w for w in minimized if w.get("address") != target["address"]]
    save_minimized(minimized)

    active_ws = run_hyprctl("activeworkspace")
    target_ws = str(active_ws.get("id", target.get("prev_ws", 1)) if active_ws else target.get("prev_ws", 1))
    addr = target["address"]

    # Focus window on minimized workspace, move back to current workspace, and focus
    lua_code = (
        f'hl.dispatch(hl.dsp.focus({{ window = "address:{addr}" }})) '
        f'hl.dispatch(hl.dsp.window.move({{ workspace = "{target_ws}", silent = false }})) '
        f'hl.dispatch(hl.dsp.focus({{ window = "address:{addr}" }}))'
    )
    subprocess.run(["hyprctl", "eval", lua_code], check=False, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    notify_waybar()

def toggle():
    active = run_hyprctl("activewindow")
    if active and active.get("address") and active.get("workspace", {}).get("name", "") not in ("minimized", "special:minimized"):
        minimize_active()
    else:
        restore_window()

def menu():
    minimized = load_minimized()
    if not minimized:
        return
    if len(minimized) == 1:
        restore_window(minimized[0]["address"])
        return

    lines = []
    for w in reversed(minimized):
        icon = get_icon(w.get("class"))
        title = w.get("title") or w.get("class") or "Window"
        lines.append(f"{icon}  {title} [{w['address']}]")

    input_text = "\n".join(lines)
    try:
        p = subprocess.run(
            ["rofi", "-dmenu", "-p", "Restore Window", "-i"],
            input=input_text,
            text=True,
            capture_output=True
        )
        selected = p.stdout.strip()
        if selected and "[" in selected and selected.endswith("]"):
            addr = selected.split("[")[-1].rstrip("]")
            restore_window(addr)
    except Exception:
        pass

def status():
    minimized = load_minimized()
    if not minimized:
        print(json.dumps({"text": "", "tooltip": "", "class": "empty"}))
        return

    icons = [get_icon(w.get("class")) for w in minimized]
    icon_str = " ".join(icons)
    count = len(minimized)
    
    titles = [f"• {get_icon(w.get('class'))} {w.get('title', 'Window')}" for w in minimized]
    tooltip = f"<b>Minimized Windows ({count})</b>\n" + "\n".join(titles) + "\n\n<i>Left-click to restore\nRight-click for menu</i>"

    out = {
        "text": f"󰍏 {icon_str}",
        "tooltip": tooltip,
        "class": "active",
        "alt": str(count)
    }
    print(json.dumps(out))

if __name__ == "__main__":
    action = sys.argv[1] if len(sys.argv) > 1 else "toggle"
    if action == "minimize":
        minimize_active()
    elif action == "restore":
        addr = sys.argv[2] if len(sys.argv) > 2 else None
        restore_window(addr)
    elif action == "toggle":
        toggle()
    elif action == "menu":
        menu()
    elif action == "status":
        status()
    else:
        toggle()
