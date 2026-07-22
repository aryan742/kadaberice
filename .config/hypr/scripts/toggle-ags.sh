#!/usr/bin/env python3
import socket, sys, subprocess, time, os

target = sys.argv[1] if len(sys.argv) > 1 else "app-launcher"
socket_path = "/tmp/ags_carousel.sock"

def send_ipc():
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as s:
        s.connect(socket_path)
        s.sendall((target + "\n").encode())

try:
    send_ipc()
except Exception:
    app_path = os.path.expanduser("~/.config/ags/app.js")
    subprocess.Popen(["gjs", "-m", app_path])
    time.sleep(0.3)
    try:
        send_ipc()
    except Exception as e:
        print("Error sending IPC to AGS:", e)

