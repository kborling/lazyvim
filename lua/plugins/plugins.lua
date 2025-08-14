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

      -- Azure SQL authentication helper function
      local function get_azure_sql_token()
        local handle = io.popen(
          'az account get-access-token --resource="https://database.windows.net" --query accessToken --output tsv 2>/dev/null'
        )
        if not handle then
          return nil
        end
        local token = handle:read("*a"):gsub("%s+", "")
        handle:close()
        return token ~= "" and token or nil
      end

      -- Function to create Azure SQL connection with Managed Identity
      local function connect_azure_sql_mi(server, database, user_id)
        local token = get_azure_sql_token()
        if not token then
          vim.notify(
            "Failed to get Azure access token. Make sure you're logged in with 'az login'",
            vim.log.levels.ERROR
          )
          return
        end

        local connection_string
        if user_id then
          -- User-assigned managed identity
          connection_string = string.format(
            "sqlserver://%s@%s:1433?database=%s&trustServerCertificate=true&connection+timeout=30&encrypt=true&authentication=ActiveDirectoryDefault&user+id=%s&access+token=%s",
            user_id,
            server,
            database,
            user_id,
            token
          )
        else
          -- System-assigned managed identity or Azure CLI auth
          connection_string = string.format(
            "sqlserver://dummy@%s:1433?database=%s&trustServerCertificate=true&connection+timeout=30&encrypt=true&authentication=ActiveDirectoryDefault&access+token=%s",
            server,
            database,
            token
          )
        end

        -- Add connection to dbee
        local sources = require("dbee").get_sources()
        local file_source = sources[2] -- Assuming FileSource is second
        if file_source then
          file_source:save({
            id = server .. "_" .. database,
            name = string.format("%s - %s (Azure MI)", server, database),
            type = "sqlserver",
            url = connection_string,
          })
          vim.notify(string.format("Added Azure SQL connection: %s/%s", server, database), vim.log.levels.INFO)
        end
      end

      -- Keymaps for database operations
      vim.keymap.set("n", "<leader>D", function()
        require("dbee").toggle()
      end, { desc = "Toggle Database UI" })

      vim.keymap.set("n", "<leader>De", function()
        require("dbee").execute(vim.fn.input("Query: "))
      end, { desc = "Execute SQL Query" })

      -- Azure SQL Managed Identity connection command
      vim.keymap.set("n", "<leader>Da", function()
        local server = vim.fn.input("Azure SQL Server (without .database.windows.net): ")
        if server == "" then
          return
        end

        local database = vim.fn.input("Database name: ")
        if database == "" then
          return
        end

        local user_id = vim.fn.input("User ID (leave empty for system-assigned MI or Azure CLI): ")
        user_id = user_id == "" and nil or user_id

        connect_azure_sql_mi(server .. ".database.windows.net", database, user_id)
      end, { desc = "Add Azure SQL MI Connection" })

      -- Quick connect to Azure SQL with environment variables
      vim.keymap.set("n", "<leader>Dq", function()
        local server = os.getenv("AZURE_SQL_SERVER")
        local database = os.getenv("AZURE_SQL_DATABASE")
        local user_id = os.getenv("AZURE_SQL_USER_ID")

        if not server or not database then
          vim.notify("Set AZURE_SQL_SERVER and AZURE_SQL_DATABASE environment variables", vim.log.levels.ERROR)
          return
        end

        connect_azure_sql_mi(server, database, user_id)
      end, { desc = "Quick Azure SQL MI Connection (from env)" })
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
      "mason-org/mason.nvim",
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
