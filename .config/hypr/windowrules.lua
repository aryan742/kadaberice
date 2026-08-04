-- ─────────────────────────────────────────────────────────────────
-- AryanOS — Intelligent Window Rules & Application Behavior (Lua)
-- Native Hyprland v0.55+ Engine
-- ─────────────────────────────────────────────────────────────────

-- ── 1. Manual Workspace Freedom ───────────────────────────────────
-- Applications open naturally on active workspace per user directive


-- ── 2. Dialogs & File Choosers ───────────────────────────────────
hl.window_rule({
    name  = "dialog-float-center",
    match = { title = "^(Open File|Save As|Select a File|Choose Files|File Upload|Save File|Confirm to replace files|File Operation Progress)$" },
    float = true,
    center = true,
})
hl.window_rule({
    name  = "dialog-size",
    match = { title = "^(Open File|Save As|Select a File|Choose Files|File Upload|Save File)$" },
    size  = "900 600",
})
hl.window_rule({
    name  = "portal-gtk-float",
    match = { class = "^(xdg-desktop-portal-gtk)$" },
    float = true,
})


-- ── 3. Authentication & Security Dialogs ─────────────────────────
hl.window_rule({
    name   = "auth-agent-rules",
    match  = { class = "^(polkit-kde-authentication-agent-1|org.kde.polkit-kde-authentication-agent-1|lxqt-policykit-agent)$" },
    float  = true,
    center = true,
    pin    = true,
})


-- ── 4. Picture-in-Picture (PiP) ───────────────────────────────────
hl.window_rule({
    name  = "pip-rules",
    match = { title = "^(Picture-in-Picture|Picture in Picture|Picture in picture)$" },
    float = true,
    pin   = true,
    size  = "640 360",
    move  = "100%-660 100%-380",
})


-- ── 5. System Utilities & Control Popups ─────────────────────────
hl.window_rule({
    name  = "sys-utils-float",
    match = { class = "^(pavucontrol|nm-connection-editor|blueman-manager|file-roller|org.gnome.FileRoller|gnome-calculator|org.gnome.Calculator|qalculate-gtk)$" },
    float = true,
})
hl.window_rule({
    name   = "pavucontrol-size-center",
    match  = { class = "^(pavucontrol)$" },
    size   = "800 600",
    center = true,
})
hl.window_rule({
    name   = "blueman-size-center",
    match  = { class = "^(blueman-manager)$" },
    size   = "700 500",
    center = true,
})
hl.window_rule({
    name   = "calculator-size-center",
    match  = { class = "^(gnome-calculator|org.gnome.Calculator|qalculate-gtk)$" },
    size   = "400 550",
    center = true,
})
hl.window_rule({
    name    = "audio-bt-opacity",
    match   = { class = "^(pavucontrol|blueman-manager)$" },
    opacity = "0.95 0.90",
})


-- ── 6. Media & Image Viewers ─────────────────────────────────────
hl.window_rule({
    name   = "image-viewers-float-center",
    match  = { class = "^(imv|viewnior|feh)$" },
    float  = true,
    center = true,
})


-- ── 7. Gaming Applications ───────────────────────────────────────
hl.window_rule({
    name  = "steam-popup-float",
    match = { class = "^(Steam)$", title = "^(Steam - News|Friends List|Settings)$" },
    float = true,
})
hl.window_rule({
    name  = "steam-main-tile",
    match = { class = "^(Steam)$", title = "^(Steam)$" },
    float = false,
})


-- ── 8. System Layer Rules (Glassmorphism & Blur) ──────────────────
hl.layer_rule({
    name  = "blur-waybar",
    match = { namespace = "waybar" },
    blur  = true,
})
hl.layer_rule({
    name  = "blur-dunst",
    match = { namespace = "dunst" },
    blur  = true,
})
