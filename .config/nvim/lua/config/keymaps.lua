-- ─────────────────────────────────────────────────────────────────────────────
-- lua/config/keymaps.lua — Aryan Development Environment
-- Custom keybindings (LazyVim defaults are inherited — only additions here)
-- ─────────────────────────────────────────────────────────────────────────────

local map = vim.keymap.set

-- ── Helper ───────────────────────────────────────────────────────────────────
local function desc(d) return { desc = d, noremap = true, silent = true } end

-- ─────────────────────────────────────────────────────────────────────────────
-- GENERAL
-- ─────────────────────────────────────────────────────────────────────────────

-- Clear search highlights
map("n", "<Esc>",      "<cmd>nohlsearch<CR>",           desc("Clear search highlights"))

-- Save file
map({ "n", "i", "v" }, "<C-s>", "<cmd>w<CR><Esc>",     desc("Save file"))

-- Quit
map("n", "<leader>q",  "<cmd>q<CR>",                   desc("Quit window"))
map("n", "<leader>Q",  "<cmd>qa!<CR>",                 desc("Force quit all"))

-- Better up/down (respect wrapped lines)
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Stay in indent mode after visual indent
map("v", "<", "<gv", desc("Indent left (stay selected)"))
map("v", ">", ">gv", desc("Indent right (stay selected)"))

-- Move lines up/down (Alt+j/k)
map("n", "<A-j>", "<cmd>m .+1<CR>==",         desc("Move line down"))
map("n", "<A-k>", "<cmd>m .-2<CR>==",         desc("Move line up"))
map("v", "<A-j>", ":m '>+1<CR>gv=gv",         desc("Move selection down"))
map("v", "<A-k>", ":m '<-2<CR>gv=gv",         desc("Move selection up"))

-- ─────────────────────────────────────────────────────────────────────────────
-- BUFFERS
-- ─────────────────────────────────────────────────────────────────────────────
map("n", "<S-h>",      "<cmd>bprevious<CR>",           desc("Prev buffer"))
map("n", "<S-l>",      "<cmd>bnext<CR>",               desc("Next buffer"))
map("n", "<leader>bd", "<cmd>bdelete<CR>",             desc("Delete buffer"))
map("n", "<leader>bD", "<cmd>bdelete!<CR>",            desc("Force delete buffer"))
map("n", "<leader>bo", "<cmd>%bd|e#|bd#<CR>",         desc("Close all other buffers"))

-- ─────────────────────────────────────────────────────────────────────────────
-- WINDOWS / SPLITS
-- ─────────────────────────────────────────────────────────────────────────────
map("n", "<leader>wv", "<cmd>vsplit<CR>",              desc("Split vertical"))
map("n", "<leader>wh", "<cmd>split<CR>",               desc("Split horizontal"))
map("n", "<leader>wc", "<cmd>close<CR>",               desc("Close window"))
map("n", "<C-h>",      "<C-w>h",                      desc("Move to left window"))
map("n", "<C-j>",      "<C-w>j",                      desc("Move to lower window"))
map("n", "<C-k>",      "<C-w>k",                      desc("Move to upper window"))
map("n", "<C-l>",      "<C-w>l",                      desc("Move to right window"))
-- Resize windows
map("n", "<C-Up>",     "<cmd>resize +2<CR>",           desc("Increase window height"))
map("n", "<C-Down>",   "<cmd>resize -2<CR>",           desc("Decrease window height"))
map("n", "<C-Left>",   "<cmd>vertical resize -2<CR>",  desc("Decrease window width"))
map("n", "<C-Right>",  "<cmd>vertical resize +2<CR>",  desc("Increase window width"))

-- ─────────────────────────────────────────────────────────────────────────────
-- FILE / SEARCH (Telescope)
-- ─────────────────────────────────────────────────────────────────────────────
map("n", "<leader>ff", "<cmd>Telescope find_files<CR>",                      desc("Find files"))
map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>",                       desc("Grep search"))
map("n", "<leader>fw", "<cmd>Telescope grep_string<CR>",                     desc("Grep word under cursor"))
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>",                         desc("Find buffers"))
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>",                       desc("Find help"))
map("n", "<leader>fr", "<cmd>Telescope oldfiles<CR>",                        desc("Recent files"))
map("n", "<leader>fc", "<cmd>Telescope colorscheme<CR>",                     desc("Colorschemes"))
map("n", "<leader>fk", "<cmd>Telescope keymaps<CR>",                         desc("Find keymaps"))
map("n", "<leader>fd", "<cmd>Telescope diagnostics<CR>",                     desc("Find diagnostics"))
map("n", "<leader>fs", "<cmd>Telescope lsp_document_symbols<CR>",            desc("Document symbols"))
map("n", "<leader>fS", "<cmd>Telescope lsp_workspace_symbols<CR>",           desc("Workspace symbols"))
map("n", "<leader>fp", "<cmd>Telescope projects<CR>",                        desc("Projects"))
-- Quick file finding (no leader needed)
map("n", "<C-p>",      "<cmd>Telescope find_files<CR>",                      desc("Find files (Ctrl+P)"))

-- ─────────────────────────────────────────────────────────────────────────────
-- FILE EXPLORER (neo-tree)
-- ─────────────────────────────────────────────────────────────────────────────
map("n", "<leader>e",  "<cmd>Neotree toggle<CR>",                            desc("Toggle file explorer"))
map("n", "<leader>E",  "<cmd>Neotree reveal<CR>",                            desc("Reveal file in explorer"))
map("n", "<leader>be", "<cmd>Neotree buffers reveal float<CR>",              desc("Buffer explorer"))

