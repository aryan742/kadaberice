#!/usr/bin/env python3
"""
AryanOS — Dynamic Notification Center & Waybar Module for Dunst
"""

import sys
import json
import subprocess
import os
from datetime import datetime

ROFI_THEME = os.path.expanduser("~/.config/rofi/notifications.rasi")

def get_dunst_status():
    try:
        is_paused = subprocess.check_output(["dunstctl", "is-paused"], stderr=subprocess.DEVNULL).decode().strip() == "true"
        hist_count_raw = subprocess.check_output(["dunstctl", "count", "history"], stderr=subprocess.DEVNULL).decode().strip()
        hist_count = int(hist_count_raw) if hist_count_raw.isdigit() else 0
        disp_count_raw = subprocess.check_output(["dunstctl", "count", "displayed"], stderr=subprocess.DEVNULL).decode().strip()
        disp_count = int(disp_count_raw) if disp_count_raw.isdigit() else 0
        total = hist_count + disp_count
    except Exception:
        is_paused = False
        total = 0

    if is_paused:
        text = "󰂛"
        tooltip = "Do Not Disturb is Active\nNotifications are muted\n• Left-click: Open Panel\n• Right-click: Resume Notifications"
        css_class = "dnd"
    elif total > 0:
        text = f"󰂚 {total}" if total < 100 else "󰂚 99+"
        tooltip = f"{total} notification(s) in history\n• Left-click: Open Notification Panel\n• Right-click: Toggle Mute (DND)\n• Middle-click: Clear History"
        css_class = "active"
    else:
        text = "󰂚"
        tooltip = "Notification Center\nNo unread notifications\n• Left-click: Open Panel\n• Right-click: Toggle Mute (DND)"
        css_class = "empty"

    print(json.dumps({"text": text, "tooltip": tooltip, "class": css_class}))


def open_notification_panel():
    try:
        raw = subprocess.check_output(["dunstctl", "history"], stderr=subprocess.DEVNULL).decode()
        data = json.loads(raw)
        notifs = data.get("data", [[]])[0]
    except Exception:
        notifs = []

    is_paused = False
    try:
        is_paused = subprocess.check_output(["dunstctl", "is-paused"], stderr=subprocess.DEVNULL).decode().strip() == "true"
    except Exception:
        pass

    menu_lines = []
    actions = {}

    dnd_label = "󰂚 Disable Do-Not-Disturb" if is_paused else "󰂛 Enable Do-Not-Disturb"
    menu_lines.append(dnd_label)
    actions[dnd_label] = ("toggle_dnd", None)

    if notifs:
        clear_label = f"󰃢 Clear All Notifications ({len(notifs)})"
        menu_lines.append(clear_label)
        actions[clear_label] = ("clear_all", None)
        menu_lines.append("──────────────────────────────────────────")
        actions["──────────────────────────────────────────"] = ("noop", None)

        for i, n in enumerate(notifs):
            app = n.get("appname", {}).get("data", "System")
            summary = n.get("summary", {}).get("data", "Notification")
            body = n.get("body", {}).get("data", "").replace("\n", " ")
            nid = n.get("id", {}).get("data", i)

            # Format entry
            entry_label = f"󰂚 [{app}] {summary}"
            if body:
                entry_label += f" — {body[:50]}..." if len(body) > 50 else f" — {body}"

            # Ensure unique key
            key = f"{entry_label}##{nid}##{i}"
            menu_lines.append(key)
            actions[key] = ("pop", nid)
    else:
        menu_lines.append("󰂚 No Recent Notifications")
        actions["󰂚 No Recent Notifications"] = ("noop", None)

    # Clean display labels without hashes
    display_entries = "\n".join([k.split("##")[0] for k in menu_lines])

    rofi_cmd = ["rofi", "-dmenu", "-p", "󰂚 Notifications", "-theme", ROFI_THEME]
    try:
        p = subprocess.Popen(rofi_cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=True)
        choice, _ = p.communicate(input=display_entries)
        choice = choice.strip()
    except Exception:
        return

    if not choice:
        return

    # Find matching action
    for key, (action_type, val) in actions.items():
        if key.split("##")[0] == choice:
            if action_type == "toggle_dnd":
                subprocess.run(["dunstctl", "set-paused", "toggle"])
            elif action_type == "clear_all":
                subprocess.run(["dunstctl", "history-clear"])
                subprocess.run(["dunstctl", "close-all"])
            elif action_type == "pop":
                # Pop notification onto screen
                subprocess.run(["dunstctl", "history-pop"])
            break


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--status":
        get_dunst_status()
    elif len(sys.argv) > 1 and sys.argv[1] == "--clear":
        subprocess.run(["dunstctl", "history-clear"])
        subprocess.run(["dunstctl", "close-all"])
    elif len(sys.argv) > 1 and sys.argv[1] == "--toggle-dnd":
        subprocess.run(["dunstctl", "set-paused", "toggle"])
    else:
        open_notification_panel()
