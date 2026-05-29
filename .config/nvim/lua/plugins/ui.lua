-- ─────────────────────────────────────────────────────────────────────────────
-- lua/plugins/ui.lua — UI, Theme, Dashboard
-- ─────────────────────────────────────────────────────────────────────────────

return {
  -- ── Colorscheme: TokyoNight ────────────────────────────────────────────────
  {
    "folke/tokyonight.nvim",
    lazy    = false,
    priority = 1000,
    opts = {
      style        = "night",    -- night | storm | moon | day
      transparent  = false,
      terminal_colors = true,
      styles = {
        comments   = { italic = true },
        keywords   = { italic = true },
        functions  = {},
        variables  = {},
        sidebars   = "dark",
        floats     = "dark",
      },
      sidebars         = { "qf", "help", "neo-tree", "Trouble", "lazy", "mason" },
      day_brightness   = 0.3,
      hide_inactive_statusline = false,
      dim_inactive     = false,
      lualine_bold     = true,
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight-night")
    end,
  },

  -- ── Lualine statusline ─────────────────────────────────────────────────────
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = {
        theme                = "tokyonight",
        globalstatus         = true,
        disabled_filetypes   = { statusline = { "dashboard", "alpha", "starter" } },
        component_separators = { left = "", right = "" },
        section_separators   = { left = "", right = "" },
      },
      sections = {
        lualine_a = { { "mode", icon = "" } },
        lualine_b = {
          { "branch", icon = "" },
          { "diff",   symbols = { added = " ", modified = " ", removed = " " } },
        },
        lualine_c = {
          { "filename", path = 1, symbols = { modified = "●", readonly = "", unnamed = "" } },
        },
        lualine_x = {
          { "diagnostics", symbols = { error = " ", warn = " ", info = " ", hint = "󰝶 " } },
          "encoding",
          { "fileformat", icons_enabled = true },
          { "filetype",   icon_only = false },
        },
        lualine_y = { { "progress", separator = "", padding = { left = 1, right = 0 } } },
        lualine_z = { { "location", padding = { left = 0, right = 1 } } },
      },
    },
  },

  -- ── Bufferline (tab bar) ───────────────────────────────────────────────────
  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        mode              = "buffers",
        separator_style   = "slant",
        show_buffer_close_icons = true,
        show_close_icon   = true,
        color_icons       = true,
        diagnostics       = "nvim_lsp",
        diagnostics_indicator = function(_, _, diagnostics_dict)
          local s = " "
          for e, n in pairs(diagnostics_dict) do
            local sym = e == "error" and " " or (e == "warning" and " " or "")
            s = s .. n .. sym
          end
          return s
        end,
        offsets = {
          { filetype = "neo-tree", text = "File Explorer", highlight = "Directory", text_align = "center" },
        },
      },
    },
  },

  -- ── Dashboard: alpha-nvim ──────────────────────────────────────────────────
  {
    "goolord/alpha-nvim",
    event    = "VimEnter",
    priority = 100,
    config = function()
      local alpha  = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      -- ASCII header
      dashboard.section.header.val = {
        "",
        "  ██████╗ ███████╗██╗   ██╗     ███████╗███╗   ██╗██╗   ██╗",
        "  ██╔══██╗██╔════╝██║   ██║     ██╔════╝████╗  ██║██║   ██║",
        "  ██║  ██║█████╗  ██║   ██║     █████╗  ██╔██╗ ██║██║   ██║",
        "  ██║  ██║██╔══╝  ╚██╗ ██╔╝     ██╔══╝  ██║╚██╗██║╚██╗ ██╔╝",
        "  ██████╔╝███████╗ ╚████╔╝      ███████╗██║ ╚████║ ╚████╔╝ ",
        "  ╚═════╝ ╚══════╝  ╚═══╝       ╚══════╝╚═╝  ╚═══╝  ╚═══╝  ",
        "",
        "         Aryan Development Environment",
        "",
      }
      dashboard.section.header.opts = { hl = "AlphaHeader", position = "center" }

      -- Menu buttons
      dashboard.section.buttons.val = {
        dashboard.button("f", "󰍉  Find File",       "<cmd>Telescope find_files<CR>"),
        dashboard.button("r", "  Recent Files",     "<cmd>Telescope oldfiles<CR>"),
        dashboard.button("g", "  Grep Search",      "<cmd>Telescope live_grep<CR>"),
        dashboard.button("p", "󰏗  Projects",         "<cmd>Telescope projects<CR>"),
        dashboard.button("n", "  New File",          "<cmd>ene <BAR> startinsert<CR>"),
        dashboard.button("c", "  Config",            "<cmd>edit ~/.config/nvim/init.lua<CR>"),
        dashboard.button("l", "󰒲  Lazy",              "<cmd>Lazy<CR>"),
        dashboard.button("m", "  Mason",             "<cmd>Mason<CR>"),
        dashboard.button("q", "  Quit",              "<cmd>qa<CR>"),
      }

      -- Footer
      local function footer()
        local stats = require("lazy").stats()
        return string.format(
          "⚡ LazyVim  %d plugins loaded  · Neovim %s",
          stats.loaded,
          vim.version().major .. "." .. vim.version().minor .. "." .. vim.version().patch
        )
      end

      dashboard.section.footer.val    = footer
      dashboard.section.footer.opts   = { hl = "AlphaFooter", position = "center" }

      -- Highlights
      vim.api.nvim_set_hl(0, "AlphaHeader", { fg = "#7aa2f7" })  -- tokyonight blue
      vim.api.nvim_set_hl(0, "AlphaFooter", { fg = "#565f89" })  -- muted

      alpha.setup(dashboard.config)
    end,
  },

  -- ── Indent guides ─────────────────────────────────────────────────────────
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {
      indent = { char = "│", tab_char = "│" },
      scope  = { enabled = true, show_start = false, show_end = false },
      exclude = {
        filetypes = { "help", "alpha", "dashboard", "neo-tree", "Trouble",
                      "trouble", "lazy", "mason", "notify", "toggleterm", "lazyterm" },
      },
    },
  },

  -- ── Noice (beautiful cmdline / notifications) ─────────────────────────────
  {
    "folke/noice.nvim",
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"]                = true,
          ["cmp.entry.get_documentation"]                  = true,
        },
      },
      presets = {
        bottom_search         = true,
        command_palette       = true,
        long_message_to_split = true,
        inc_rename            = true,
        lsp_doc_border        = true,
      },
    },
  },

  -- ── Which-key (popup keybinding hints) ───────────────────────────────────
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>f",  group = "find/file" },
        { "<leader>g",  group = "git" },
        { "<leader>l",  group = "lsp" },
        { "<leader>b",  group = "buffer" },
        { "<leader>w",  group = "window" },
        { "<leader>t",  group = "terminal" },
        { "<leader>x",  group = "diagnostics/quickfix" },
        { "<leader>r",  group = "rust" },
        { "<leader>c",  group = "c/cpp" },
        { "<leader>p",  group = "plugins" },
        { "<leader>u",  group = "toggle" },
      },
    },
  },
}
