local whichkey = require "which-key"

-- local function keymap(lhs, rhs, desc)
--   vim.keymap.set("n", lhs, rhs, { silent = true, desc = desc })
-- end

return {
  setup = function()
    local keymap = {
      {
        "<leader>eB",
        "<cmd>lua require'dap'.toggle_breakpoint()<cr>",
        desc = "Toggle Breakpoint",
        nowait = false,
        remap = false
      },
      {
        "<leader>eC",
        "<cmd>lua require'dap'.set_breakpoint(vim.fn.input '[Condition] > ')<cr>",
        desc = "Conditional Breakpoint",
        nowait = false,
        remap = false
      },
      {
        "<leader>eE",
        "<cmd>lua require'dapui'.eval(vim.fn.input '[Expression] > ')<cr>",
        desc = "Evaluate Input",
        nowait = false,
        remap = false
      },
      {
        "<leader>eR",
        "<cmd>lua require'dap'.run_to_cursor()<cr>",
        desc = "Run to Cursor",
        nowait = false,
        remap = false
      },
      {
        "<leader>eS",
        "<cmd>lua require'dap.ui.widgets'.scopes()<cr>",
        desc = "Scopes",
        nowait = false,
        remap = false
      },
      {
        "<leader>eU",
        "<cmd>lua require'dapui'.toggle()<cr>",
        desc = "Toggle UI",
        nowait = false,
        remap = false
      },
      {
        "<leader>eb",
        "<cmd>lua require'dap'.step_back()<cr>",
        desc = "Step Back",
        nowait = false,
        remap = false
      },
      {
        "<leader>ec",
        "<cmd>lua require'dap'.continue()<cr>",
        desc = "Continue",
        nowait = false,
        remap = false
      },
      {
        "<leader>ed",
        "<cmd>lua require'dap'.disconnect()<cr>",
        desc = "Disconnect",
        nowait = false,
        remap = false
      },
      {
        "<leader>ee",
        "<cmd>lua require'dapui'.eval()<cr>",
        desc = "Evaluate",
        nowait = false,
        remap = false
      },
      {
        "<leader>eg",
        "<cmd>lua require'dap'.session()<cr>",
        desc = "Get Session",
        nowait = false,
        remap = false
      },
      {
        "<leader>eh",
        "<cmd>lua require'dap.ui.widgets'.hover()<cr>",
        desc = "Hover Variables",
        nowait = false,
        remap = false
      },
      {
        "<leader>ei",
        "<cmd>lua require'dap'.step_into()<cr>",
        desc = "Step Into",
        nowait = false,
        remap = false
      },
      {
        "<leader>eo",
        "<cmd>lua require'dap'.step_over()<cr>",
        desc = "Step Over",
        nowait = false,
        remap = false
      },
      {
        "<leader>ep",
        "<cmd>lua require'dap'.pause.toggle()<cr>",
        desc = "Pause",
        nowait = false,
        remap = false
      },
      {
        "<leader>eq",
        "<cmd>lua require'dap'.close()<cr>",
        desc = "Quit",
        nowait = false,
        remap = false
      },
      {
        "<leader>er",
        "<cmd>lua require'dap'.repl.toggle()<cr>",
        desc = "Toggle Repl",
        nowait = false,
        remap = false
      },
      {
        "<leader>es",
        "<cmd>lua require'dap'.continue()<cr>",
        desc = "Start",
        nowait = false,
        remap = false
      },
      {
        "<leader>eu",
        "<cmd>lua require'dap'.step_out()<cr>",
        desc = "Step Out",
        nowait = false,
        remap = false
      },
      {
        "<leader>ex",
        "<cmd>lua require'dap'.terminate()<cr>",
        desc = "Terminate",
        nowait = false,
        remap = false
      },
    }


    whichkey.add(keymap)

    local keymap_v = {
      {
        "<leader>e",
        "<cmd>lua require'dapui'.eval()<cr>",
        desc = "Evaluate",
        mode = "v",
        nowait = false,
        remap = false
      },
    }

    whichkey.add(keymap_v)
  end
}
