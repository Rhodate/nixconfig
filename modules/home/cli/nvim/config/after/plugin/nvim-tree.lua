-- vim.opt.termguicolors = true

require('nvim-tree').setup({
  update_focused_file = { enable = true },
  hijack_unnamed_buffer_when_opening = true,
  sync_root_with_cwd = true,
  view = {
    adaptive_size = true,
    side = "right",
    signcolumn = "auto",
  }
})

vim.keymap.set('n', '<leader>tf', vim.cmd.NvimTreeFocus)
vim.keymap.set('n', '<leader>tc', vim.cmd.NvimTreeClose)
vim.keymap.set('n', '<leader>tr', vim.cmd.NvimTreeRefresh)
