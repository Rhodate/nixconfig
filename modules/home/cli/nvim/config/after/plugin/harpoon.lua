local harpoon = require('harpoon')
local extensions = require('harpoon.extensions')

harpoon:setup({
  settings = {
    save_on_toggle = true,
    sync_on_ui_close = true,
  },
})

vim.keymap.set('n', '<leader>ha', function() harpoon:list():add() end)
vim.keymap.set('n', '<leader>hr', function() harpoon:list():remove() end)
vim.keymap.set('n', '<leader>hd', function() harpoon:list():remove_at(vim.v.count1) end)

vim.keymap.set('n', 'gh', function() harpoon:list():select(vim.v.count1) end)

vim.keymap.set('n', '[h', function() harpoon:list():prev() end)
vim.keymap.set('n', ']h', function() harpoon:list():next() end)

vim.keymap.set('n', '<leader>hu', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

-- Telescope harpoon setup
do
  local conf = require('telescope.config').values
  local pickers = require("telescope.pickers")
  local themes = require("telescope.themes")
  local finders = require("telescope.finders")
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local function list_indexOf(list, predicate)
    for i, v in ipairs(list) do
      if predicate(v) then
        return i
      end
    end
    return -1
  end

  local function generate_harpoon_finder(harpoon_files)
    local file_paths = {}
    for _, item in ipairs(harpoon_files.items) do
      table.insert(file_paths, item.value)
    end
    return finders.new_table({
      results = file_paths
    })
  end

  local function toggle_telescope(harpoon_files)
    pickers.new({}, {
      prompt_title = 'Harpoon',
      finder = generate_harpoon_finder(harpoon_files),
      previewer = conf.file_previewer({}),
      sorter = conf.generic_sorter({}),
      initial_mode = 'normal',
      attach_mappings = function(_, map)
        actions.select_default:replace(function(prompt_bufnr)
          local curr_entry = action_state.get_selected_entry()
          if not curr_entry then
            return
          end
          actions.close(prompt_bufnr)
          harpoon:list():select(curr_entry.index)
        end)

        map({ 'i', 'n' }, '<C-d>', function(prompt_bufnr)
          local curr_picker = action_state.get_current_picker(prompt_bufnr)
          curr_picker:delete_selection(function(selection)
            harpoon:list():remove_at(selection.index)
          end)
        end)

        return true
      end,
    }):find()
  end

  vim.keymap.set('n', '<leader>hh', function() toggle_telescope(harpoon:list()) end, { desc = 'Open harpoon window' })
end
