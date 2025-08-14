--
-- In your plugin files, you can:
-- * add extra plugins
-- * disable/enabled LazyVim plugins
-- * override the configuration of LazyVim plugins
return {
  -- Import LazyVim extras first
  { import = "lazyvim.plugins.extras.lang.typescript" },
  { import = "lazyvim.plugins.extras.lang.json" },
  { import = "lazyvim.plugins.extras.lang.angular" },

  -- Configure LazyVim colorscheme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "moonbow",
    },
  },

  -- Override LazyVim plugins
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "regex",
        "tsx",
        "typescript",
        "c_sharp",
        "vim",
        "yaml",
      },
    },
  },

  -- Color themes
  {
    "arturgoms/moonbow.nvim",
    lazy = false,
    priority = 1000,
  },
  {
    "vague2k/vague.nvim",
    lazy = false,
    priority = 1000,
  },

  -- Neogit - Magit clone for Neovim
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("neogit").setup({})
      vim.keymap.set("n", "<leader>G", function()
        require("neogit").open()
      end, { desc = "Open Neogit" })
    end,
  },

  -- Orgmode
  {
    "nvim-orgmode/orgmode",
    event = "VeryLazy",
    ft = { "org" },
    config = function()
      require("orgmode").setup({
        org_agenda_files = { "~/org/**/*" },
        org_default_notes_file = "~/org/refile.org",
      })
    end,
  },

  {
    "greggh/claude-code.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("claude-code").setup({
        window = {
          split_ratio = 0.3,
          position = "botright",
          enter_insert = true,
          hide_numbers = true,
          hide_signcolumn = true,
          float = {
            width = "80%",
            height = "80%",
            row = "center",
            col = "center",
            relative = "editor",
            border = "rounded",
          },
        },
        refresh = {
          enable = true,
          updatetime = 100,
          timer_interval = 1000,
          show_notifications = false,
        },
        git = {
          use_git_root = true,
        },
        shell = {
          separator = "&&",
          pushd_cmd = "pushd",
          popd_cmd = "popd",
        },
        command = "claude",
        command_variants = {
          continue = "--continue",
          resume = "--resume",
          verbose = "--verbose",
        },
        keymaps = {
          toggle = {
            normal = "<C-,>",
            terminal = "<C-,>",
            variants = {
              continue = "<leader>cC",
              verbose = "<leader>cV",
            },
          },
          window_navigation = true,
          scrolling = true,
        },
        terminal = {
          use_leader_mappings = false,
        },
      })
    end,
  },

  -- Database client for Azure SQL and other databases
  {
    "kndndrj/nvim-dbee",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    build = function()
      require("dbee").install()
    end,
    config = function()
      require("dbee").setup({
        sources = {
          require("dbee.sources").EnvSource:new("DBEE_CONNECTIONS"),
          require("dbee.sources").FileSource:new(vim.fn.stdpath("cache") .. "/dbee/persistence.json"),
        },
      })

      -- Keymaps for database operations
      vim.keymap.set("n", "<leader>D", function()
        require("dbee").toggle()
      end, { desc = "Toggle Database UI" })

      vim.keymap.set("n", "<leader>De", function()
        require("dbee").execute(vim.fn.input("Query: "))
      end, { desc = "Execute SQL Query" })
    end,
  },

  -- DAP configuration
  {
    "mfussenegger/nvim-dap",
    config = function()
      -- Basic configuration - add your specific debugger configurations here
    end,
  },

  -- .NET Core solution support
  {
    "iabdelkareem/csharp.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "mfussenegger/nvim-dap",
      "Tastyep/structlog.nvim",
    },
    config = function()
      require("mason").setup()
      require("csharp").setup({
        lsp = {
          enable = true,
        },
        dap = {
          enable = true,
        },
      })
    end,
  },

  -- Additional .NET support
  {
    "GustavEikaas/easy-dotnet.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
    ft = { "cs", "fsproj", "csproj", "sln" },
    cmd = { "Dotnet" },
    config = function()
      require("easy-dotnet").setup()
    end,
    keys = {
      { "<leader>ns", "<cmd>Dotnet<cr>", desc = ".NET Solutions" },
    },
  },
}
