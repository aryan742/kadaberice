-- ─────────────────────────────────────────────────────────────────
-- AryanOS — Hyprland Plugins Configuration (Lua)
-- ─────────────────────────────────────────────────────────────────

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
            on_double_click = "hyprctl eval 'hl.dispatch(hl.dsp.window.fullscreen(1))'",
        },
    },
})

-- Register Titlebar Buttons: Close (Red), Fullscreen (Green), Minimize (Yellow)
if hl.plugin and hl.plugin.hyprbars and hl.plugin.hyprbars.add_button then
    hl.plugin.hyprbars.add_button({
        bg_color = "rgb(ff5555)",
        fg_color = "rgb(12131a)",
        size = 11,
        icon = "󰖭",
        action = "hyprctl eval 'hl.dispatch(hl.dsp.window.close())'"
    })
    hl.plugin.hyprbars.add_button({
        bg_color = "rgb(50fa7b)",
        fg_color = "rgb(12131a)",
        size = 11,
        icon = "󰍉",
        action = "hyprctl eval 'hl.dispatch(hl.dsp.window.fullscreen(1))'"
    })
    hl.plugin.hyprbars.add_button({
        bg_color = "rgb(f1fa8c)",
        fg_color = "rgb(12131a)",
        size = 11,
        icon = "󰍏",
        action = "python3 ~/.config/hypr/scripts/minimize.py minimize"
    })
end
