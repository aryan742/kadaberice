-- ─────────────────────────────────────────────────────────────────
-- AryanOS — Theme, Styling, & Color System Configuration (Lua)
-- ─────────────────────────────────────────────────────────────────

local colors_ok, dyn_colors = pcall(require, "colors")
local active_border_colors = colors_ok and { dyn_colors.primary, dyn_colors.secondary } or { "rgba(D97706ee)", "rgba(D4AF37ee)" }
local inactive_border_color = colors_ok and dyn_colors.surface or "rgba(1A1A1Aee)"

hl.config({
    general = {
        gaps_in     = 8,
        gaps_out    = 12,
        border_size = 2,
        
        col = {
            -- Dynamic Matugen gradient on active window border
            active_border   = { colors = active_border_colors, angle = 45 },
            -- Dynamic Matugen background on inactive windows
            inactive_border = inactive_border_color,
        },

        layout = "dwindle",

        -- Prevent accidental screen tearing
        allow_tearing = false,
    },

    decoration = {
        rounding = 10,

        active_opacity   = 1.0,
        inactive_opacity = 0.94,
        dim_special      = 0.3,

        -- Classic elegant drop shadow
        shadow = {
            enabled        = true,
            range          = 20,
            render_power   = 3,
            color          = "rgba(111111dd)",
            color_inactive = "rgba(11111166)",
        },

        -- Clean spiritual blur, highly optimized for performance (no lag)
        blur = {
            enabled           = true,
            size              = 8,
            passes            = 2,
            new_optimizations = true,
            xray              = false,
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
