import Astal from "gi://Astal?version=3.0"
import Gtk from "gi://Gtk?version=3.0"
import Gdk from "gi://Gdk?version=3.0"
import GLib from "gi://GLib"
import Gio from "gi://Gio"
import Apps from "gi://AstalApps"

const BANNER_DIR = "/home/kadabe/Pictures/assets/Banners"

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

function findBannerPath(appName) {
    const name = (appName || "").toLowerCase()

    const bannerMap = {
        "antigravity ide": "antigravity_banner.png",
        "antigravity":     "antigravity_banner.png",
        "blender":         "blender_banner.png",
        "btop++":          "btop_banner.png",
        "btop":            "btop_banner.png",
        "dolphin":         "dolphin_banner.png",
        "gimp":            "gimp_banner.png",
        "gnu image manipulation program": "gimp_banner.png",
        "htop":            "htop_banner.png",
        "kitty":           "kitty_banner.png",
        "krita":           "krita_baneer.png",
        "neovim":          "neovim_banner.png",
        "nvim":            "neovim_banner.png",
        "obs":             "obs_banner.png",
        "obs studio":      "obs_banner.png",
        "thunar":          "thunar_banner.png",
        "thunar file manager": "thunar_banner.png",
        "vivaldi":         "vivaldi_banner.png",
        "zen browser":     "zen_browser_banner.png",
    }

    for (const [key, file] of Object.entries(bannerMap)) {
        if (name === key || name.includes(key) || key.includes(name)) {
            const fullPath = `${BANNER_DIR}/${file}`
            const f = Gio.File.new_for_path(fullPath)
            if (f.query_exists(null)) return fullPath
        }
    }

    const slug = name.replace(/[^a-z0-9]/g, "_").replace(/_+/g, "_").replace(/^_|_$/g, "")
    const candidates = [`${slug}_banner.png`, `${slug}_banner.jpeg`]
    for (const c of candidates) {
        const f = Gio.File.new_for_path(`${BANNER_DIR}/${c}`)
        if (f.query_exists(null)) return `${BANNER_DIR}/${c}`
    }

    return null
}

function getAppTheme(app) {
    const name = (app.name || "").toLowerCase()
    const exe  = (app.executable || "").toLowerCase()

    if (name.includes("obs") || exe.includes("obs"))
        return { category: "MEDIA" }
    else if (name.includes("spotify") || name.includes("music") || exe.includes("spotify"))
        return { category: "MUSIC" }
    else if (name.includes("steam") || name.includes("game") || name.includes("heroic") || name.includes("blender"))
        return { category: "GAME" }
    else if (name.includes("code") || name.includes("terminal") || name.includes("kitty") || name.includes("nvim") || name.includes("vim") || name.includes("neovim") || name.includes("btop") || name.includes("htop"))
        return { category: "DEV" }
    else if (name.includes("firefox") || name.includes("chrome") || name.includes("chromium") || name.includes("vivaldi") || name.includes("zen"))
        return { category: "NET" }
    else if (name.includes("gimp") || name.includes("krita") || name.includes("inkscape"))
        return { category: "GFX" }
    else
        return { category: "SYS" }
}

function isTerminalApp(app) {
    try {
        if (typeof app.get_is_terminal === "function") return app.get_is_terminal()
    } catch(_) {}
    const name = (app.name || "").toLowerCase()
    const exe  = (app.executable || "").toLowerCase()
    const terminalApps = ["htop", "btop", "nvim", "vim", "neovim", "ranger", "ncdu", "cava", "micro"]
    return terminalApps.some(t => name.includes(t) || exe.includes(t))
}

function launchApp(app) {
    if (isTerminalApp(app)) {
        let cmd = (app.executable || app.name || "").replace(/ %[fFuUdDnNickvm]/g, "").trim()
        if (!cmd) cmd = app.name.toLowerCase()
        GLib.spawn_command_line_async(`kitty --title "${app.name}" -e ${cmd}`)
    } else {
        app.launch()
    }
}

