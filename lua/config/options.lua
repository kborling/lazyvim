-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Neovide settings
if vim.g.neovide then
  vim.opt.guifont = "Comic Code:h10:#e-subpixelantialias:#h-none"
  vim.g.neovide_transparency = 1.0
  vim.g.neovide_scroll_animation_length = 0.2
  vim.g.neovide_hide_mouse_when_typing = true
  vim.g.neovide_refresh_rate = 144
  vim.g.neovide_cursor_vfx_mode = "railgun"
  vim.g.neovide_scale_factor = 1.0
end

-- Disable animations globally
vim.g.snacks_animate = false

-- Disable code folding
vim.opt.foldenable = false
vim.opt.foldmethod = "manual"
