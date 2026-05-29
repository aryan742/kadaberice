-- ─────────────────────────────────────────────────────────────────────────────
-- lua/plugins/lsp.lua — LSP, Mason, and Language Servers
-- Covers: C/C++, Rust, Python, Lua, Bash, JS/TS
-- ─────────────────────────────────────────────────────────────────────────────

return {
  -- ── Mason: LSP / formatter / linter installer ─────────────────────────────
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        -- Language servers
        "clangd",             -- C / C++
        "pyright",            -- Python
        "lua-language-server",-- Lua
        "bash-language-server",-- Bash
        "typescript-language-server", -- JS / TS
        "taplo",              -- TOML (Cargo.toml, etc.)
        "yaml-language-server",-- YAML
        "json-lsp",           -- JSON
        "marksman",           -- Markdown
        -- Formatters
        "clang-format",       -- C / C++
        "stylua",             -- Lua
        "black",              -- Python
        "isort",              -- Python imports
        "prettier",           -- JS / TS / HTML / CSS / JSON / YAML / Markdown
        "shfmt",              -- Bash / Shell
        -- Linters
        "cpplint",            -- C / C++
        "flake8",             -- Python
        "shellcheck",         -- Bash
        "eslint_d",           -- JS / TS
        -- DAP adapters
        "codelldb",           -- C / C++ / Rust debugger (LLDB-based)
      },
      ui = {
        border = "rounded",
        icons  = { package_installed = "✓", package_pending = "➜", package_uninstalled = "✗" },
      },
    },
  },

  -- ── mason-lspconfig: auto-setup installed servers ─────────────────────────
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      automatic_installation = false,  -- We manage via mason.ensure_installed
    },
  },

  -- ── nvim-lspconfig: server configuration ──────────────────────────────────
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- Diagnostics display
      diagnostics = {
        underline   = true,
        update_in_insert = false,
        virtual_text = {
          spacing = 4,
          source  = "if_many",
          prefix  = "●",
        },
        severity_sort = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN]  = " ",
            [vim.diagnostic.severity.HINT]  = "󰝶 ",
            [vim.diagnostic.severity.INFO]  = " ",
          },
        },
      },
      -- Enable LSP inlay hints (Neovim 0.10+)
      inlay_hints = { enabled = true },
      -- Enable LSP code lens (show references / run buttons inline)
      codelens    = { enabled = false },  -- Can be slow; toggle with <leader>lc if desired
      -- Capabilities (enhanced by nvim-cmp)
      capabilities = {
        workspace = { fileOperations = { didRename = true, willRename = true } },
      },
      servers = {
        -- ── clangd (C / C++) ─────────────────────────────────────────────────
        clangd = {
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--function-arg-placeholders",
            "--fallback-style=llvm",
          },
          root_dir = function(fname)
            return require("lspconfig.util").root_pattern(
              "compile_commands.json", "compile_flags.txt",
              ".clangd", ".git"
            )(fname)
          end,
          init_options = {
            usePlaceholders  = true,
            completeUnimported = true,
            clangdFileStatus = true,
          },
          filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
        },

        -- ── Pyright (Python) ─────────────────────────────────────────────────
        pyright = {
          settings = {
            python = {
              analysis = {
                autoSearchPaths      = true,
                useLibraryCodeForTypes = true,
                diagnosticMode       = "openFilesOnly",
                typeCheckingMode     = "basic",
              },
            },
          },
        },

        -- ── lua_ls (Lua) ─────────────────────────────────────────────────────
        lua_ls = {
          settings = {
            Lua = {
              workspace = { checkThirdParty = false },
              completion = { callSnippet = "Replace" },
              diagnostics = { globals = { "vim" } },
              telemetry = { enable = false },
            },
          },
        },

        -- ── bashls (Bash) ─────────────────────────────────────────────────────
        bashls = {
          filetypes = { "sh", "bash" },
          settings  = {
            bashIde = { globPattern = "*@(.sh|.inc|.bash|.command)" },
          },
        },

        -- ── tsserver (JavaScript / TypeScript) ───────────────────────────────
        tsserver = {
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints       = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints         = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints      = true,
              },
            },
            javascript = {
              inlayHints = {
                includeInlayParameterNameHints       = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints         = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints      = true,
              },
            },
          },
        },

        -- ── taplo (TOML — Cargo.toml, etc.) ──────────────────────────────────
        taplo = {},

        -- ── yamlls ────────────────────────────────────────────────────────────
        yamlls = {
          settings = {
            yaml = {
              keyOrdering   = false,
              format        = { enable = true },
              validate      = true,
              schemaStore   = { enable = false, url = "" },
            },
          },
        },

        -- ── jsonls ────────────────────────────────────────────────────────────
        jsonls = {
          on_new_config = function(new_config)
            new_config.settings.json.schemas = new_config.settings.json.schemas or {}
            vim.list_extend(new_config.settings.json.schemas,
              require("schemastore").json.schemas())
          end,
          settings = {
            json = { format = { enable = true }, validate = { enable = true } },
          },
        },

        -- ── marksman (Markdown) ───────────────────────────────────────────────
        marksman = {},
      },
      setup = {
        -- Rust is handled by rustaceanvim (not lspconfig directly)
        rust_analyzer = function() return true end,
        clangd = function(_, opts)
          -- clangd requires the clangd extra from LazyVim for full integration
          local clangd_ext_opts = require("lazyvim.util").opts("clangd_extensions.nvim")
          require("clangd_extensions").setup(
            vim.tbl_deep_extend("force", clangd_ext_opts or {}, { server = opts })
          )
          return true
        end,
      },
    },
  },
}
