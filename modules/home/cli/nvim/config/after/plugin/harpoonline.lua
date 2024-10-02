local harpoonline = require('harpoonline')
harpoonline.setup({
  on_update = function() require('lualine').refresh() end,
  formatter = 'extended',
  formatter_opts = {
    extended = {
      empty_slow = ' · ',
    },
  },
})
