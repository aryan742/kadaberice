-- ─────────────────────────────────────────────────────────────────
-- AryanOS — Hyprland Plugins Configuration (Lua)
-- ─────────────────────────────────────────────────────────────────
-- NOTE: hyprexpo plugin config is ready but the plugin itself is not
-- loaded here via plugins.lua — it must be loaded via hyprpm.
-- Run the install commands below first, then uncomment the plugin block.
--
-- ── INSTALL COMMANDS (run in terminal as user, NOT root) ──────────
--   sudo pacman -S cmake
--   hyprpm update
--   hyprpm add https://github.com/hyprwm/hyprland-plugins
--   hyprpm enable hyprexpo
--   hyprpm reload
--
-- ── AFTER INSTALLATION, uncomment below ──────────────────────────

hl.config({
    plugin = {
        hyprexpo = {
            columns = 3,
            gaps_in = 10,
            gaps_out = 15,
            bg_col = "rgba(0, 0, 0, 0.85)",
            workspace_method = "center current",
        },
        hyprbars = {
            bar_height = 24,
            bar_color = "rgba(18, 19, 26, 0.95)",
            ["col.text"] = "rgb(205, 214, 244)",
            bar_text_size = 10,
            bar_text_font = "JetBrainsMono Nerd Font",
            bar_text_align = "left",
            bar_buttons_alignment = "right",
            bar_padding = 10,
            bar_button_padding = 8,
            on_double_click = "hyprctl dispatch fullscreen 1",

            -- 3 Titlebar Buttons: Close (Red), Fullscreen (Green), Minimize (Yellow)
            ["hyprbars-button"] = {
                "rgb(ff5555), 10, 󰖭, hyprctl dispatch killactive",
                "rgb(50fa7b), 10, 󰍉, hyprctl dispatch fullscreen 1",
                "rgb(f1fa8c), 10, 󰍏, ~/.config/hypr/scripts/minimize.sh minimize",
            },
        },
    },
})


