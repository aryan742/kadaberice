import Astal from "gi://Astal?version=3.0"
import Gtk from "gi://Gtk?version=3.0"
import Gdk from "gi://Gdk?version=3.0"
import GLib from "gi://GLib"
import Gio from "gi://Gio"

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

export default function WallpaperCarousel(app) {
    const window = new Astal.Window({
        name: "wallpaper-carousel",
        application: app,
        visible: false,
        keymode: Astal.Keymode.NONE,
        anchor: Astal.WindowAnchor.TOP | Astal.WindowAnchor.BOTTOM | Astal.WindowAnchor.LEFT | Astal.WindowAnchor.RIGHT,
        exclusivity: Astal.Exclusivity.IGNORE,
        layer: Astal.Layer.OVERLAY,
    })

    const categories = ["Hanuman", "Shiva", "Krishna", "Warriors", "Minimal", "Art"]
    let activeCategoryIndex = 0
    let activeIndex = 0
    let wallpapers = []

    function loadWallpapersForCategory(cat) {
        const dirPath = `/home/kadabe/Pictures/Wallpapers/${cat}`
        const dir = Gio.File.new_for_path(dirPath)
        const list = []
        try {
            const enumerator = dir.enumerate_children(
                "standard::name,standard::type",
                Gio.FileQueryInfoFlags.NONE,
                null
            )
            let info
            while ((info = enumerator.next_file(null)) !== null) {
                const name = info.get_name()
                const fileType = info.get_file_type()
                if (fileType === Gio.FileType.REGULAR &&
                    (name.endsWith(".jpg") || name.endsWith(".png") || name.endsWith(".jpeg"))) {
                    list.push(`${dirPath}/${name}`)
                }
            }
        } catch (e) {
            print("Error scanning category " + cat + ": " + e.message)
        }
        wallpapers = list
        activeIndex = 0
    }

    const box = Widget(Gtk.Box, { orientation: Gtk.Orientation.VERTICAL, halign: Gtk.Align.CENTER, valign: Gtk.Align.CENTER }, "fullscreen-overlay")

    // ── Top Nav Pill ──
    const topBar = Widget(Gtk.Box, { halign: Gtk.Align.CENTER, spacing: 16 }, "top-nav-bar")
    const navPill = Widget(Gtk.Box, { spacing: 4 }, "nav-pill")

    const btnLauncher   = Widget(Gtk.Button, { label: "󰀻 Launcher"   }, "nav-item")
    const btnWallpapers = Widget(Gtk.Button, { label: "󰸉 Wallpapers" }, "nav-item", "active")

    btnLauncher.connect("clicked",   () => globalThis.showWidget("app-launcher"))
    btnWallpapers.connect("clicked", () => globalThis.showWidget("wallpaper-carousel"))

    navPill.add(btnLauncher)
    navPill.add(btnWallpapers)

    const searchEntry = Widget(Gtk.Entry, { placeholder_text: "Search Apps...", width_request: 200 }, "search-pill-entry")
    const searchIcon  = new Gtk.Label({ label: "󰍉", margin_right: 8 })
    const searchBox   = Widget(Gtk.Box, { spacing: 4, valign: Gtk.Align.CENTER })
    searchBox.add(searchIcon)
    searchBox.add(searchEntry)
    navPill.add(searchBox)

    searchEntry.connect("changed", () => {
        const text = searchEntry.get_text()
        if (text !== "") {
            window.hide()
            globalThis.showWidget("app-launcher")
        }
    })

    topBar.add(navPill)

    // ── Category Ribbon ──
    const categoriesBox = Widget(Gtk.Box, { spacing: 10, halign: Gtk.Align.CENTER, margin_bottom: 16 })

    // ── Carousel ──
    const scroll = new Gtk.ScrolledWindow({
        vscrollbar_policy: Gtk.PolicyType.NEVER,
        hscrollbar_policy: Gtk.PolicyType.NEVER,
        hexpand: true
    })
    const carousel = Widget(Gtk.Box, { spacing: 0, halign: Gtk.Align.START }, "carousel-container")
    scroll.add(carousel)

    const bottomLabel = Widget(Gtk.Label, { label: "Wallpapers Gallery" }, "active-item-label")

    box.add(topBar)
    box.add(categoriesBox)
    box.add(scroll)
    box.add(bottomLabel)
    window.add(box)

    function renderCategories() {
        categoriesBox.get_children().forEach(c => c.destroy())
        categories.forEach((cat, idx) => {
            const btn = Widget(Gtk.Button, { label: cat }, "category-btn")
            if (idx === activeCategoryIndex) btn.get_style_context().add_class("active")
            btn.connect("clicked", () => {
                activeCategoryIndex = idx
                loadWallpapersForCategory(cat)
                renderCategories()
                renderCarousel(true)
            })
            categoriesBox.add(btn)
        })
        categoriesBox.show_all()
    }

    // Smooth lerp scroll animator
    let animId = 0
    function animateScrollTo(targetX) {
        const adj = scroll.get_hadjustment()
        if (animId > 0) {
            GLib.source_remove(animId)
            animId = 0
        }

        const duration = 180 // ms smooth fluid response
        const startTime = GLib.get_monotonic_time() / 1000
        const startX = adj.get_value()

        if (Math.abs(startX - targetX) < 0.5) {
            adj.set_value(targetX)
            return
        }

        animId = GLib.timeout_add(GLib.PRIORITY_HIGH, 16, () => {
            const now = GLib.get_monotonic_time() / 1000
            const elapsed = now - startTime
            const progress = Math.min(1.0, elapsed / duration)
            const ease = 1 - Math.pow(1 - progress, 3) // easeOutCubic

            const current = startX + (targetX - startX) * ease
            adj.set_value(current)

            if (progress >= 1.0) {
                animId = 0
                return GLib.SOURCE_REMOVE
            }
            return GLib.SOURCE_CONTINUE
        })
    }

    function createCardWidget(wpPath, absIdx) {
        const filename = wpPath.split("/").pop()
        const card = Widget(Gtk.Box, { orientation: Gtk.Orientation.VERTICAL }, "flow-card")

        // Active: full wallpaper preview
        const banner = Widget(Gtk.Box, {
            orientation: Gtk.Orientation.VERTICAL,
            valign: Gtk.Align.CENTER,
            halign: Gtk.Align.CENTER,
            hexpand: true,
            vexpand: true
        }, "card-banner", "wallpaper-img-box")
        setInlineStyle(banner, `
            * {
                background-image: url("${wpPath}");
                background-size: cover;
                background-position: center;
                background-repeat: no-repeat;
                min-width: 860px;
                min-height: 440px;
                border-radius: 16px;
            }
        `)

        // Inactive: thin slice showing edge of image
        const sliceBox = Widget(Gtk.Box, {
            orientation: Gtk.Orientation.VERTICAL,
            valign: Gtk.Align.CENTER,
            halign: Gtk.Align.CENTER,
            vexpand: true
        }, "side-slice", "wallpaper-img-box")
        setInlineStyle(sliceBox, `
            * {
                background-image: url("${wpPath}");
                background-size: cover;
                background-position: center;
                background-repeat: no-repeat;
                min-width: 60px;
                min-height: 380px;
                border-radius: 10px;
            }
        `)

        banner.show_all()
        sliceBox.show_all()
        banner.no_show_all = true
        sliceBox.no_show_all = true

        card.add(banner)
        card.add(sliceBox)

        card._banner   = banner
        card._sliceBox = sliceBox
        card._filename = filename
        card._wpPath   = wpPath
        card._wpIndex  = absIdx

        return card
    }

    let renderedStartIdx = -1
    let renderedEndIdx = -1

    function centerActiveCard(localActiveIndex) {
        const scrollWidth = scroll.get_allocated_width() || 1920
        const visualCenter = localActiveIndex * 68 + 544
        const targetX = visualCenter - scrollWidth / 2
        
        animateScrollTo(Math.max(0, targetX))
    }

    function updateCarouselActiveState(startIdx) {
        const children = carousel.get_children()
        if (children.length === 0) return
        const localActiveIndex = activeIndex - startIdx

        children.forEach((card, idx) => {
            const isCenter = (idx === localActiveIndex)
            const ctx = card.get_style_context()

            ctx.remove_class("active")
            ctx.remove_class("neighbor")

            if (isCenter) {
                ctx.add_class("active")
                if (card._banner)   card._banner.set_visible(true)
                if (card._sliceBox) card._sliceBox.set_visible(false)
                bottomLabel.set_text(card._filename || "Wallpaper")
            } else {
                if (idx === localActiveIndex - 1 || idx === localActiveIndex + 1) {
                    ctx.add_class("neighbor")
                }
                if (card._banner)   card._banner.set_visible(false)
                if (card._sliceBox) card._sliceBox.set_visible(true)
            }
        })

        centerActiveCard(localActiveIndex)
    }

    function renderCarousel(reset = false) {
        if (wallpapers.length === 0) {
            carousel.get_children().forEach(c => c.destroy())
            const card = Widget(Gtk.Box, { orientation: Gtk.Orientation.VERTICAL }, "flow-card", "active")
            const banner = Widget(Gtk.Box, { valign: Gtk.Align.CENTER, halign: Gtk.Align.CENTER }, "card-banner")
            banner.add(new Gtk.Label({ label: "No Wallpapers Found in Category" }))
            card.add(banner)
            carousel.add(card)
            carousel.show_all()
            renderedStartIdx = -1
            renderedEndIdx = -1
            return
        }

        const maxWindow = Math.min(10, wallpapers.length)
        let startIdx = Math.max(0, activeIndex - Math.floor(maxWindow / 2))
        let endIdx = startIdx + maxWindow - 1
        if (endIdx >= wallpapers.length) {
            endIdx = wallpapers.length - 1
            startIdx = Math.max(0, endIdx - maxWindow + 1)
        }

        if (reset || renderedStartIdx === -1 || Math.abs(startIdx - renderedStartIdx) >= maxWindow) {
            carousel.get_children().forEach(c => c.destroy())
            for (let i = startIdx; i <= endIdx; i++) {
                carousel.add(createCardWidget(wallpapers[i], i))
            }
            renderedStartIdx = startIdx
            renderedEndIdx = endIdx
            carousel.show_all()
        } else {
            // Incremental edge sliding
            while (renderedStartIdx < startIdx) {
                const children = carousel.get_children()
                if (children.length > 0) children[0].destroy()
                renderedStartIdx++
                renderedEndIdx++
                if (renderedEndIdx < wallpapers.length) {
                    const newCard = createCardWidget(wallpapers[renderedEndIdx], renderedEndIdx)
                    carousel.add(newCard)
                    newCard.show_all()
                }
            }
            while (renderedStartIdx > startIdx) {
                const children = carousel.get_children()
                if (children.length > 0) children[children.length - 1].destroy()
                renderedStartIdx--
                renderedEndIdx--
                if (renderedStartIdx >= 0) {
                    const newCard = createCardWidget(wallpapers[renderedStartIdx], renderedStartIdx)
                    carousel.pack_start(newCard, false, false, 0)
                    carousel.reorder_child(newCard, 0)
                    newCard.show_all()
                }
            }
        }

        updateCarouselActiveState(startIdx)
    }

    window.connect("scroll-event", (self, event) => {
        const [, direction] = event.get_scroll_direction()
        if (direction === Gdk.ScrollDirection.DOWN || direction === Gdk.ScrollDirection.RIGHT) {
            if (activeIndex < wallpapers.length - 1) {
                activeIndex++
                renderCarousel()
            }
            return true
        } else if (direction === Gdk.ScrollDirection.UP || direction === Gdk.ScrollDirection.LEFT) {
            if (activeIndex > 0) {
                activeIndex--
                renderCarousel()
            }
            return true
        }
        return false
    })

    // ── Keyboard ──
    window.connect("key-press-event", (self, event) => {
        const [, keyval] = event.get_keyval()
        const state = event.get_state()[1]
        const hasCtrl = (state & Gdk.ModifierType.CONTROL_MASK) !== 0
        const isEntryFocused = searchEntry.has_focus

        if (keyval === Gdk.KEY_Escape) { window.hide(); return true }

        if (hasCtrl) {
            if (keyval === Gdk.KEY_1) { globalThis.showWidget("app-launcher");       return true }
            if (keyval === Gdk.KEY_2) { globalThis.showWidget("workspace-carousel"); return true }
            if (keyval === Gdk.KEY_3) { globalThis.showWidget("wallpaper-carousel"); return true }
        }

        // Arrow keys always navigate
        if (keyval === Gdk.KEY_Left) {
            if (activeIndex > 0) { activeIndex--; renderCarousel() }
            return true
        }
        if (keyval === Gdk.KEY_Right) {
            if (activeIndex < wallpapers.length - 1) { activeIndex++; renderCarousel() }
            return true
        }
        if (keyval === Gdk.KEY_Up) {
            if (activeCategoryIndex > 0) {
                activeCategoryIndex--
                loadWallpapersForCategory(categories[activeCategoryIndex])
                renderCategories(); renderCarousel(true)
            }
            return true
        }
        if (keyval === Gdk.KEY_Down) {
            if (activeCategoryIndex < categories.length - 1) {
                activeCategoryIndex++
                loadWallpapersForCategory(categories[activeCategoryIndex])
                renderCategories(); renderCarousel(true)
            }
            return true
        }

        // Vim keys (h, l, j, k) only when search box is NOT focused, OR with Ctrl
        if (!isEntryFocused || hasCtrl) {
            if (keyval === Gdk.KEY_h) {
                if (activeIndex > 0) { activeIndex--; renderCarousel() }
                return true
            }
            if (keyval === Gdk.KEY_l) {
                if (activeIndex < wallpapers.length - 1) { activeIndex++; renderCarousel() }
                return true
            }
            if (keyval === Gdk.KEY_k) {
                if (activeCategoryIndex > 0) {
                    activeCategoryIndex--
                    loadWallpapersForCategory(categories[activeCategoryIndex])
                    renderCategories(); renderCarousel(true)
                }
                return true
            }
            if (keyval === Gdk.KEY_j) {
                if (activeCategoryIndex < categories.length - 1) {
                    activeCategoryIndex++
                    loadWallpapersForCategory(categories[activeCategoryIndex])
                    renderCategories(); renderCarousel(true)
                }
                return true
            }
        }
        if (keyval === Gdk.KEY_Return || keyval === Gdk.KEY_KP_Enter) {
            const selectedWp = wallpapers[activeIndex]
            if (selectedWp) {
                // Use waypaper CLI — it handles hyprpaper IPC correctly without killing the daemon
                GLib.spawn_command_line_async(`waypaper --wallpaper "${selectedWp}" --backend hyprpaper`)
                window.hide()
            }
            return true
        }

        return false
    })

    window.connect("button-press-event", (self, event) => {
        const children = carousel.get_children()
        children.forEach((card) => {
            const alloc = card.get_allocation()
            const [, ex, ey] = event.get_coords()
            const [ok, wx, wy] = card.translate_coordinates(window, 0, 0)
            if (ok && ex >= wx && ex <= wx + alloc.width && ey >= wy && ey <= wy + alloc.height) {
                const globalIdx = card._wpIndex
                if (globalIdx === activeIndex) {
                    const selectedWp = wallpapers[activeIndex]
                    if (selectedWp) {
                        GLib.spawn_command_line_async(`waypaper --wallpaper "${selectedWp}" --backend hyprpaper`)
                        window.hide()
                    }
                } else {
                    activeIndex = globalIdx
                    renderCarousel()
                }
            }
        })
        return false
    })

    window.connect("notify::visible", (self) => {
        if (self.visible) {
            self.keymode = Astal.Keymode.EXCLUSIVE
            searchEntry.set_text("")
            loadWallpapersForCategory(categories[activeCategoryIndex])
            renderCategories()
            renderCarousel(true)
            self.show()
        } else {
            self.keymode = Astal.Keymode.NONE
        }
    })

    return window
}
