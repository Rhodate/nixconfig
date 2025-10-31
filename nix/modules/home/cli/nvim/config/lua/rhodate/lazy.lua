local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

return require('lazy').setup({
  'tpope/vim-eunuch',

  {
    'Bekaboo/dropbar.nvim',
    -- optional, but required for fuzzy finder support
    dependencies = {
      'nvim-telescope/telescope-fzf-native.nvim'
    }
  },

  {
    "qvalentin/helm-ls.nvim",
    ft = "helm",
    opts = {
        -- leave empty or see below
    },
  },

  {
    'lucidph3nx/nvim-sops',
    event = { 'BufEnter' },
  },

  {
      "iamcco/markdown-preview.nvim",
      cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
      ft = { "markdown" },
      build = function() vim.fn["mkdp#util#install"]() end,
  },

  {
    "Exafunction/codeium.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp",
    },
    config = function()
      require("codeium").setup({
        virtual_text = {
          enabled = true,
          key_bindings = {
            accept = "<A-f>",
          },
          workspace_root = "use_lsp",
          enable_cmp_source = false,
          enable_chat = true,
        },
      })
    end
  },

  {
    "stevearc/conform.nvim",
    lazy = true,
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        nix = { "alejandra" },
      },
    },
    keys = {
      { "<leader>F", function() require 'conform'.format { lsp_fallback = true } end, desc = "Format Buffer" },
    },
  },

  'lambdalisue/suda.vim',

  'rmagatti/auto-session',

  {
    'mikesmithgh/kitty-scrollback.nvim',
    enabled = true,
    lazy = true,
    cmd = { 'KittyScrollbackGenerateKittens', 'KittyScrollbackCheckHealth' },
    event = { 'User KittyScrollbackLaunch' },
    -- version = '*', -- latest stable version, may have breaking changes if major version changed
    -- version = '^5.0.0', -- pin major version, include fixes and features that do not have breaking changes
    config = function()
      require('kitty-scrollback').setup()
    end,
  },

  {
    'declancm/cinnamon.nvim',
    config = function()
      require('cinnamon').setup {
        keymaps = {
          basic = true,
          extra = true,
        },
        options = {
          delay = 5,
          max_delta = {
            line = 100,
            column = nil,
          },
          mode = "window",
        },
      }
    end
  },

  {
      "3rd/image.nvim",
      build = false, -- so that it doesn't build the rock https://github.com/3rd/image.nvim/issues/91#issuecomment-2453430239
      opts = {
  	    processor = "magick_cli",
      }
  },

  {
    "MunsMan/kitty-navigator.nvim",
    build = {
      "cp navigate_kitty.py ~/.config/kitty",
      "cp pass_keys.py ~/.config/kitty",
    },
    opts = {
      keybindings = {
        left = "<C-h>",
        down = "<C-j>",
        up = "<C-k>",
        right = "<C-l>",
      },
    },
  },
  {
    'pwntester/octo.nvim',
    commit = '604fad120e59275dfb9f67ceb369bda86e34a55e',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      require('octo').setup()
    end
  },
  'tpope/vim-unimpaired',
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      'antoinemadec/FixCursorHold.nvim',
      'nvim-neotest/neotest-plenary',
      'nvim-neotest/neotest-vim-test',
      'adrigzr/neotest-mocha',
      'nvim-neotest/nvim-nio',
    },
    config = function()
      require('neotest').setup({
        adapters = {
          require('neotest-plenary'),
          require('neotest-vim-test')({
            ignore_file_types = { 'python', 'vim', 'lua' },
          }),
          require('neotest-mocha')({
            command = 'npm test --',
            env = { CI = true },
            cwd = function()
              return vim.fn.getcwd()
            end,
          }),
        },
      })
    end,
  },

  {
    'nvim-neorg/neorg',
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-neorg/neorg-telescope' },
    tag = 'v7.0.0',
    config = function()
      require('neorg').setup {
        load = {
          ['core.defaults'] = {},  -- Loads default behaviour
          ['core.concealer'] = {}, -- Adds pretty icons to your documents
          ['core.integrations.telescope'] = {},
          ['core.dirman'] = {      -- Manages Neorg workspaces
            config = {
              workspaces = {
                notes = '~/notes',
                work = '~/notes/work',
                haLife = '~/notes/haLife',
              },
            },
          },
          ['core.export'] = {},
          ['core.export.markdown'] = {},
        },
      }
    end,
  },
  {
    'mfussenegger/nvim-dap',
    lazy = true,
    enabled = true,
    dependencies = {
      { 'mxsdev/nvim-dap-vscode-js' },
      { 'theHamsta/nvim-dap-virtual-text' },
      { 'rcarriga/nvim-dap-ui' },
      { 'nvim-telescope/telescope-dap.nvim' },
      {
        'microsoft/vscode-js-debug',
        lazy = true,
        build = 'npm ci --legacy-peer-deps && npx gulp vsDebugServerBundle && rm -rf out && mv dist out'
      }
    },
    keys = '<leader>d',
    config = function()
      require('rhodate.dap').setup()
    end
  },

  'jghauser/mkdir.nvim',

  'folke/which-key.nvim',

  {
    'heavenshell/vim-jsdoc',
    build = 'make install'
  },

  {
    'lewis6991/hover.nvim',
    config = function()
      require('hover').setup {
        init = function()
          -- Require providers
          require('hover.providers.lsp')
          require('hover.providers.gh')
          require('hover.providers.gh_user')
          require('hover.providers.jira')
          require('hover.providers.man')
          require('hover.providers.dictionary')
        end,
        preview_opts = {
          border = nil
        },
        -- Whether the contents of a currently open hover window should be moved
        -- to a :h preview-window when pressing the hover keymap.
        preview_window = false,
        title = true
      }

      -- Setup keymaps
      vim.keymap.set('n', 'K', require('hover').hover, { desc = 'hover.nvim' })
      vim.keymap.set('n', 'gK', require('hover').hover_select, { desc = 'hover.nvim (select)' })
    end
  },

  'nvim-tree/nvim-tree.lua',
  'nvim-tree/nvim-web-devicons',

  'nvim-telescope/telescope-file-browser.nvim',

  'simrat39/symbols-outline.nvim',

  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'abeldekat/harpoonline' },
    version = '*',
  },

  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    opts = {
    },
    dependencies = {
      'MunifTanjim/nui.nvim',
      'rcarriga/nvim-notify',
    }
  },

  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
  },

  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate'
  },

  {
    'nvim-treesitter/playground',
  },

  { 'neovim/nvim-lspconfig' },
  { 'williamboman/mason.nvim' },
  { 'williamboman/mason-lspconfig.nvim' },

  -- Autocompletion
  { 'hrsh7th/nvim-cmp' },
  { 'hrsh7th/cmp-buffer' },
  { 'hrsh7th/cmp-path' },
  { 'saadparwaiz1/cmp_luasnip' },
  { 'hrsh7th/cmp-nvim-lsp' },
  { 'hrsh7th/cmp-nvim-lua' },

  -- Snippets
  { 'L3MON4D3/LuaSnip' },
  -- Snippet Collection (Optional)
  { 'rafamadriz/friendly-snippets' },

  'tpope/vim-fugitive',

  'tpope/vim-rhubarb',

  'mbbill/undotree',

  {
    'folke/trouble.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
  },

  {
    'catppuccin/nvim',
    name = 'catppuccin',
    lazy = false,
    config = function()
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
    end
  },
  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
    },
  },
})
