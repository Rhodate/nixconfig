vim.g.mapleader = " "
vim.g.vim_k8s_toggle_keymap = "<C-p>"

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")

vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')

vim.keymap.set('n', '<leader>F', function()
  vim.lsp.buf.format {
    -- USE FUCKING ESLINT-LSP FOR FORMATTING
    filter = function(client) return client.name ~= "tsserver" end
  }
end)
vim.keymap.set('v', '<leader>F', function()
  vim.lsp.buf.format({
    async = true,
    range = {
      ["start"] = vim.api.nvim_buf_get_mark(0, "<"),
      ["end"] = vim.api.nvim_buf_get_mark(0, ">"),
    },
    filter = function(client) return client.name ~= "tsserver" end
  })
  vim.api.nvim_feedkeys('<esc>', 'x', false)
end)
vim.keymap.set({ 'n', 'v' }, '<leader>y', '"+y')
vim.keymap.set({ 'n', 'v' }, '<leader>p', '"+p')
vim.keymap.set({ 'n', 'v' }, '<leader>P', '"+P')

vim.keymap.set('n', '<Tab>', ':bnext\n')
vim.keymap.set('n', '<S-Tab>', ':bprev\n')

vim.keymap.set({ 'n', 'v' }, ';', ':')
