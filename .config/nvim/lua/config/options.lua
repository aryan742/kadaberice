-- ─────────────────────────────────────────────────────────────────────────────
-- lua/config/options.lua — Aryan Development Environment
-- Core Neovim options (applied before plugins load)
-- ─────────────────────────────────────────────────────────────────────────────

local opt = vim.opt

-- ── Leader keys ──────────────────────────────────────────────────────────────
vim.g.mapleader      = " "   -- Space is leader
vim.g.maplocalleader = "\\"  -- Backslash is local leader

-- ── Appearance ────────────────────────────────────────────────────────────────
opt.termguicolors   = true         -- 24-bit RGB colors
opt.number          = true         -- Show line numbers
opt.relativenumber  = true         -- Relative line numbers (easy motion)
opt.cursorline      = true         -- Highlight current line
opt.signcolumn      = "yes"        -- Always show sign column (no layout shift)
opt.colorcolumn     = "100"        -- Guide line at 100 chars
opt.showmode        = false        -- Mode shown in statusline (not cmdline)
opt.cmdheight       = 0           -- Hide cmdline when not in use
opt.laststatus      = 3           -- Global statusline (one bar for all splits)
opt.scrolloff       = 8           -- Keep 8 lines visible above/below cursor
opt.sidescrolloff   = 8           -- Keep 8 columns visible left/right
opt.wrap            = false        -- No line wrapping
opt.linebreak       = true         -- Wrap at word boundary (when wrap=true)
opt.conceallevel    = 1           -- Hide markup in Markdown (1 = partial)

-- ── Font (terminal reads this for GUI fallback) ───────────────────────────────
vim.g.gui_font_default_size = 12
vim.g.neovide_font_hinting  = "auto"  -- For neovide users

-- ── Indentation ───────────────────────────────────────────────────────────────
opt.tabstop     = 4    -- Tab = 4 spaces wide (display)
opt.shiftwidth  = 4    -- Indent = 4 spaces
opt.expandtab   = true -- Use spaces not tabs
opt.smartindent = true -- Auto-indent new lines
opt.shiftround  = true -- Round indent to shiftwidth multiple

-- ── Search ────────────────────────────────────────────────────────────────────
opt.ignorecase = true   -- Case-insensitive search
opt.smartcase  = true   -- … unless pattern contains uppercase
opt.hlsearch   = true   -- Highlight all matches
opt.incsearch  = true   -- Show matches while typing

-- ── Files & Buffers ───────────────────────────────────────────────────────────
opt.hidden      = true   -- Allow switching buffers without saving
opt.confirm     = true   -- Prompt before closing unsaved buffer
opt.backup      = false  -- No .bak files
opt.writebackup = false  -- No temp backup during write
opt.swapfile    = false  -- No .swp files (we have undo history)
opt.undofile    = true   -- Persistent undo history
opt.undolevels  = 10000  -- Deep undo history
opt.updatetime  = 200    -- Faster CursorHold events (LSP hover, etc.)
opt.timeoutlen  = 300    -- Key sequence timeout (ms)

-- ── Splits ────────────────────────────────────────────────────────────────────
opt.splitright = true   -- Vertical splits open to the right
opt.splitbelow = true   -- Horizontal splits open below

-- ── Completion ────────────────────────────────────────────────────────────────
opt.pumheight   = 10     -- Max items in popup menu
opt.completeopt = { "menu", "menuone", "noselect" }

-- ── Clipboard ─────────────────────────────────────────────────────────────────
opt.clipboard = "unnamedplus"   -- Use system clipboard (wl-clipboard on Wayland)

-- ── Terminal & Shell ──────────────────────────────────────────────────────────
opt.shell = "/bin/bash"

-- ── Folding (using nvim-ufo / treesitter) ─────────────────────────────────────
opt.foldlevel     = 99  -- Open all folds by default
opt.foldlevelstart = 99
opt.foldenable    = true

-- ── Spell ─────────────────────────────────────────────────────────────────────
opt.spelllang = { "en" }

-- ── Netrw (disabled — use neo-tree) ───────────────────────────────────────────
vim.g.loaded_netrw       = 1
vim.g.loaded_netrwPlugin = 1

-- ── Misc ──────────────────────────────────────────────────────────────────────
opt.virtualedit  = "block"    -- Allow cursor past EOL in visual block mode
opt.smoothscroll = true        -- Smooth scrolling (nvim 0.10+)
opt.list         = true        -- Show invisible characters
opt.listchars    = { tab = "» ", trail = "·", nbsp = "␣" }

-- ── Filetype-specific overrides (set per buffer via autocmds) ─────────────────
-- C / C++ use 4-space indent (set in autocmds.lua)
-- Python uses 4-space indent (PEP 8)
-- Lua uses 2-space indent
-- JS/TS use 2-space indent
