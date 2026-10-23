-- Neovim only extras

-- Snippets
local ok, ls = pcall(require, 'luasnip')
if ok then
  ls.setup({ enable_autosnippets = true, update_events = 'TextChanged,TextChangedI' })
  require('luasnip.loaders.from_lua').lazy_load({ paths = { vim.fn.stdpath('config') .. '/snippets' } })
  vim.keymap.set({ 'i', 's' }, '<C-j>', function() if ls.expand_or_jumpable() then ls.expand_or_jump() end end)
  vim.keymap.set({ 'i', 's' }, '<C-k>', function() if ls.jumpable(-1) then ls.jump(-1) end end)
end

-- Keymap popup
local ok_wk, wk = pcall(require, 'which-key')
if ok_wk then
  wk.setup({ preset = 'classic' })
  wk.add({
    { '<leader>b', group = 'buffers' },
    { '<leader>c', group = 'comment' },
    { '<leader>f', group = 'find' },
    { '<leader>h', group = 'git hunks' },
    { '<leader>s', group = 'spell' },
    { '<leader>t', group = 'tabs' },
  })
end

-- Git signs
local ok_gs, gs = pcall(require, 'gitsigns')
if ok_gs then
  gs.setup({
    on_attach = function(buf)
      local function map(mode, l, r, desc) vim.keymap.set(mode, l, r, { buffer = buf, desc = desc }) end
      map('n', ']c', function()
        if vim.wo.diff then vim.cmd.normal({ ']c', bang = true }) else gs.nav_hunk('next') end
      end, 'Next hunk')
      map('n', '[c', function()
        if vim.wo.diff then vim.cmd.normal({ '[c', bang = true }) else gs.nav_hunk('prev') end
      end, 'Previous hunk')
      map('n', '<leader>hs', gs.stage_hunk, 'Stage hunk')
      map('n', '<leader>hr', gs.reset_hunk, 'Reset hunk')
      map('n', '<leader>hu', gs.undo_stage_hunk, 'Undo stage')
      map('n', '<leader>hp', gs.preview_hunk, 'Preview hunk')
      map('n', '<leader>hb', function() gs.blame_line({ full = true }) end, 'Blame line')
      map('n', '<leader>hd', gs.diffthis, 'Diff file')
    end,
  })
end

-- fzf
local ok_fzf, fzf = pcall(require, 'fzf-lua')
if ok_fzf and vim.fn.executable('fzf') == 1 then
  fzf.setup({})
  -- Project root
  local function project_dir()
    local root = vim.fs.root(0, '.git')
    local dir = vim.fn.expand('%:p:h')
    return root or (dir ~= '' and dir or vim.fn.getcwd())
  end
  vim.keymap.set('n', '<leader>ff', fzf.files, { desc = 'Files' })
  vim.keymap.set('n', '<leader>fp', function() fzf.files({ cwd = project_dir() }) end, { desc = 'Project files' })
  -- CtrlP keys
  vim.keymap.set('n', '<leader>t', function() fzf.files({ cwd = project_dir() }) end, { desc = 'Project files' })
  vim.keymap.set('n', '<leader>b', fzf.buffers, { desc = 'Buffers' })
  vim.keymap.set('n', '<leader>fb', fzf.buffers, { desc = 'Buffers' })
  vim.keymap.set('n', '<leader>fr', fzf.oldfiles, { desc = 'Recent files' })
  vim.keymap.set('n', '<leader>fg', fzf.live_grep, { desc = 'Grep' })
  vim.keymap.set('n', '<leader>fw', fzf.grep_cword, { desc = 'Grep word' })
  vim.keymap.set('n', '<leader>fh', fzf.helptags, { desc = 'Help' })
  vim.keymap.set('n', '<leader>fk', fzf.keymaps, { desc = 'Keymaps' })
end

-- Language servers
if vim.fn.has('nvim-0.11') == 0 then return end

vim.diagnostic.config({ virtual_text = true })
vim.o.completeopt = 'menuone,noselect,popup'

local servers = { 'clangd', 'rust_analyzer', 'ruff', 'basedpyright', 'lua_ls', 'texlab',
                  'html', 'cssls', 'jsonls', 'ts_ls' }
local bins = {
  html = 'vscode-html-language-server', cssls = 'vscode-css-language-server',
  jsonls = 'vscode-json-language-server', ts_ls = 'typescript-language-server',
}
for _, name in ipairs(servers) do
  local cmd = (vim.lsp.config[name] or {}).cmd
  local bin = bins[name] or (type(cmd) == 'table' and cmd[1])
  if bin and vim.fn.executable(bin) == 1 then
    vim.lsp.enable(name)
  end
end

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
    end
    -- Autoformat
    vim.keymap.set('n', '<F3>', vim.lsp.buf.format, { buffer = args.buf })
  end,
})

-- Markdown: regex syntax highlights inline HTML, treesitter has no html parser
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'markdown',
  callback = function(args)
    vim.treesitter.stop(args.buf)
    vim.bo[args.buf].syntax = 'markdown'
  end,
})
