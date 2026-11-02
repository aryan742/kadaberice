-- ─────────────────────────────────────────────────────────────────
-- AryanOS — Keybindings & Native Window Management (Lua)
-- Native Hyprland Dispatchers (0ms Latency, 0 External Scripts)
-- ─────────────────────────────────────────────────────────────────

local mainMod = "SUPER"
local screenshot = "~/.config/hypr/scripts/screenshot.sh"
local osd = "~/.config/hypr/scripts/osd_control.sh"

-- ── Application Binds ────────────────────────────────────────────
hl.bind(mainMod .. " + Q",      hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("alacritty"))
hl.bind(mainMod .. " + E",      hl.dsp.exec_cmd("thunar"))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("rofi -show drun"))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exit())
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("wlogout || hyprctl dispatch exit"))

-- ── Window States & Manipulations ────────────────────────────────
hl.bind(mainMod .. " + V",         hl.dsp.exec_cmd("~/.config/hypr/scripts/clipboard.sh"))
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F",         hl.dsp.window.fullscreen(1))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen(0))
hl.bind(mainMod .. " + P",         hl.dsp.window.pseudo())
hl.bind(mainMod .. " + S",         hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + Y",         hl.dsp.exec_cmd("hyprctl dispatch pin"))               -- Pin floating window across workspaces
hl.bind(mainMod .. " + X",         hl.dsp.exec_cmd("hyprctl dispatch centerwindow"))      -- Center floating window on screen
hl.bind(mainMod .. " + B",         hl.dsp.exec_cmd("hyprctl dispatch focuscurrentorlast")) -- Toggle focus between current and last window

-- ── Native Window Grouping (Tabs) ────────────────────────────────
hl.bind(mainMod .. " + G",         hl.dsp.exec_cmd("hyprctl dispatch togglegroup"))       -- Group/Ungroup windows into tabs
hl.bind(mainMod .. " + ALT + Tab", hl.dsp.exec_cmd("hyprctl dispatch changegroupactive f")) -- Cycle forward through tabbed group

-- ── Focus Navigation (Vim + Arrow Keys) ──────────────────────────
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- ── Move Windows (Vim + Arrow Keys) ──────────────────────────────
hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.move({ direction = "down" }))

hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))

-- ── Resize Windows (Vim + Arrow Keys) ────────────────────────────
hl.bind(mainMod .. " + ALT + h",     hl.dsp.exec_cmd("hyprctl dispatch resizeactive -30 0"), { repeating = true })
hl.bind(mainMod .. " + ALT + l",     hl.dsp.exec_cmd("hyprctl dispatch resizeactive 30 0"),  { repeating = true })
hl.bind(mainMod .. " + ALT + k",     hl.dsp.exec_cmd("hyprctl dispatch resizeactive 0 -30"), { repeating = true })
hl.bind(mainMod .. " + ALT + j",     hl.dsp.exec_cmd("hyprctl dispatch resizeactive 0 30"),  { repeating = true })

hl.bind(mainMod .. " + ALT + left",  hl.dsp.exec_cmd("hyprctl dispatch resizeactive -30 0"), { repeating = true })
hl.bind(mainMod .. " + ALT + right", hl.dsp.exec_cmd("hyprctl dispatch resizeactive 30 0"),  { repeating = true })
hl.bind(mainMod .. " + ALT + up",    hl.dsp.exec_cmd("hyprctl dispatch resizeactive 0 -30"), { repeating = true })
hl.bind(mainMod .. " + ALT + down",  hl.dsp.exec_cmd("hyprctl dispatch resizeactive 0 30"),  { repeating = true })

-- ── Multi-Monitor & Scratchpad Controls ──────────────────────────
hl.bind(mainMod .. " + O",         hl.dsp.focus({ monitor = "+1" }))
hl.bind(mainMod .. " + SHIFT + O", hl.dsp.window.move({ monitor = "+1" }))

hl.bind(mainMod .. " + U",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + U", hl.dsp.window.move({ workspace = "special:magic" }))

-- ── Workspace Navigation & Hopping ───────────────────────────────
hl.bind(mainMod .. " + BackSpace",    hl.dsp.focus({ workspace = "previous" }))
hl.bind(mainMod .. " + N",            hl.dsp.focus({ workspace = "empty" }))
hl.bind(mainMod .. " + CTRL + right", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + CTRL + left",  hl.dsp.focus({ workspace = "e-1" }))

-- Switch workspaces with mainMod + [0-9] and move window with mainMod + SHIFT / CTRL + [0-9]
for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i,          hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i,  hl.dsp.window.move({ workspace = i }))
    hl.bind(mainMod .. " + CTRL + " .. i,   hl.dsp.window.move({ workspace = i, silent = true }))
end
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.window.move({ workspace = "empty" }))

-- ── Native Mouse Controls ────────────────────────────────────────
hl.bind(mainMod .. " + mouse:272",  hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273",  hl.dsp.window.resize(), { mouse = true })
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- ── Screenshot System ────────────────────────────────────────────
hl.bind("Print",                          hl.dsp.exec_cmd(screenshot .. " full"))
hl.bind(mainMod .. " + Print",            hl.dsp.exec_cmd(screenshot .. " region"))
hl.bind("SHIFT + Print",                  hl.dsp.exec_cmd(screenshot .. " window"))
hl.bind(mainMod .. " + SHIFT + Print",    hl.dsp.exec_cmd(screenshot .. " region-cb"))
hl.bind("CTRL + Print",                   hl.dsp.exec_cmd(screenshot .. " window-cb"))

-- ── Session & Tool Integrations ──────────────────────────────────
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind("ALT + Tab",               hl.dsp.exec_cmd("snappy-switcher next"))
hl.bind("ALT + SHIFT + Tab",       hl.dsp.exec_cmd("snappy-switcher prev"))

-- ── AGS Dashboard & Expo Overview ────────────────────────────────
hl.bind(mainMod .. " + Space",     hl.dsp.exec_cmd("~/.config/hypr/scripts/toggle-ags.sh app-launcher"))
hl.bind(mainMod .. " + Tab",       hl.dsp.exec_cmd("~/.config/hypr/scripts/toggle-ags.sh workspace-carousel"))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("~/.config/hypr/scripts/toggle-ags.sh wallpaper-carousel"))
hl.bind(mainMod .. " + grave", function()
    if hl.plugin and hl.plugin.hyprexpo and hl.plugin.hyprexpo.expo then
        hl.plugin.hyprexpo.expo("toggle")
    end
end)

-- ── Notification Controls (Dunst) ────────────────────────────────
hl.bind(mainMod .. " + Escape",         hl.dsp.exec_cmd("dunstctl close"))
hl.bind(mainMod .. " + SHIFT + Escape", hl.dsp.exec_cmd("dunstctl close-all"))
hl.bind(mainMod .. " + SHIFT + grave",  hl.dsp.exec_cmd("dunstctl history-pop"))

-- ── Presentation & Display Toggle ────────────────────────────────
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("~/.config/hypr/scripts/display_toggle.sh"))
hl.bind("XF86Display",             hl.dsp.exec_cmd("~/.config/hypr/scripts/display_toggle.sh"))

-- ── Multimedia & Hardware Keys (Native Audio & Brightness OSD) ────
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd(osd .. " vol_up"),    { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd(osd .. " vol_down"),  { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd(osd .. " vol_mute"),  { locked = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd(osd .. " mic_mute"),  { locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd(osd .. " bright_up"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(osd .. " bright_down"), { locked = true, repeating = true })
