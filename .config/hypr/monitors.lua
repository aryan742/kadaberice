-- ─────────────────────────────────────────────────────────────────
-- AryanOS — Monitors & Workspace Bindings Configuration (Lua)
-- ─────────────────────────────────────────────────────────────────

-- Primary Internal Laptop Display
hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1080@60",
    position = "0x0",
    scale    = "1",
})

-- Presentation Mode: Auto-mirror any connected Projector/External Monitor onto eDP-1
hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "auto", scale = "1", mirror = "eDP-1" })
hl.monitor({ output = "HDMI-A-2", mode = "preferred", position = "auto", scale = "1", mirror = "eDP-1" })
hl.monitor({ output = "DP-1",     mode = "preferred", position = "auto", scale = "1", mirror = "eDP-1" })
hl.monitor({ output = "DP-2",     mode = "preferred", position = "auto", scale = "1", mirror = "eDP-1" })

-- Fallback for any other external monitor output
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "1", mirror = "eDP-1" })

-- Default Workspace Rules (Assigned to primary monitor)
hl.workspace_rule({ workspace = "1", monitor = "eDP-1", default = true })
hl.workspace_rule({ workspace = "2", monitor = "eDP-1" })
hl.workspace_rule({ workspace = "3", monitor = "eDP-1" })
hl.workspace_rule({ workspace = "4", monitor = "eDP-1" })
hl.workspace_rule({ workspace = "5", monitor = "eDP-1" })
hl.workspace_rule({ workspace = "6", monitor = "eDP-1" })
hl.workspace_rule({ workspace = "7", monitor = "eDP-1" })
hl.workspace_rule({ workspace = "8", monitor = "eDP-1" })
hl.workspace_rule({ workspace = "9", monitor = "eDP-1" })
