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
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      indent = { enabled = true },
      input = { enabled = true },
      quickfile = { enabled = true },
      scope = { enabled = true },
      scroll = { enabled = true },
      statuscolumn = { enabled = true },
    },
  },

  {
      "nvim-treesitter/nvim-treesitter",
      dependencies = { "OXY2DEV/markview.nvim" },
      lazy = false,
  },

  {
    "arakkkkk/kanban.nvim",
    -- Optional
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
  
    config = function()
      require("kanban").setup({
        markdown = {
          description_folder = "./tasks/", -- Path to save the file corresponding to the task.
          list_head = "## ",
        },
      })
    end,
  },

  --{
  --  "3rd/diagram.nvim",
  --  dependencies = {
  --    "3rd/image.nvim",
  --  },
  --  config = function()
  --    require("image").setup({})
  --    require("diagram").setup({
  --      integrations = {
  --        require("diagram.integrations.markdown"),
  --        require("diagram.integrations.neorg"),
  --      },
  --      renderer_options = {
  --        mermaid = {
  --          theme = "forest",
  --          scale = 4,
  --        },
  --        plantuml = {
  --          charset = "utf-8",
  --        },
  --        d2 = {
  --          theme_id = 1,
  --        },
  --        gnuplot = {
  --          theme = "dark",
  --          size = "800,600",
  --        },
  --      }
  --    })
  --  end
  --},

  {
    'Bekaboo/dropbar.nvim',
    -- optional, but required for fuzzy finder support
    dependencies = {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
    },
    config = function()
      local dropbar_api = require('dropbar.api')
      vim.keymap.set('n', '<Leader>;', dropbar_api.pick, { desc = 'Pick symbols in winbar' })
      vim.keymap.set('n', '[;', dropbar_api.goto_context_start, { desc = 'Go to start of current context' })
      vim.keymap.set('n', '];', dropbar_api.select_next_context, { desc = 'Select next context' })
    end
  },

  {
    "kkoomen/vim-doge",
  },

  {
    "vuki656/package-info.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require('package-info').setup()
      -- Show dependency versions
      vim.keymap.set({ "n" }, "<LEADER>ns", require("package-info").show, { silent = true, noremap = true })
      -- Hide dependency versions
      vim.keymap.set({ "n" }, "<LEADER>nc", require("package-info").hide, { silent = true, noremap = true })
      -- Toggle dependency versions
      vim.keymap.set({ "n" }, "<LEADER>nt", require("package-info").toggle, { silent = true, noremap = true })
      -- Update dependency on the line
      vim.keymap.set({ "n" }, "<LEADER>nu", require("package-info").update, { silent = true, noremap = true })
      -- Delete dependency on the line
      vim.keymap.set({ "n" }, "<LEADER>nd", require("package-info").delete, { silent = true, noremap = true })
      -- Install a new dependency
      vim.keymap.set({ "n" }, "<LEADER>ni", require("package-info").install, { silent = true, noremap = true })
      -- Install a different dependency version
      vim.keymap.set({ "n" }, "<LEADER>np", require("package-info").change_version, { silent = true, noremap = true })
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

  -- {
  --   'ahmedkhalf/project.nvim',
  --   config = function()
  --     require('project_nvim').setup({
  --     })
  --   end,
  -- },

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
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
  },
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    dependencies = {
      { 'zbirenbaum/copilot.lua' },                   -- or github/copilot.vim
      { 'nvim-lua/plenary.nvim', branch = 'master' }, -- for curl, log wrapper
    },
    build = "make tiktoken",
  },
  {
    "olimorris/codecompanion.nvim",
    opts = {
      --Refer to: https://codecompanion.olimorris.dev/configuration/introduction.html
      adapters = {
        copilot = function()
          return require("codecompanion.adapters").extend("copilot", {
            schema = {
              model = {
                default = "claude-3.7-sonnet",
              },
            },
          })
        end,
      },
      strategies = {
        chat = { adapter = "copilot" },
        inline = { adapter = "copilot" },
        agent = { adapter = "copilot" },
      },
      opts = {
        log_level = "DEBUG",
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
      'Nsidorenco/neotest-vstest',
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
          require('neotest-vstest')({
            dap_settings = {
              type = 'coreclr',
            },
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
      },
    },
    keys = '<leader>e',
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
  { 'Decodetalkers/csharpls-extended-lsp.nvim' },

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
