-- ─────────────────────────────────────────────────────────────────────────────
-- lua/config/autocmds.lua — Aryan Development Environment
-- Auto-commands for filetype behaviour and quality-of-life
-- ─────────────────────────────────────────────────────────────────────────────

local function augroup(name)
  return vim.api.nvim_create_augroup("aryan_" .. name, { clear = true })
end

-- ── Highlight yanked text ─────────────────────────────────────────────────────
vim.api.nvim_create_autocmd("TextYankPost", {
  group    = augroup("highlight_yank"),
  callback = function() vim.highlight.on_yank({ timeout = 200 }) end,
})

-- ── Resize splits when window is resized ─────────────────────────────────────
vim.api.nvim_create_autocmd("VimResized", {
  group    = augroup("resize_splits"),
  callback = function() vim.cmd("tabdo wincmd =") end,
})

-- ── Go to last location when reopening a file ────────────────────────────────
vim.api.nvim_create_autocmd("BufReadPost", {
  group    = augroup("last_location"),
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- ── Close certain filetypes with 'q' ─────────────────────────────────────────
vim.api.nvim_create_autocmd("FileType", {
  group   = augroup("close_with_q"),
  pattern = {
    "PlenaryTestPopup", "help", "lspinfo", "man", "notify",
    "qf", "query", "spectre_panel", "startuptime",
    "tsplayground", "neotest-output", "checkhealth",
    "neotest-summary", "neotest-output-panel",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = event.buf, silent = true })
  end,
})

-- ── Auto-create parent directories on save ────────────────────────────────────
vim.api.nvim_create_autocmd("BufWritePre", {
  group    = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+://") then return end
    local file = vim.loop.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- ── Filetype: C / C++ ─────────────────────────────────────────────────────────
vim.api.nvim_create_autocmd("FileType", {
  group   = augroup("c_cpp"),
  pattern = { "c", "cpp", "h", "hpp" },
  callback = function()
    vim.opt_local.tabstop    = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab  = true
    vim.opt_local.commentstring = "// %s"
  end,
})

-- ── Filetype: Rust ────────────────────────────────────────────────────────────
vim.api.nvim_create_autocmd("FileType", {
  group   = augroup("rust"),
  pattern = "rust",
  callback = function()
    vim.opt_local.tabstop    = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab  = true
  end,
})

-- ── Filetype: Lua ─────────────────────────────────────────────────────────────
vim.api.nvim_create_autocmd("FileType", {
  group   = augroup("lua"),
  pattern = "lua",
  callback = function()
    vim.opt_local.tabstop    = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab  = true
  end,
})

-- ── Filetype: JavaScript / TypeScript ─────────────────────────────────────────
vim.api.nvim_create_autocmd("FileType", {
  group   = augroup("js_ts"),
  pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact", "json" },
  callback = function()
    vim.opt_local.tabstop    = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab  = true
  end,
})

-- ── Filetype: Python ─────────────────────────────────────────────────────────
vim.api.nvim_create_autocmd("FileType", {
  group   = augroup("python"),
  pattern = "python",
  callback = function()
    vim.opt_local.tabstop    = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab  = true
    vim.opt_local.colorcolumn = "79,100"  -- PEP8 soft limit at 79
  end,
})

-- ── Filetype: Bash / Shell ────────────────────────────────────────────────────
vim.api.nvim_create_autocmd("FileType", {
  group   = augroup("shell"),
  pattern = { "sh", "bash", "zsh" },
  callback = function()
    vim.opt_local.tabstop    = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab  = true
  end,
})

-- ── Filetype: Makefile (tabs required) ────────────────────────────────────────
vim.api.nvim_create_autocmd("FileType", {
  group   = augroup("makefile"),
  pattern = "make",
  callback = function()
    vim.opt_local.expandtab = false  -- Makefiles MUST use real tabs
    vim.opt_local.tabstop   = 4
  end,
})

-- ── Auto-format on save (for supported filetypes) ─────────────────────────────
-- Actual formatting is handled by conform.nvim (configured in plugins/coding.lua)
-- This autocmd is a fallback trigger if conform is not active
vim.api.nvim_create_autocmd("BufWritePre", {
  group    = augroup("auto_format_fallback"),
  pattern  = { "*.lua" },
  callback = function()
    if not pcall(require, "conform") then
      vim.lsp.buf.format({ async = false, timeout_ms = 1000 })
    end
  end,
})

-- ── Check if file changed outside nvim ───────────────────────────────────────
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group    = augroup("checktime"),
  callback = function()
    if vim.o.buftype ~= "nofile" then vim.cmd("checktime") end
  end,
})
