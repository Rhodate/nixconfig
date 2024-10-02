function Theme()
  require('catppuccin').setup {
    flavour = 'mocha',
    background = {
      light = 'latte',
      dark = 'mocha',
    },
    transparent_background = true,
    term_colors = true,
    styles = {
      comments = { 'italic' },
      conditionals = {},
      types = { 'bold' },
      keywords = { 'bold' },
    },
  }

  vim.cmd.colorscheme 'catppuccin'

  vim.api.nvim_set_hl(0, 'NotifyBackground', { bg = '#000000' })
end

Theme()

