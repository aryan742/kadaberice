import Astal from "gi://Astal?version=3.0"
import Gtk from "gi://Gtk?version=3.0"
import Gdk from "gi://Gdk?version=3.0"
import GLib from "gi://GLib"
import Gio from "gi://Gio"
import Hyprland from "gi://AstalHyprland"

function Widget(type, props, ...classes) {
    const w = new type(props)
    classes.forEach(c => w.get_style_context().add_class(c))
    return w
}

function setInlineStyle(widget, cssString) {
    try {
        const provider = new Gtk.CssProvider()
        provider.load_from_data(cssString)
        widget.get_style_context().add_provider(provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)
    } catch (e) {
        print("Error setting inline style:", e.message)
    }
}

// Helper to find dominant active app per workspace
function getDominantAppForWorkspace(hypr, wsId) {
    // If the active window is on this workspace, return it
    const active = hypr.get_focused_client()
    if (active && active.workspace && active.workspace.id === wsId) {
        return active
    }
    // Otherwise return first client on this workspace
    const clients = hypr.get_clients().filter(c => c.workspace && c.workspace.id === wsId)
    return clients.length > 0 ? clients[0] : null
}

export default function WorkspaceCarousel(app) {
    const window = new Astal.Window({
        name: "workspace-carousel",
        application: app,
        visible: false,
        keymode: Astal.Keymode.NONE, // Safe initialize
        anchor: Astal.WindowAnchor.TOP | Astal.WindowAnchor.BOTTOM | Astal.WindowAnchor.LEFT | Astal.WindowAnchor.RIGHT,
        exclusivity: Astal.Exclusivity.IGNORE,
        layer: Astal.Layer.OVERLAY,
    })

    const hypr = Hyprland.get_default()
    let activeIndex = 0 // Represents focused card (workspace index 0-8 for workspaces 1-9)
    const totalWorkspaces = 9
    
    // ── Screenshot Caching System ──
    let captureTimeout = null;
    function captureCurrentWorkspace() {
        const ws = hypr.get_focused_workspace()
        if (!ws) return
        
        // Ensure /tmp/ags-workspaces exists
        try {
            Gio.File.new_for_path("/tmp/ags-workspaces").make_directory_with_parents(null)
        } catch (e) {}

        const path = `/tmp/ags-workspaces/ws_${ws.id}.jpg`
        // We use grim to capture the current screen to a cache path
        GLib.spawn_command_line_async(`grim -t jpeg -q 50 ${path}`)
    }

    function scheduleCapture() {
        if (captureTimeout) {
            GLib.source_remove(captureTimeout)
        }
        // Wait 600ms for hyprland animations to finish before taking picture
        captureTimeout = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 600, () => {
            // Only capture if switcher is NOT visible (we don't want to screenshot the switcher itself)
            if (!window.get_visible()) {
                captureCurrentWorkspace()
            }
            captureTimeout = null
            return false
        })
    }

    hypr.connect("notify::focused-workspace", scheduleCapture)
    hypr.connect("client-added", scheduleCapture)
    hypr.connect("client-removed", scheduleCapture)

    function syncActiveWorkspace() {
        const focused = hypr.get_focused_workspace()
        if (focused) {
            activeIndex = Math.min(Math.max(focused.id - 1, 0), totalWorkspaces - 1)
        }
    }

    const box = Widget(Gtk.Box, { orientation: Gtk.Orientation.VERTICAL, halign: Gtk.Align.CENTER, valign: Gtk.Align.CENTER }, "fullscreen-overlay")

    // ── Unified Top Navigation Pill ──
    const topBar = Widget(Gtk.Box, { halign: Gtk.Align.CENTER, spacing: 16, margin_bottom: 24 }, "top-nav-bar")
    const navPill = Widget(Gtk.Box, { spacing: 4 }, "nav-pill")

    const btnLauncher = Widget(Gtk.Button, { label: "󰀻 Launcher" }, "nav-item")
    const btnWorkspaces = Widget(Gtk.Button, { label: "󰨇 Workspaces" }, "nav-item", "active")
    const btnWallpapers = Widget(Gtk.Button, { label: "󰸉 Wallpapers" }, "nav-item")

    btnLauncher.connect("clicked", () => globalThis.showWidget("app-launcher"))
    btnWorkspaces.connect("clicked", () => globalThis.showWidget("workspace-carousel"))
    btnWallpapers.connect("clicked", () => globalThis.showWidget("wallpaper-carousel"))

    navPill.add(btnLauncher)
    navPill.add(btnWorkspaces)
    navPill.add(btnWallpapers)
    topBar.add(navPill)

    // ── CoverFlow Carousel ──
    const scroll = new Gtk.ScrolledWindow({ 
        vscrollbar_policy: Gtk.PolicyType.NEVER, 
        hscrollbar_policy: Gtk.PolicyType.NEVER,
        hexpand: true
    })
    const carousel = Widget(Gtk.Box, { spacing: 0, halign: Gtk.Align.CENTER }, "carousel-container")
    scroll.add(carousel)

    box.add(topBar)
    box.add(scroll)
    window.add(box)

    function centerActiveCard() {
        const children = carousel.get_children()
        if (children.length === 0) return

        const activeCard = children[activeIndex]
        if (!activeCard) return

        const adj = scroll.get_hadjustment()
        GLib.timeout_add(GLib.PRIORITY_DEFAULT, 30, () => {
            const alloc = activeCard.get_allocation()
            const scrollAlloc = scroll.get_allocation()
            if (alloc.width > 1 && scrollAlloc.width > 1) {
                const target = alloc.x - (scrollAlloc.width - alloc.width) / 2
                adj.set_value(target)
            }
            return false
        })
    }

    function renderCarousel() {
        carousel.get_children().forEach(c => c.destroy())

        for (let idx = 0; idx < totalWorkspaces; idx++) {
            const wsNum = idx + 1
            const card = Widget(Gtk.Box, { orientation: Gtk.Orientation.VERTICAL }, "flow-card", "workspace-screenshot")
            
            const imagePath = `/tmp/ags-workspaces/ws_${wsNum}.jpg`
            // Force CSS reload by appending timestamp cache buster
            const time = new Date().getTime()
            setInlineStyle(card, `* { background-image: url("${imagePath}?t=${time}"); }`)

            // Darkening overlay (for inactive states)
            const overlay = Widget(Gtk.Box, { 
                orientation: Gtk.Orientation.VERTICAL, 
                hexpand: true, 
                vexpand: true 
            }, "workspace-overlay", "ws-info-container")

            // Top-left: Workspace Number watermark
            const numLabel = Widget(Gtk.Label, { 
                label: wsNum.toString(), 
                halign: Gtk.Align.START,
                valign: Gtk.Align.START
            }, "ws-number")

            // Bottom-left: App Details
            const infoBox = Widget(Gtk.Box, { orientation: Gtk.Orientation.VERTICAL, halign: Gtk.Align.START, valign: Gtk.Align.END })
            
            const titleLabel = Widget(Gtk.Label, { 
                label: `Workspace ${wsNum}`, 
                halign: Gtk.Align.START 
            }, "ws-title")
            infoBox.add(titleLabel)

            const domApp = getDominantAppForWorkspace(hypr, wsNum)
            if (domApp && domApp.class) {
                const appPill = Widget(Gtk.Box, { spacing: 8, valign: Gtk.Align.CENTER, halign: Gtk.Align.START }, "ws-app-pill")
                const appLabel = Widget(Gtk.Label, { label: domApp.class }, "ws-app-label")
                appPill.add(appLabel)
                infoBox.add(appPill)
            }

            overlay.add(numLabel)
            overlay.add(infoBox)
            card.add(overlay)

            // Stash references
            card._wsNum = wsNum

            carousel.add(card)
        }

        carousel.show_all()
        updateCarouselActiveState()
    }

    function updateCarouselActiveState() {
        const children = carousel.get_children()
        if (children.length === 0) return

        children.forEach((card, idx) => {
            const ctx = card.get_style_context()
            
            // Remove existing state classes
            ctx.remove_class("active")
            ctx.remove_class("neighbor")

            if (idx === activeIndex) {
                ctx.add_class("active")
            } else if (idx === activeIndex - 1 || idx === activeIndex + 1) {
                ctx.add_class("neighbor")
            }
        })

        centerActiveCard()
    }

    // Keyboard handlers
    window.connect("key-press-event", (self, event) => {
        const [, keyval] = event.get_keyval()
        const state = event.get_state()[1]

        // Escape to hide
        if (keyval === Gdk.KEY_Escape) {
            window.hide()
            return true
        }

        // Ctrl + Number switches
        if ((state & Gdk.ModifierType.CONTROL_MASK) !== 0) {
            if (keyval === Gdk.KEY_1) { globalThis.showWidget("app-launcher"); return true; }
            if (keyval === Gdk.KEY_2) { globalThis.showWidget("workspace-carousel"); return true; }
            if (keyval === Gdk.KEY_3) { globalThis.showWidget("wallpaper-carousel"); return true; }
        }

        // Navigation (Left/Right)
        if (keyval === Gdk.KEY_Left || keyval === Gdk.KEY_h) {
            if (activeIndex > 0) {
                activeIndex--
                updateCarouselActiveState()
            }
            return true
        }
        if (keyval === Gdk.KEY_Right || keyval === Gdk.KEY_l) {
            if (activeIndex < totalWorkspaces - 1) {
                activeIndex++
                updateCarouselActiveState()
            }
            return true
        }

        // Enter to Dispatch Switch Workspace
        if (keyval === Gdk.KEY_Return || keyval === Gdk.KEY_KP_Enter) {
            const wsNum = activeIndex + 1
            hypr.dispatch("workspace", wsNum.toString())
            window.hide()
            return true
        }

        return false
    })

    window.connect("notify::visible", (self) => {
        if (self.visible) {
            self.keymode = Astal.Keymode.EXCLUSIVE
            syncActiveWorkspace()
            renderCarousel()
            self.show_all()
        } else {
            self.keymode = Astal.Keymode.NONE
        }
    })

    return window
}
