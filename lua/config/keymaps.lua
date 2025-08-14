-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Close other windows (keep only current window)
vim.keymap.set("n", "<leader>wo", "<cmd>only<cr>", { desc = "Close other windows" })

-- Disable default notification keymap
vim.keymap.del("n", "<leader>n")

-- Debugging keybindings
vim.keymap.set("n", "<leader>db", function() require("dap").toggle_breakpoint() end, { desc = "Toggle Breakpoint" })
vim.keymap.set("n", "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, { desc = "Set Conditional Breakpoint" })
vim.keymap.set("n", "<leader>dc", function() require("dap").continue() end, { desc = "Continue" })
vim.keymap.set("n", "<leader>dC", function() require("dap").run_to_cursor() end, { desc = "Run to Cursor" })
vim.keymap.set("n", "<leader>dg", function() require("dap").goto_() end, { desc = "Go to line (no execute)" })
vim.keymap.set("n", "<leader>di", function() require("dap").step_into() end, { desc = "Step Into" })
vim.keymap.set("n", "<leader>dj", function() require("dap").down() end, { desc = "Down" })
vim.keymap.set("n", "<leader>dk", function() require("dap").up() end, { desc = "Up" })
vim.keymap.set("n", "<leader>dl", function() require("dap").run_last() end, { desc = "Run Last" })
vim.keymap.set("n", "<leader>do", function() require("dap").step_out() end, { desc = "Step Out" })
vim.keymap.set("n", "<leader>dO", function() require("dap").step_over() end, { desc = "Step Over" })
vim.keymap.set("n", "<leader>dp", function() require("dap").pause() end, { desc = "Pause" })
vim.keymap.set("n", "<leader>dr", function() require("dap").repl.toggle() end, { desc = "Toggle REPL" })
vim.keymap.set("n", "<leader>ds", function() require("dap").session() end, { desc = "Session" })
vim.keymap.set("n", "<leader>dt", function() require("dap").terminate() end, { desc = "Terminate" })
vim.keymap.set("n", "<leader>dw", function() require("dap.ui.widgets").hover() end, { desc = "Widgets" })
