-- ─────────────────────────────────────────────────────────────────
-- AryanOS — Autostart Processes & Daemons (Lua)
-- ─────────────────────────────────────────────────────────────────

hl.on("hyprland.start", function()
    -- Portal & DBus Environment (PipeWire Screen Sharing)
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

    -- Polkit (Authentication UI agent)
    hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")

    -- Desktop Status Bar, Idle Daemon & UI
    hl.exec_cmd("waybar")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("gjs -m ~/.config/ags/app.js")
    hl.exec_cmd("python3 ~/.config/hypr/scripts/osd_daemon.py")

    -- Notifications Daemon
    hl.exec_cmd("dunst")

    -- Clipboard History (wl-clipboard & cliphist integration)
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    -- Wallpaper Setup
    hl.exec_cmd("waypaper --restore")

    -- Window Switcher (Snappy Switcher)
    hl.exec_cmd("snappy-switcher --daemon")

    -- Hyprland Plugins (hyprpm reload & auto-recovery)
    hl.exec_cmd("~/.config/hypr/scripts/hyprpm-auto-update.sh &")

    -- Cursor & Theme Integration
    hl.exec_cmd("hyprctl setcursor Bibata-Modern-Ice 24")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Ice'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-size 24")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface gtk-theme 'Colloid-Dark'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface icon-theme 'BeautyLine'")
end)