export default function AppLauncher(app) {
    const window = new Astal.Window({
        name: "app-launcher",
        application: app,
        visible: false,
        keymode: Astal.Keymode.NONE,
        anchor: Astal.WindowAnchor.TOP | Astal.WindowAnchor.BOTTOM | Astal.WindowAnchor.LEFT | Astal.WindowAnchor.RIGHT,
        exclusivity: Astal.Exclusivity.IGNORE,
        layer: Astal.Layer.OVERLAY,
    })

    const appsService = new Apps.Apps()
    let allApps = appsService.get_list().filter(a => a.name && !a.name.startsWith("xgps"))
    let appList = allApps
    let activeIndex = 0
    let lastActiveIndex = -1

    // ── Outer Fullscreen Box ──
    const box = Widget(Gtk.Box, {
        orientation: Gtk.Orientation.VERTICAL,
        halign: Gtk.Align.FILL,
        valign: Gtk.Align.FILL,
        hexpand: true,
        vexpand: true
    }, "fullscreen-overlay")

    // ── Top Nav Bar (Centered at Top) ──
    const topBar = Widget(Gtk.Box, {
        halign: Gtk.Align.CENTER,
        valign: Gtk.Align.START,
        spacing: 16,
        margin_top: 28,
        margin_bottom: 20,
        hexpand: true
    }, "top-nav-bar")

    const navPill = Widget(Gtk.Box, { spacing: 6, valign: Gtk.Align.CENTER }, "nav-pill")

    const btnLauncher   = Widget(Gtk.Button, { label: "󰀻 Launcher"   }, "nav-item", "active")
    const btnWallpapers = Widget(Gtk.Button, { label: "󰸉 Wallpapers" }, "nav-item")

    btnLauncher.connect("clicked",   () => globalThis.showWidget("app-launcher"))
    btnWallpapers.connect("clicked", () => globalThis.showWidget("wallpaper-carousel"))

    navPill.add(btnLauncher)
    navPill.add(btnWallpapers)

    const searchEntry = Widget(Gtk.Entry, { placeholder_text: "Search...", width_request: 180 }, "search-pill-entry")
    const searchIcon  = new Gtk.Label({ label: "󰍉", margin_right: 4 })
    const searchBox   = Widget(Gtk.Box, { spacing: 4, valign: Gtk.Align.CENTER, margin_left: 8 })
    searchBox.add(searchIcon)
    searchBox.add(searchEntry)
    navPill.add(searchBox)
    topBar.add(navPill)

    // ── Carousel Scrolled Window ──
    const scroll = new Gtk.ScrolledWindow({
        vscrollbar_policy: Gtk.PolicyType.NEVER,
        hscrollbar_policy: Gtk.PolicyType.NEVER,
        hexpand: true,
        vexpand: true,
        valign: Gtk.Align.CENTER
    })
    const carousel = Widget(Gtk.Box, { spacing: 0, halign: Gtk.Align.START, valign: Gtk.Align.CENTER }, "carousel-container")
    scroll.add(carousel)

    box.add(topBar)
    box.add(scroll)
    window.add(box)

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

        animId = GLib.timeout_add(GLib.PRIORITY_HIGH, 8, () => {
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

    function createCardWidget(app, absIdx) {
        const theme = getAppTheme(app)
        const card  = Widget(Gtk.Box, { orientation: Gtk.Orientation.VERTICAL }, "flow-card")
        const bannerImgPath = findBannerPath(app.name)

        const banner = Widget(Gtk.Box, {
            orientation: Gtk.Orientation.VERTICAL,
            valign: Gtk.Align.FILL,
            halign: Gtk.Align.FILL,
            hexpand: true,
            vexpand: true
        }, "card-banner")

        if (bannerImgPath) {
            setInlineStyle(banner, `
                * {
                    background-image: url("${bannerImgPath}");
                    background-size: cover;
                    background-position: center;
                    min-width: 800px;
                    min-height: 450px;
                    border-radius: 16px;
                }
            `)

            const bottomOverlay = Widget(Gtk.Box, {
                orientation: Gtk.Orientation.HORIZONTAL,
                valign: Gtk.Align.END,
                halign: Gtk.Align.FILL,
                hexpand: true,
            }, "card-bottom-overlay")

            const centerSpacer = Widget(Gtk.Box, { hexpand: true })
            const rightSpacer  = Widget(Gtk.Box, { hexpand: true })

            const namePill = Widget(Gtk.Box, { halign: Gtk.Align.CENTER }, "card-name-pill")
            namePill.add(new Gtk.Label({ label: app.name }))

            const badgeBox = Widget(Gtk.Box, { halign: Gtk.Align.END, valign: Gtk.Align.CENTER }, "category-badge")
            badgeBox.add(new Gtk.Label({ label: theme.category }))

            bottomOverlay.add(centerSpacer)
            bottomOverlay.add(namePill)
            bottomOverlay.add(rightSpacer)
            bottomOverlay.add(badgeBox)

            banner.add(bottomOverlay)

        } else {
            setInlineStyle(banner, `* { min-width: 800px; min-height: 450px; }`)

            const inner = Widget(Gtk.Box, {
                orientation: Gtk.Orientation.VERTICAL,
                valign: Gtk.Align.CENTER,
                halign: Gtk.Align.CENTER,
                spacing: 16,
                hexpand: true,
                vexpand: true
            })

            let icon
            try {
                icon = new Gtk.Image({ icon_name: app.icon_name || "application-x-executable", pixel_size: 110 })
            } catch(e) {
                icon = new Gtk.Image({ icon_name: "application-x-executable", pixel_size: 110 })
            }

            const iconContainer = Widget(Gtk.Box, { halign: Gtk.Align.CENTER }, "app-icon-container")
            iconContainer.add(icon)

            const titleLabel = Widget(Gtk.Label, { label: app.name, halign: Gtk.Align.CENTER }, "app-title")

            inner.add(iconContainer)
            inner.add(titleLabel)

            const bottomOverlay = Widget(Gtk.Box, {
                orientation: Gtk.Orientation.HORIZONTAL,
                valign: Gtk.Align.END,
                halign: Gtk.Align.FILL,
                hexpand: true,
            }, "card-bottom-overlay")

            const badgeBox = Widget(Gtk.Box, { halign: Gtk.Align.END, valign: Gtk.Align.CENTER }, "category-badge")
            badgeBox.add(new Gtk.Label({ label: theme.category }))

            bottomOverlay.add(new Gtk.Box({ hexpand: true }))
            bottomOverlay.add(badgeBox)

            banner.add(inner)
            banner.add(bottomOverlay)
        }

        const sliceBox = Widget(Gtk.Box, {
            orientation: Gtk.Orientation.VERTICAL,
            valign: Gtk.Align.FILL,
            halign: Gtk.Align.FILL,
            hexpand: true,
            vexpand: true
        }, "side-slice")

        if (bannerImgPath) {
            setInlineStyle(sliceBox, `
                * {
                    background-image: url("${bannerImgPath}");
                    background-size: cover;
                    background-position: center;
                    min-width: 85px;
                    min-height: 450px;
                    border-radius: 12px;
                }
            `)
        } else {
            setInlineStyle(sliceBox, `
                * {
                    background-color: rgba(22, 20, 26, 0.9);
                    min-width: 85px;
                    min-height: 450px;
                    border-radius: 12px;
                }
            `)
        }

        const sideBadgeBox = Widget(Gtk.Box, { halign: Gtk.Align.CENTER, valign: Gtk.Align.END, vexpand: true }, "side-badge")
        sideBadgeBox.add(new Gtk.Label({ label: theme.category }))
        sliceBox.add(sideBadgeBox)

        banner.show_all()
        sliceBox.show_all()
        banner.no_show_all = true
        sliceBox.no_show_all = true

        card.add(banner)
        card.add(sliceBox)

        card._banner   = banner
        card._sliceBox = sliceBox
        card._appName  = app.name
        card._app      = app
        card._appIndex = absIdx

        return card
    }

    let renderedStartIdx = -1
    let renderedEndIdx = -1

    function centerActiveCard(localActiveIndex) {
        const scrollWidth = scroll.get_allocated_width() || 1920
        const visualCenter = localActiveIndex * 93 + 544
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
        if (appList.length === 0) {
            carousel.get_children().forEach(c => c.destroy())
            const card = Widget(Gtk.Box, { orientation: Gtk.Orientation.VERTICAL }, "flow-card", "active")
            const banner = Widget(Gtk.Box, { valign: Gtk.Align.CENTER, halign: Gtk.Align.CENTER }, "card-banner")
            banner.add(new Gtk.Label({ label: "No Applications Found" }))
            card.add(banner)
            carousel.add(card)
            carousel.show_all()
            renderedStartIdx = -1
            renderedEndIdx = -1
            return
        }

        const maxWindow = Math.min(10, appList.length)
        let startIdx = Math.max(0, activeIndex - Math.floor(maxWindow / 2))
        let endIdx = startIdx + maxWindow - 1
        if (endIdx >= appList.length) {
            endIdx = appList.length - 1
            startIdx = Math.max(0, endIdx - maxWindow + 1)
        }

        if (reset || renderedStartIdx === -1 || Math.abs(startIdx - renderedStartIdx) >= maxWindow) {
            carousel.get_children().forEach(c => c.destroy())
            for (let i = startIdx; i <= endIdx; i++) {
                carousel.add(createCardWidget(appList[i], i))
            }
            renderedStartIdx = startIdx
            renderedEndIdx = endIdx
            carousel.show_all()
        } else {
            // Incremental edge sliding: push new edge card and drop old opposite edge card without resetting carousel
            while (renderedStartIdx < startIdx) {
                const children = carousel.get_children()
                if (children.length > 0) children[0].destroy()
                renderedStartIdx++
                renderedEndIdx++
                if (renderedEndIdx < appList.length) {
                    const newCard = createCardWidget(appList[renderedEndIdx], renderedEndIdx)
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
                    const newCard = createCardWidget(appList[renderedStartIdx], renderedStartIdx)
                    carousel.pack_start(newCard, false, false, 0)
                    carousel.reorder_child(newCard, 0)
                    newCard.show_all()
                }
            }
        }

        updateCarouselActiveState(startIdx)
    }

    renderCarousel(true)

    window.connect("scroll-event", (self, event) => {
        const [, direction] = event.get_scroll_direction()
        if (direction === Gdk.ScrollDirection.DOWN || direction === Gdk.ScrollDirection.RIGHT) {
            if (activeIndex < appList.length - 1) {
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

    window.connect("key-press-event", (self, event) => {
        const [, keyval] = event.get_keyval()

        if (keyval === Gdk.KEY_Escape) { window.hide(); return true }

        if (keyval === Gdk.KEY_Left || keyval === Gdk.KEY_h) {
            if (activeIndex > 0) {
                activeIndex--
                renderCarousel()
            }
            return true
        }
        if (keyval === Gdk.KEY_Right || keyval === Gdk.KEY_l) {
            if (activeIndex < appList.length - 1) {
                activeIndex++
                renderCarousel()
            }
            return true
        }
        if (keyval === Gdk.KEY_Return || keyval === Gdk.KEY_KP_Enter) {
            const activeApp = appList[activeIndex]
            if (activeApp) {
                launchApp(activeApp)
                window.hide()
            }
            return true
        }

        return false
    })

    searchEntry.connect("changed", () => {
        const query = searchEntry.get_text().toLowerCase().trim()
        appList = query === ""
            ? allApps
            : allApps.filter(a =>
                (a.name        && a.name.toLowerCase().includes(query)) ||
                (a.description && a.description.toLowerCase().includes(query))
            )
        activeIndex = 0
        renderCarousel(true)
    })

    window.connect("button-press-event", (self, event) => {
        const children = carousel.get_children()
        children.forEach((card) => {
            const alloc = card.get_allocation()
            const [, ex, ey] = event.get_coords()
            const [ok, wx, wy] = card.translate_coordinates(window, 0, 0)
            if (ok && ex >= wx && ex <= wx + alloc.width && ey >= wy && ey <= wy + alloc.height) {
                const globalIdx = card._appIndex
                if (globalIdx === activeIndex) {
                    const activeApp = appList[activeIndex]
                    if (activeApp) { launchApp(activeApp); window.hide() }
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
            activeIndex = 0
            renderCarousel(true)
            GLib.idle_add(GLib.PRIORITY_DEFAULT_IDLE, () => {
                searchEntry.grab_focus()
                return false
            })
        } else {
            self.keymode = Astal.Keymode.NONE
        }
    })

    return window
}
