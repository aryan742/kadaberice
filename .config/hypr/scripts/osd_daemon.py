#!/usr/bin/env python3
import os
import sys
import socket
import gi

gi.require_version("Gtk", "3.0")
gi.require_version("Gdk", "3.0")
gi.require_version("GtkLayerShell", "0.1")

from gi.repository import Gtk, Gdk, GtkLayerShell, GLib, Gio

SOCKET_PATH = "/tmp/aryanos_osd.sock"
CSS_PATH = os.path.expanduser("~/.config/hypr/styles/osd.css")

class AudioOSDWindow(Gtk.Window):
    def __init__(self):
        super().__init__(type=Gtk.WindowType.TOPLEVEL)
        self.set_name("osd-window")
        self.hide_timer = None
        
        # Animation properties
        self.anim_id = None
        self.target_opacity = 0.0
        self.target_margin = 12
        self.current_opacity = 0.0
        self.current_margin = 12
        self.is_visible = False

        # Setup Layer Shell
        GtkLayerShell.init_for_window(self)
        GtkLayerShell.set_namespace(self, "osd")
        GtkLayerShell.set_layer(self, GtkLayerShell.Layer.OVERLAY)
        GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.TOP, True)
        GtkLayerShell.set_margin(self, GtkLayerShell.Edge.TOP, 12)
        GtkLayerShell.set_keyboard_mode(self, GtkLayerShell.KeyboardMode.NONE)
        GtkLayerShell.set_exclusive_zone(self, -1)

        # UI Container (320px x 56px, 18px corner radius)
        self.box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=0)
        self.box.set_name("osd-container")
        self.box.set_size_request(320, 56)
        self.add(self.box)

        # Icon Label (18px monochrome symbolic)
        self.icon_label = Gtk.Label(label="󰕾")
        self.icon_label.set_name("osd-icon")
        self.icon_label.set_valign(Gtk.Align.CENTER)
        self.box.pack_start(self.icon_label, False, False, 0)

        # Thin Rounded Progress Bar
        self.progress = Gtk.ProgressBar()
        self.progress.set_name("osd-progress")
        self.progress.set_valign(Gtk.Align.CENTER)
        self.box.pack_start(self.progress, True, True, 0)

        # Text Label (centered, for microphone active/muted)
        self.text_label = Gtk.Label(label="")
        self.text_label.set_name("osd-text")
        self.text_label.set_valign(Gtk.Align.CENTER)
        self.box.pack_start(self.text_label, True, True, 0)

        # Value Label (13px Inter Medium)
        self.value_label = Gtk.Label(label="50%")
        self.value_label.set_name("osd-value")
        self.value_label.set_valign(Gtk.Align.CENTER)
        self.box.pack_start(self.value_label, False, False, 0)

        self.load_css()
        self.set_opacity(0.0)
        self.show_all()
        self.hide()

    def load_css(self):
        if os.path.exists(CSS_PATH):
            try:
                provider = Gtk.CssProvider()
                provider.load_from_path(CSS_PATH)
                Gtk.StyleContext.add_provider_for_screen(
                    Gdk.Screen.get_default(),
                    provider,
                    Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
                )
            except Exception as e:
                print("CSS load warning:", e)

    def show_osd(self, icon, val_pct, text_val, mode="standard"):
        # Update layout elements based on active mode
        self.icon_label.set_text(icon)
        
        if mode == "standard":
            self.progress.set_visible(True)
            self.value_label.set_visible(True)
            self.text_label.set_visible(False)
            self.progress.set_fraction(max(0.0, min(1.0, val_pct / 100.0)))
            self.value_label.set_text(text_val)
        else: # mic mode
            self.progress.set_visible(False)
            self.value_label.set_visible(False)
            self.text_label.set_visible(True)
            self.text_label.set_text(text_val)

        # Handle animations and window showing
        if not self.is_visible:
            self.is_visible = True
            self.show_all()
            self.animate_to(1.0, 32, 150) # Fade in + slide down over 150ms
        else:
            # Already fully visible, reset dismissal timer and skip transition
            self.set_opacity(1.0)
            GtkLayerShell.set_margin(self, GtkLayerShell.Edge.TOP, 32)
            self.current_opacity = 1.0
            self.current_margin = 32

        # Reset 900ms auto-dismiss timer
        if self.hide_timer:
            GLib.source_remove(self.hide_timer)
        self.hide_timer = GLib.timeout_add(900, self.trigger_hide)

    def trigger_hide(self):
        self.animate_to(0.0, 12, 200) # Fade out + slide up over 200ms
        GLib.timeout_add(200, self.finish_hide)
        self.hide_timer = None
        return False

    def finish_hide(self):
        if not self.hide_timer: # Confirm no new event interrupted the hide
            self.hide()
            self.is_visible = False
        return False

    def animate_to(self, target_opacity, target_margin, duration_ms):
        if self.anim_id:
            GLib.source_remove(self.anim_id)
            self.anim_id = None

        steps = max(1, duration_ms // 16)
        step_opacity = (target_opacity - self.current_opacity) / steps
        step_margin = (target_margin - self.current_margin) / steps
        current_step = 0

        def anim_step():
            nonlocal current_step
            if current_step < steps:
                self.current_opacity += step_opacity
                self.current_margin += step_margin
                self.set_opacity(max(0.0, min(1.0, self.current_opacity)))
                GtkLayerShell.set_margin(self, GtkLayerShell.Edge.TOP, int(self.current_margin))
                current_step += 1
                return True
            else:
                self.current_opacity = target_opacity
                self.current_margin = target_margin
                self.set_opacity(max(0.0, min(1.0, self.current_opacity)))
                GtkLayerShell.set_margin(self, GtkLayerShell.Edge.TOP, int(self.current_margin))
                self.anim_id = None
                return False

        self.anim_id = GLib.timeout_add(16, anim_step)


def start_ipc_server(osd_win):
    if os.path.exists(SOCKET_PATH):
        try:
            os.remove(SOCKET_PATH)
        except OSError:
            pass

    server = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    server.bind(SOCKET_PATH)
    server.listen(5)

    def handle_client(source, condition):
        conn, _ = server.accept()
        data = conn.recv(1024).decode("utf-8").strip()
        conn.close()

        if data:
            parts = data.split()
            cmd = parts[0]

            if cmd == "volume":
                val = int(parts[1])
                muted = int(parts[2]) == 1
                if muted:
                    osd_win.show_osd("󰖁", 0, "Muted", mode="standard")
                else:
                    icon = "󰕾" if val > 50 else ("󰖀" if val > 0 else "󰕿")
                    osd_win.show_osd(icon, val, f"{val}%", mode="standard")

            elif cmd == "brightness":
                val = int(parts[1])
                osd_win.show_osd("󰃠", val, f"{val}%", mode="standard")

            elif cmd == "mic":
                muted = int(parts[1]) == 1
                if muted:
                    osd_win.show_osd("󰍭", 0, "Microphone Muted", mode="mic")
                else:
                    osd_win.show_osd("󰍬", 100, "Microphone Active", mode="mic")

        return True

    GLib.io_add_watch(server.fileno(), GLib.IO_IN, handle_client)


def main():
    app = AudioOSDWindow()
    start_ipc_server(app)
    Gtk.main()

if __name__ == "__main__":
    main()
