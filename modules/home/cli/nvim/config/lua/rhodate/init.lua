vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true

vim.opt.laststatus = 3

vim.opt.foldmethod= 'expr'
vim.opt.foldexpr= 'nvim_treesitter#foldexpr()'
vim.opt.foldenable = false

vim.opt.smartindent = true

vim.opt.undodir = os.getenv('HOME') .. '/.vim/undodir'
vim.opt.undofile = true
vim.opt.swapfile = false
vim.opt.backup = false

vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"

vim.opt.updatetime = 750

--vim.opt.colorcolumn = "80"

vim.api.nvim_command('cd %:p:h')

local bufname = vim.api.nvim_buf_get_name(0)

if vim.fn.isdirectory(bufname) ~= 0 then
  vim.opt.bufhidden = 'wipe'
end
vim.g.vim_k8s_toggle_key_map = "<C-p>"

vim.opt.showmode = false
vim.opt.showcmd = false
vim.opt.cmdheight = 0

require('rhodate.remap')
require('rhodate.lazy')
