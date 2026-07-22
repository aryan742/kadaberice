import Astal from "gi://Astal?version=3.0"
import Gio from "gi://Gio"
import Gtk from "gi://Gtk?version=3.0"
import Gdk from "gi://Gdk?version=3.0"
import GLib from "gi://GLib"

import AppLauncher from "./widgets/AppLauncher.js"
import WallpaperCarousel from "./widgets/WallpaperCarousel.js"

Gtk.init(null)

// Load style
const provider = new Gtk.CssProvider()
provider.load_from_path("/home/kadabe/.config/ags/styles/main.css")
Gtk.StyleContext.add_provider_for_screen(Gdk.Screen.get_default(), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)

// Initialize Windows
const appLauncher = AppLauncher(null)
const wallpaperCarousel = WallpaperCarousel(null)

// Global Helper to switch between dashboards dynamically
globalThis.showWidget = (name) => {
    appLauncher.hide()
    wallpaperCarousel.hide()

    if (name === "app-launcher") {
        appLauncher.show_all()
        appLauncher.present()
    } else if (name === "wallpaper-carousel") {
        wallpaperCarousel.show_all()
        wallpaperCarousel.present()
    }
}

// Socket IPC for Hyprland binding execution
const socketPath = "/tmp/ags_carousel.sock"
try { Gio.File.new_for_path(socketPath).delete(null) } catch(e) {}

const service = new Gio.SocketService()
service.add_address(Gio.UnixSocketAddress.new(socketPath), Gio.SocketType.STREAM, Gio.SocketProtocol.DEFAULT, null)
service.connect("incoming", (svc, conn) => {
    const stream = new Gio.DataInputStream({ base_stream: conn.get_input_stream() })
    const [line] = stream.read_line_utf8(null)
    if (!line) return false
    
    const target = line.trim()
    if (target === "app-launcher") {
        if (appLauncher.get_visible()) {
            appLauncher.hide()
        } else {
            globalThis.showWidget("app-launcher")
        }
    } else if (target === "wallpaper-carousel") {
        if (wallpaperCarousel.get_visible()) {
            wallpaperCarousel.hide()
        } else {
            globalThis.showWidget("wallpaper-carousel")
        }
    }
    
    return false
})
service.start()

print("✅ AGS Daemon is running in the background with Socket IPC!")

const loop = new GLib.MainLoop(null, false)
loop.run()
