DEBUGGER_PATH = vim.fn.expand("~/.config/vscode-js-debug")

return {
  setup = function()
    local dap = require("dap")
    require("dap-vscode-js").setup {
      node_path = "node",
      debugger_path = DEBUGGER_PATH,
      adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost", "node", "chrome" }, -- which adapters to register in nvim-dap
    }

    require("dap.ext.vscode").load_launchjs(nil,
      { ['pwa-node'] = { 'javascript', 'typescript' }, ['node'] = { 'typescript', 'javascript' } })
  end
}
