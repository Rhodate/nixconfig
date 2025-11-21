vim.diagnostic.config({ virtual_text = true, virtual_lines = true });

vim.api.nvim_create_autocmd('LspAttach', {
  desc = "LSP Setup",
  callback = function(event)
    local opts = { buffer = event.buf }

    vim.keymap.set("n", "gD", function() vim.lsp.buf.declaration() end, opts)
    vim.keymap.set("n", "gd", function() require('telescope.builtin').lsp_definitions() end, opts)
    vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
    vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ diagnostic = vim.diagnostic.get_next() }) end, opts)
    vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ diagnostic = vim.diagnostic.get_prev() }) end, opts)
    vim.keymap.set("n", "<leader>ca", function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set("n", "<leader>rr", function() vim.lsp.buf.references() end, opts)
    vim.keymap.set("n", "<leader>rn", function() vim.lsp.buf.rename() end, opts)
    vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
  end
})

local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()

require('mason').setup({})
require('mason-lspconfig').setup({
  ensure_installed = { 'eslint', 'ts_ls', 'rust_analyzer', 'csharp_ls' },
  handlers = {
    -- Default setup
    function(server)
      require('lspconfig')[server].setup({
        capabilities = lsp_capabilities,
        settings = {
          Lua = {
            diagnostics = {
              globals = { 'vim' }
            },
            workspace = {
              library = {
                vim.env.VIMRUNTIME
              },
            },
          }
        },
      })
    end,
    lua_ls = function()
      require('lspconfig').lua_ls.setup({
        capabilities = lsp_capabilities,
      })
    end,
    csharp_ls = function()
      require('lspconfig').csharp_ls.setup({
        capabilities = lsp_capabilities,
        root_dir = function(fname)
          return require('lspconfig.util').root_pattern("*.sln")(fname) or
          require('lspconfig.util').root_pattern("*.csproj")(fname)
        end,
        handlers = {
          ["textDocument/definition"] = require('csharpls_extended').handler,
          ["textDocument/typeDefinition"] = require('csharpls_extended').handler,
        },
        command = "csharp-ls";
      })
      require("csharpls_extended").buf_read_cmd_bind()
      require("telescope").load_extension("csharpls_definition")
    end,
    nil_ls = function()
      require('lspconfig').nil_ls.setup({
        settings = {
          ['nil'] = {
            formatting = {
              command = { "nixfmt" },
            },
          },
        },
      })
    end
  }
})

local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }
cmp.setup({
  sources = {
    { name = 'path' },
    { name = 'nvim_lsp' },
    { name = 'nvim_lua' },
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
    ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
    ['<cr>'] = cmp.mapping.confirm({ select = true }),
    ["<C-Space>"] = cmp.mapping.complete(),
  }),
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
})

vim.lsp.set_log_level("INFO")
