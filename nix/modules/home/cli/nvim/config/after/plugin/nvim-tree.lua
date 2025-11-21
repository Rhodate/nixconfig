-- vim.opt.termguicolors = true

require('nvim-tree').setup({
  update_focused_file = {
    enable = true,
    update_root = {
      enable = false,
    },
  },
  actions = {
    change_dir = {
      enable = false,
      global = true,
    },
  },
  prefer_startup_root = true,
  sync_root_with_cwd = true,
  hijack_unnamed_buffer_when_opening = true,
  disable_netrw = false,
  view = {
    adaptive_size = true,
    side = "right",
    signcolumn = "auto",
  }
})

vim.keymap.set('n', '<leader>tf', vim.cmd.NvimTreeFocus)
vim.keymap.set('n', '<leader>tc', vim.cmd.NvimTreeClose)
vim.keymap.set('n', '<leader>tr', vim.cmd.NvimTreeRefresh)
