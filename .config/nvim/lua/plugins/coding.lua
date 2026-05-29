-- ─────────────────────────────────────────────────────────────────────────────
-- lua/plugins/coding.lua — Completion, Formatting, Snippets, Treesitter
-- ─────────────────────────────────────────────────────────────────────────────

return {
  -- ── Treesitter: syntax highlighting & text objects ────────────────────────
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        -- Systems / Low-level
        "c", "cpp", "rust", "asm",
        -- Scripting
        "lua", "python", "bash",
        -- Web
        "javascript", "typescript", "tsx", "html", "css", "json", "jsonc",
        -- Config / Data
        "toml", "yaml", "ini",
        -- Docs
        "markdown", "markdown_inline",
        -- Neovim
        "vim", "vimdoc", "query",
        -- Other useful
        "make", "cmake", "dockerfile",
        "git_rebase", "gitcommit", "gitignore",
        "regex",
      },
      highlight     = { enable = true },
      indent        = { enable = true },
      auto_install  = true,
      incremental_selection = {
        enable  = true,
        keymaps = {
          init_selection    = "<C-space>",
          node_incremental  = "<C-space>",
          scope_incremental = false,
          node_decremental  = "<bs>",
        },
      },
    },
  },

  -- ── conform.nvim: formatting ──────────────────────────────────────────────
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        c          = { "clang_format" },
        cpp        = { "clang_format" },
        lua        = { "stylua" },
        python     = { "isort", "black" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        json       = { "prettier" },
        yaml       = { "prettier" },
        markdown   = { "prettier" },
        html       = { "prettier" },
        css        = { "prettier" },
        sh         = { "shfmt" },
        bash       = { "shfmt" },
        toml       = { "taplo" },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
      formatters = {
        shfmt = {
          prepend_args = { "-i", "4", "-bn" },  -- 4-space indent, binary-next
        },
        black = {
          prepend_args = { "--line-length", "100" },
        },
        stylua = {
          prepend_args = { "--indent-type", "Spaces", "--indent-width", "2" },
        },
      },
    },
  },

  -- ── nvim-lint: async linting ──────────────────────────────────────────────
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        c          = { "cpplint" },
        cpp        = { "cpplint" },
        python     = { "flake8" },
        sh         = { "shellcheck" },
        bash       = { "shellcheck" },
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
      },
    },
  },

  -- ── nvim-cmp: completion ──────────────────────────────────────────────────
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      local cmp = require("cmp")
      -- Add path completion source
      opts.sources = cmp.config.sources(vim.list_extend(opts.sources or {}, {
        { name = "path" },
      }))
      -- Better completion appearance
      opts.window = {
        completion    = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      }
      -- Preselect first item
      opts.preselect = cmp.PreselectMode.None
      opts.completion = { completeopt = "menu,menuone,noinsert" }
      return opts
    end,
  },

  -- ── Rust: rustaceanvim (replaces rust-tools, official LazyVim approach) ───
  {
    "mrcjkb/rustaceanvim",
    version = "^5",  -- Use semver for stability
    ft      = { "rust" },
    opts = {
      server = {
        on_attach = function(_, bufnr)
          -- Rust-specific keymaps (buffer-local)
          local map = vim.keymap.set
          local opts_buf = { buffer = bufnr, silent = true }
          map("n", "<leader>rr", function() vim.cmd.RustLsp("runnables")    end, vim.tbl_extend("force", opts_buf, { desc = "Rust runnables" }))
          map("n", "<leader>rd", function() vim.cmd.RustLsp("debuggables")  end, vim.tbl_extend("force", opts_buf, { desc = "Rust debuggables" }))
          map("n", "<leader>re", function() vim.cmd.RustLsp("expandMacro") end, vim.tbl_extend("force", opts_buf, { desc = "Rust expand macro" }))
          map("n", "<leader>rc", function() vim.cmd.RustLsp("openCargo")    end, vim.tbl_extend("force", opts_buf, { desc = "Rust open Cargo.toml" }))
          map("n", "<leader>rp", function() vim.cmd.RustLsp("parentModule") end, vim.tbl_extend("force", opts_buf, { desc = "Rust parent module" }))
          map("n", "K",          function() vim.cmd.RustLsp { "hover", "actions" } end, vim.tbl_extend("force", opts_buf, { desc = "Rust hover actions" }))
        end,
        default_settings = {
          ["rust-analyzer"] = {
            cargo     = { allFeatures = true, loadOutDirsFromCheck = true, buildScripts = { enable = true } },
            checkOnSave = { allFeatures = true, command = "clippy", extraArgs = { "--no-deps" } },
            procMacro = {
              enable = true,
              ignored = {
                ["async-trait"] = { "async_trait" },
                ["napi-derive"] = { "napi" },
                ["async-recursion"] = { "async_recursion" },
              },
            },
            inlayHints = {
              lifetimeElisionHints = { enable = "skip_trivial", useParameterNames = true },
              closureReturnTypeHints = { enable = "with_block" },
            },
          },
        },
      },
    },
    config = function(_, opts)
      vim.g.rustaceanvim = vim.tbl_deep_extend("keep", vim.g.rustaceanvim or {}, opts)
    end,
  },

  -- ── Crates.nvim: Cargo.toml dependency helper ─────────────────────────────
  {
    "Saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    opts  = { completion = { cmp = { enabled = true } } },
  },

  -- ── LuaSnip: snippets engine ──────────────────────────────────────────────
  {
    "L3MON4D3/LuaSnip",
    opts = { history = true, delete_check_events = "TextChanged" },
  },

  -- ── friendly-snippets: pre-built snippet collections ─────────────────────
  {
    "rafamadriz/friendly-snippets",
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },

  -- ── Comment.nvim ──────────────────────────────────────────────────────────
  {
    "numToStr/Comment.nvim",
    opts = {},
  },

  -- ── Todo-comments ─────────────────────────────────────────────────────────
  {
    "folke/todo-comments.nvim",
    cmd  = { "TodoTrouble", "TodoTelescope" },
    opts = { signs = true },
  },

  -- ── nvim-autopairs ────────────────────────────────────────────────────────
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts  = { check_ts = true },  -- Use treesitter for smart pairing
  },

  -- ── nvim-surround ─────────────────────────────────────────────────────────
  {
    "kylechui/nvim-surround",
    version = "*",
    event   = "VeryLazy",
    opts    = {},
  },
}
