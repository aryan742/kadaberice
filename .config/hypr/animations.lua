-- ─────────────────────────────────────────────────────────────────
-- AryanOS — Premium & Apple-Fluid Animations (Lua)
-- ─────────────────────────────────────────────────────────────────

hl.config({
    animations = {
        enabled = true,
    },
})

-- Fluid Expo Bezier Curves (Fast start, ultra-smooth deceleration)
hl.curve("fluidDecel",  { type = "bezier", points = { {0.16, 1}, {0.3, 1}  } })
hl.curve("quickIn",     { type = "bezier", points = { {0.7,  0}, {0.84, 0} } })
hl.curve("easeOutQuad", { type = "bezier", points = { {0.25, 1}, {0.5, 1}  } })

-- Window Transitions
hl.animation({ leaf = "windows",     enabled = true, speed = 3.5, bezier = "fluidDecel", style = "slide" })
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 3.5, bezier = "fluidDecel", style = "slide" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 3.0, bezier = "fluidDecel", style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 3.5, bezier = "fluidDecel" })

-- Fade Effects
hl.animation({ leaf = "fade",        enabled = true, speed = 3.0, bezier = "easeOutQuad" })
hl.animation({ leaf = "fadeIn",      enabled = true, speed = 2.5, bezier = "easeOutQuad" })
hl.animation({ leaf = "fadeOut",     enabled = true, speed = 2.5, bezier = "easeOutQuad" })
hl.animation({ leaf = "fadeSwitch",  enabled = true, speed = 3.5, bezier = "easeOutQuad" })

-- Layer Popups (Waybar, Dunst, Overlays)
hl.animation({ leaf = "layers",      enabled = true, speed = 3.0, bezier = "fluidDecel", style = "fade" })

-- Border & Active State Transitions
hl.animation({ leaf = "border",      enabled = true,  speed = 4.0, bezier = "easeOutQuad" })
hl.animation({ leaf = "borderangle", enabled = false, speed = 8.0, bezier = "easeOutQuad" }) -- No distracting spin animation

-- Workspace & Scratchpad slide
hl.animation({ leaf = "workspaces",       enabled = true, speed = 4.0, bezier = "fluidDecel", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3.5, bezier = "fluidDecel", style = "slidevert" })
