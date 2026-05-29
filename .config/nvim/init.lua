-- ─────────────────────────────────────────────────────────────────────────────
-- init.lua — Aryan Development Environment
-- LazyVim Bootstrap (official method: https://www.lazyvim.org/installation)
-- ─────────────────────────────────────────────────────────────────────────────

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "--branch=stable",
    lazyrepo, lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to continue..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Load options, keymaps, and autocmds before lazy setup
require("config.options")
require("config.keymaps")
require("config.autocmds")

-- Setup lazy.nvim + LazyVim
require("lazy").setup({
  spec = {
    -- Import LazyVim and its default plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- Language extras (LazyVim official extras)
    { import = "lazyvim.plugins.extras.lang.clangd" },
    { import = "lazyvim.plugins.extras.lang.rust" },
    { import = "lazyvim.plugins.extras.lang.python" },
    { import = "lazyvim.plugins.extras.lang.typescript" },
    { import = "lazyvim.plugins.extras.lang.json" },
    { import = "lazyvim.plugins.extras.lang.markdown" },
    { import = "lazyvim.plugins.extras.lang.yaml" },
    -- DAP (debugging)
    { import = "lazyvim.plugins.extras.dap.core" },
    { import = "lazyvim.plugins.extras.dap.nlua" },
    -- Editor extras
    { import = "lazyvim.plugins.extras.editor.telescope" },
    -- User plugins (loaded last to allow overrides)
    { import = "plugins" },
  },
  defaults = {
    lazy = false,     -- plugins load at startup unless explicitly lazy = true
    version = false,  -- always use latest git commits for LazyVim plugins
  },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = {
    enabled = true,   -- auto-check for plugin updates
    notify = false,   -- silent background check
  },
  performance = {
    rtp = {
      -- Disable unused built-in runtime plugins
      disabled_plugins = {
        "gzip", "matchit", "matchparen",
        "netrwPlugin", "tarPlugin", "tohtml",
        "tutor", "zipPlugin",
      },
    },
  },
  ui = {
    border = "rounded",
    title = " lazy.nvim ",
    title_pos = "center",
  },
})