-- ─────────────────────────────────────────────────────────────────────────────
-- LSP (most are set by LazyVim on_attach — these are global supplements)
-- ─────────────────────────────────────────────────────────────────────────────
map("n", "<leader>li", "<cmd>LspInfo<CR>",                                   desc("LSP info"))
map("n", "<leader>lr", "<cmd>LspRestart<CR>",                                desc("LSP restart"))
map("n", "<leader>ll", "<cmd>LspLog<CR>",                                    desc("LSP log"))
-- (LazyVim already provides: gd, gr, K, <leader>ca, <leader>rn, [d, ]d)

-- ─────────────────────────────────────────────────────────────────────────────
-- DIAGNOSTICS
-- ─────────────────────────────────────────────────────────────────────────────
map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>",                desc("Diagnostics (Trouble)"))
map("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>",   desc("Buffer diagnostics"))
map("n", "<leader>xl", "<cmd>Trouble loclist toggle<CR>",                    desc("Location list"))
map("n", "<leader>xq", "<cmd>Trouble qflist toggle<CR>",                     desc("Quickfix list"))
map("n", "]d",         vim.diagnostic.goto_next,                             desc("Next diagnostic"))
map("n", "[d",         vim.diagnostic.goto_prev,                             desc("Prev diagnostic"))

-- ─────────────────────────────────────────────────────────────────────────────
-- GIT (LazyGit + Gitsigns)
-- ─────────────────────────────────────────────────────────────────────────────
map("n", "<leader>gg", "<cmd>LazyGit<CR>",                                   desc("LazyGit"))
map("n", "<leader>gf", "<cmd>Telescope git_files<CR>",                       desc("Git files"))
map("n", "<leader>gc", "<cmd>Telescope git_commits<CR>",                     desc("Git commits"))
map("n", "<leader>gb", "<cmd>Telescope git_branches<CR>",                    desc("Git branches"))
map("n", "<leader>gs", "<cmd>Telescope git_status<CR>",                      desc("Git status"))
-- (LazyVim + gitsigns provide: ]c, [c, <leader>gh hunk nav/stage/reset)

-- ─────────────────────────────────────────────────────────────────────────────
-- TERMINAL (toggleterm / LazyVim built-in)
-- ─────────────────────────────────────────────────────────────────────────────
map("n", "<leader>th", "<cmd>ToggleTerm direction=horizontal<CR>",           desc("Terminal (horizontal)"))
map("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical<CR>",             desc("Terminal (vertical)"))
map("n", "<leader>tf", "<cmd>ToggleTerm direction=float<CR>",                desc("Terminal (float)"))
map("n", "<C-\\>",     "<cmd>ToggleTerm<CR>",                                desc("Toggle terminal"))
-- Exit terminal mode easily
map("t", "<Esc><Esc>", "<C-\\><C-n>",                                        desc("Exit terminal mode"))
map("t", "<C-h>",      "<cmd>wincmd h<CR>",                                  desc("Terminal: move left"))
map("t", "<C-j>",      "<cmd>wincmd j<CR>",                                  desc("Terminal: move down"))
map("t", "<C-k>",      "<cmd>wincmd k<CR>",                                  desc("Terminal: move up"))
map("t", "<C-l>",      "<cmd>wincmd l<CR>",                                  desc("Terminal: move right"))

-- ─────────────────────────────────────────────────────────────────────────────
-- C / C++ SPECIFIC
-- ─────────────────────────────────────────────────────────────────────────────
map("n", "<leader>ch", "<cmd>ClangdSwitchSourceHeader<CR>",                  desc("C/C++: switch .h/.cpp"))

-- ─────────────────────────────────────────────────────────────────────────────
-- RUST SPECIFIC
-- ─────────────────────────────────────────────────────────────────────────────
map("n", "<leader>rc", "<cmd>RustLsp openCargo<CR>",                         desc("Rust: open Cargo.toml"))
map("n", "<leader>rr", "<cmd>RustLsp runnables<CR>",                         desc("Rust: runnables"))
map("n", "<leader>rd", "<cmd>RustLsp debuggables<CR>",                       desc("Rust: debuggables"))
map("n", "<leader>re", "<cmd>RustLsp expandMacro<CR>",                       desc("Rust: expand macro"))

-- ─────────────────────────────────────────────────────────────────────────────
-- FORMATTING
-- ─────────────────────────────────────────────────────────────────────────────
map({ "n", "v" }, "<leader>lf", function() require("conform").format({ async = true }) end, desc("Format buffer"))

-- ─────────────────────────────────────────────────────────────────────────────
-- MISC UTILITIES
-- ─────────────────────────────────────────────────────────────────────────────
map("n", "<leader>un", "<cmd>Noice dismiss<CR>",                             desc("Dismiss notifications"))
map("n", "<leader>ur", "<cmd>nohlsearch<bar>diffupdate<bar>normal! <C-L><CR>", desc("Redraw screen"))
-- Copy relative file path
map("n", "<leader>cp", '<cmd>let @+ = expand("%:.")<CR>',                   desc("Copy relative file path"))
-- Toggle word wrap
map("n", "<leader>uw", "<cmd>set wrap!<CR>",                                 desc("Toggle word wrap"))
-- Open lazy.nvim UI
map("n", "<leader>pl", "<cmd>Lazy<CR>",                                      desc("Lazy plugin manager"))
-- Open Mason
map("n", "<leader>pm", "<cmd>Mason<CR>",                                     desc("Mason LSP installer"))
