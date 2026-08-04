-- ─────────────────────────────────────────────────────────────────
-- AryanOS — Theme, Styling, & Color System Configuration (Lua)
-- ─────────────────────────────────────────────────────────────────

hl.config({
    general = {
        gaps_in     = 8,
        gaps_out    = 12,
        border_size = 2,
        
        col = {
            -- Elegant Saffron-to-Gold gradient on active window border
            active_border   = { colors = {"rgba(D97706ee)", "rgba(D4AF37ee)"}, angle = 45 },
            -- Deep minimalist secondary background on inactive windows
            inactive_border = "rgba(1A1A1Aee)",
        },

        layout = "dwindle",

        -- Prevent accidental screen tearing
        allow_tearing = false,
    },

    decoration = {
        rounding = 6,

        active_opacity   = 1.0,
        inactive_opacity = 0.94,
        dim_special      = 0.3,

        -- Classic elegant drop shadow
        shadow = {
            enabled        = true,
            range          = 15,
            render_power   = 3,
            color          = "rgba(111111dd)",
            color_inactive = "rgba(11111166)",
        },

        -- Clean spiritual blur, highly optimized for performance (no lag)
        blur = {
            enabled           = true,
            size              = 6,
            passes            = 2,
            new_optimizations = true,
            xray              = true,
            ignore_opacity    = true,
        },
    },

    dwindle = {
        preserve_split = true,
        smart_split    = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper  = 0,
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        mouse_move_enables_dpms  = true,
        key_press_enables_dpms   = true,
        background_color         = 0x111111,
    },
})

-- Workspace Layout Rules & Gestures
hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})
