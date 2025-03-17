vim.o.sessionoptions="blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

require('auto-session').setup {
  auto_session_use_git_branch = true,
  auto_save_enabled = true,
  auto_session_supress_dirs = { '~/', '~/code', '/', '~/Downloads' },

  session_lens = {
    load_on_setup = true,
    previewer = true,
  }
}

vim.keymap.set('n', '<leader>fse', require('auto-session.session-lens').search_session)
