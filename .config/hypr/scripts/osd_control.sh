#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# AryanOS — Audio & Brightness Hardware Control & OSD Dispatcher
# Performs underlying system state changes AND triggers Top-Center OSD
# ─────────────────────────────────────────────────────────────────────────────

SOCKET_PATH="/tmp/aryanos_osd.sock"
DAEMON_SCRIPT="$HOME/.config/hypr/scripts/osd_daemon.py"

# Native Python IPC helper (0 dependencies, self-healing autostart)
send_ipc() {
    local msg="$1"
    python3 -c "
import socket, sys, os, time, subprocess

sock_path = '$SOCKET_PATH'
msg = '$msg'.encode('utf-8')

def try_connect():
    try:
        s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        s.connect(sock_path)
        s.sendall(msg)
        s.close()
        return True
    except Exception:
        return False

if not try_connect():
    # Autostart daemon detached if not running
    script = os.path.expanduser('$DAEMON_SCRIPT')
    subprocess.Popen(['python3', script], start_new_session=True)
    time.sleep(0.2)
    try_connect()
" 2>/dev/null || true
}

ACTION="$1"

case "$ACTION" in
    vol_up)
        wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+
        RAW=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
        VOL=$(python3 -c "import sys; line='$RAW'.split(); print(int(float(line[1])*100))" 2>/dev/null || echo "50")
        MUTED=$(echo "$RAW" | grep -q "MUTED" && echo "1" || echo "0")
        send_ipc "volume $VOL $MUTED"
        ;;

    vol_down)
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
        RAW=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
        VOL=$(python3 -c "import sys; line='$RAW'.split(); print(int(float(line[1])*100))" 2>/dev/null || echo "50")
        MUTED=$(echo "$RAW" | grep -q "MUTED" && echo "1" || echo "0")
        send_ipc "volume $VOL $MUTED"
        ;;

    vol_mute)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        RAW=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
        VOL=$(python3 -c "import sys; line='$RAW'.split(); print(int(float(line[1])*100))" 2>/dev/null || echo "50")
        MUTED=$(echo "$RAW" | grep -q "MUTED" && echo "1" || echo "0")
        send_ipc "volume $VOL $MUTED"
        ;;

    bright_up)
        brightnessctl set 5%+ >/dev/null 2>&1
        CUR=$(brightnessctl get 2>/dev/null || echo "50")
        MAX=$(brightnessctl max 2>/dev/null || echo "100")
        PCT=$(( CUR * 100 / MAX ))
        send_ipc "brightness $PCT"
        ;;

    bright_down)
        brightnessctl set 5%- >/dev/null 2>&1
        CUR=$(brightnessctl get 2>/dev/null || echo "50")
        MAX=$(brightnessctl max 2>/dev/null || echo "100")
        PCT=$(( CUR * 100 / MAX ))
        send_ipc "brightness $PCT"
        ;;

    mic_mute)
        wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
        RAW=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@)
        MUTED=$(echo "$RAW" | grep -q "MUTED" && echo "1" || echo "0")
        send_ipc "mic $MUTED"
        ;;

    *)
        echo "Usage: osd_control.sh [vol_up|vol_down|vol_mute|bright_up|bright_down|mic_mute]"
        exit 1
        ;;
esac
