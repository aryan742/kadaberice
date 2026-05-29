-- ─────────────────────────────────────────────────────────────────────────────
-- lua/plugins/tools.lua — Editor Utilities, Search, Terminal, DAP, Git
-- ─────────────────────────────────────────────────────────────────────────────

return {
  -- ── Telescope: fuzzy finder ────────────────────────────────────────────────
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-telescope/telescope-project.nvim",
      "nvim-telescope/telescope-file-browser.nvim",
    },
    opts = {
      defaults = {
        prompt_prefix   = "  ",
        selection_caret = "  ",
        entry_prefix    = "   ",
        border          = true,
        borderchars     = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
        layout_config   = { horizontal = { preview_width = 0.55 }, width = 0.87, height = 0.80 },
        file_ignore_patterns = {
          "node_modules/", ".git/", "target/",
          "%.o", "%.a", "%.so", "%.class",
          "__pycache__/", "%.pyc",
        },
        vimgrep_arguments = {
          "rg", "--color=never", "--no-heading", "--with-filename",
          "--line-number", "--column", "--smart-case", "--hidden",
          "--glob", "!.git/*",
        },
        mappings = {
          i = {
            ["<C-j>"] = "move_selection_next",
            ["<C-k>"] = "move_selection_previous",
            ["<C-f>"] = "preview_scrolling_down",
            ["<C-b>"] = "preview_scrolling_up",
            ["<C-q>"] = "send_to_qflist",
            ["<Esc>"] = "close",
          },
        },
      },
      extensions = {
        fzf = { fuzzy = true, override_generic_sorter = true, override_file_sorter = true },
        project = {
          base_dirs = {
            { path = "~/Projects",  max_depth = 3 },
            { path = "~/GitHub",    max_depth = 2 },
          },
          hidden_files = false,
          theme        = "dropdown",
        },
      },
    },
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      telescope.load_extension("fzf")
      telescope.load_extension("project")
      telescope.load_extension("file_browser")
    end,
  },

  -- ── neo-tree: file explorer ────────────────────────────────────────────────
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      close_if_last_window = true,
      popup_border_style   = "rounded",
      enable_git_status    = true,
      enable_diagnostics   = true,
      default_component_configs = {
        icon = {
          folder_closed   = "",
          folder_open     = "",
          folder_empty    = "󰜌",
          default         = "",
          highlight       = "NeoTreeFileIcon",
        },
        git_status = {
          symbols = {
            added     = "✚", modified = "", deleted = "✖",
            renamed   = "󰁕", untracked = "", ignored = "",
            unstaged  = "󰄱", staged = "",  conflict = "",
          },
        },
      },
      window = {
        position = "left",
        width    = 35,
        mappings = {
          ["<space>"] = "none",  -- avoid conflict with leader
          ["<cr>"]    = "open",
          ["l"]       = "open",
          ["h"]       = "close_node",
          ["v"]       = "open_vsplit",
          ["s"]       = "open_split",
          ["t"]       = "open_tabnew",
          ["P"]       = { "toggle_preview", config = { use_float = true } },
          ["a"]       = { "add", config = { show_path = "relative" } },
          ["d"]       = "delete",
          ["r"]       = "rename",
          ["c"]       = "copy",
          ["m"]       = "move",
          ["q"]       = "close_window",
          ["R"]       = "refresh",
          ["?"]       = "show_help",
        },
      },
      filesystem = {
        filtered_items = {
          visible        = false,
          hide_dotfiles  = false,  -- show dotfiles
          hide_gitignored = true,
        },
        follow_current_file   = { enabled = true },
        use_libuv_file_watcher = true,
      },
    },
  },

  -- ── toggleterm: persistent terminal ────────────────────────────────────────
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = {
      size = function(term)
        if term.direction == "horizontal" then return 15
        elseif term.direction == "vertical" then return vim.o.columns * 0.4
        end
      end,
      open_mapping       = [[<C-\>]],
      hide_numbers       = true,
      shade_terminals    = true,
      shading_factor     = 2,
      start_in_insert    = true,
      insert_mappings    = true,
      persist_size       = true,
      direction          = "float",
      close_on_exit      = true,
      shell              = "/bin/bash",
      float_opts         = { border = "curved", winblend = 3 },
      highlights         = {
        FloatBorder = { link = "FloatBorder" },
        NormalFloat = { link = "Normal" },
      },
    },
  },

  -- ── lazygit.nvim: full git UI ─────────────────────────────────────────────
  {
    "kdheepak/lazygit.nvim",
    cmd          = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile", "LazyGitFilter" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys         = { { "<leader>gg", "<cmd>LazyGit<CR>", desc = "LazyGit" } },
  },

  -- ── gitsigns: git hunk decorations ────────────────────────────────────────
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add          = { text = "▎" },
        change       = { text = "▎" },
        delete       = { text = "" },
        topdelete    = { text = "" },
        changedelete = { text = "▎" },
        untracked    = { text = "▎" },
      },
      current_line_blame = false,  -- toggle with <leader>gb
      on_attach = function(buffer)
        local gs  = package.loaded.gitsigns
        local map = vim.keymap.set
        local function opts_b(d) return { buffer = buffer, desc = d } end

        map("n", "]h", function() gs.nav_hunk("next") end, opts_b("Next hunk"))
        map("n", "[h", function() gs.nav_hunk("prev") end, opts_b("Prev hunk"))
        map({ "n","v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>",     opts_b("Stage hunk"))
        map({ "n","v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>",     opts_b("Reset hunk"))
        map("n", "<leader>ghS", gs.stage_buffer,                        opts_b("Stage buffer"))
        map("n", "<leader>ghu", gs.undo_stage_hunk,                     opts_b("Undo stage hunk"))
        map("n", "<leader>ghR", gs.reset_buffer,                        opts_b("Reset buffer"))
        map("n", "<leader>ghp", gs.preview_hunk_inline,                 opts_b("Preview hunk"))
        map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, opts_b("Blame line"))
        map("n", "<leader>ghd", gs.diffthis,                            opts_b("Diff this"))
        map("n", "<leader>ghD", function() gs.diffthis("~") end,        opts_b("Diff this ~"))
        map({ "o","x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>",        opts_b("Select hunk"))
      end,
    },
  },

  -- ── nvim-dap: debugging (C/C++/Rust via codelldb) ─────────────────────────
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap    = require("dap")
      local dapui  = require("dapui")
      local mason_path = vim.fn.glob(
        vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/"
      )
      local codelldb_path = mason_path .. "adapter/codelldb"
      local liblldb_path  = mason_path .. "lldb/lib/liblldb.so"

      -- ── codelldb adapter (C / C++ / Rust) ─────────────────────────────────
      dap.adapters.codelldb = {
        type    = "server",
        port    = "${port}",
        executable = {
          command = codelldb_path,
          args    = { "--liblldb", liblldb_path, "--port", "${port}" },
        },
      }

      -- C / C++ launch config
      dap.configurations.c = {
        {
          name        = "Launch (C)",
          type        = "codelldb",
          request     = "launch",
          program     = function() return vim.fn.input("Executable: ", vim.fn.getcwd() .. "/", "file") end,
          cwd         = "${workspaceFolder}",
          stopOnEntry = false,
          args        = {},
        },
      }
      dap.configurations.cpp  = dap.configurations.c
      dap.configurations.rust = {
        {
          name        = "Launch (Rust)",
          type        = "codelldb",
          request     = "launch",
          program     = function() return vim.fn.input("Executable: ", vim.fn.getcwd() .. "/target/debug/", "file") end,
          cwd         = "${workspaceFolder}",
          stopOnEntry = false,
          args        = {},
        },
      }

      -- DAP UI auto-open/close
      dap.listeners.after.event_initialized["dapui_config"]  = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"]  = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"]      = function() dapui.close() end

      -- DAP UI setup
      dapui.setup({
        icons   = { expanded = "", collapsed = "", current_frame = "" },
        layouts = {
          { elements = { "scopes", "breakpoints", "stacks", "watches" }, size = 40, position = "left" },
          { elements = { "repl", "console" }, size = 0.25, position = "bottom" },
        },
      })

      -- Virtual text
      require("nvim-dap-virtual-text").setup({ commented = true })

      -- DAP keymaps
      local map = vim.keymap.set
      map("n", "<F5>",  dap.continue,           { desc = "DAP: Continue" })
      map("n", "<F10>", dap.step_over,           { desc = "DAP: Step over" })
      map("n", "<F11>", dap.step_into,           { desc = "DAP: Step into" })
      map("n", "<F12>", dap.step_out,            { desc = "DAP: Step out" })
      map("n", "<leader>db", dap.toggle_breakpoint, { desc = "DAP: Toggle breakpoint" })
      map("n", "<leader>dB", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, { desc = "DAP: Conditional breakpoint" })
      map("n", "<leader>dr", dap.repl.open,      { desc = "DAP: REPL" })
      map("n", "<leader>du", dapui.toggle,       { desc = "DAP: Toggle UI" })
      map("n", "<leader>dt", dap.terminate,      { desc = "DAP: Terminate" })
    end,
  },

  -- ── Trouble: diagnostic list ───────────────────────────────────────────────
  {
    "folke/trouble.nvim",
    opts = { use_diagnostic_signs = true },
  },

  -- ── Flash: enhanced search + jump ─────────────────────────────────────────
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts  = {},
    keys  = {
      { "s",     mode = { "n","x","o" }, function() require("flash").jump()        end, desc = "Flash jump" },
      { "S",     mode = { "n","x","o" }, function() require("flash").treesitter()  end, desc = "Flash treesitter" },
      { "r",     mode = "o",            function() require("flash").remote()       end, desc = "Flash remote" },
      { "<c-s>", mode = { "c" },        function() require("flash").toggle()       end, desc = "Flash toggle search" },
    },
  },

  -- ── mini.pairs (bracket auto-close) ──────────────────────────────────────
  -- Handled by nvim-autopairs in coding.lua

  -- ── Harpoon 2: fast file navigation ───────────────────────────────────────
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup()
      local map = vim.keymap.set
      map("n", "<leader>ha", function() harpoon:list():add() end,                    { desc = "Harpoon: add file" })
      map("n", "<leader>hm", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon: menu" })
      map("n", "<leader>h1", function() harpoon:list():select(1) end,                { desc = "Harpoon: file 1" })
      map("n", "<leader>h2", function() harpoon:list():select(2) end,                { desc = "Harpoon: file 2" })
      map("n", "<leader>h3", function() harpoon:list():select(3) end,                { desc = "Harpoon: file 3" })
      map("n", "<leader>h4", function() harpoon:list():select(4) end,                { desc = "Harpoon: file 4" })
    end,
  },
}
