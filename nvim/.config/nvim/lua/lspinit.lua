-- I am more used to these keymaps:
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover documentation" })
vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "List references" })
-- next diagnostic (and show it in a floating window)
vim.keymap.set("n", "]d", function()
	vim.diagnostic.goto_next()
	vim.diagnostic.open_float()
end, { desc = "Next diagnostic" })
vim.keymap.set("n", "[d", function()
	vim.diagnostic.goto_prev()
	vim.diagnostic.open_float()
end, { desc = "Previous diagnostic" })
require 'mason'.setup {}
require 'mason-nvim-lint'.setup {
	ensure_installed = { 'eslint_d', 'ruff' }, -- will be set manually
}

function LspInfo()
	vim.cmd('checkhealth lsp')
end

vim.cmd('command! LspInfo lua LspInfo()')
-- open lsp log file in a new tab
vim.cmd('command! LspLog tabnew ' .. vim.lsp.get_log_path())

local servers = { 'vimls', 'lua_ls', 'ts_ls', 'ty' }
for _, server in ipairs(servers) do
	vim.lsp.enable(server)
end
