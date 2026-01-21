-- I am more used to these keymaps:
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover documentation" })
vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "List references" })
vim.keymap.set("n", "]d", function()
	vim.diagnostic.goto_next()
	vim.diagnostic.open_float()
end, { desc = "Next diagnostic" })
vim.keymap.set("n", "[d", function()
	vim.diagnostic.goto_prev()
	vim.diagnostic.open_float()
end, { desc = "Previous diagnostic" })
vim.keymap.set("n", "gs", vim.lsp.buf.signature_help, { desc = "Signature help" })
vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, { desc = "Rename symbol" })
vim.keymap.set("n", "<F3>", function()
	vim.lsp.buf.format({ async = true })
end, { desc = "Format buffer" })
vim.keymap.set("n", "<F4>", vim.lsp.buf.code_action, { desc = "Code action" })

require 'mason'.setup {}
require 'mason-nvim-lint'.setup {
	ensure_installed = { 'eslint_d', 'ruff' }, -- will be set manually
}

function LspInfo()
	vim.cmd('checkhealth lsp')
end

vim.cmd('command! LspInfo lua LspInfo()')
vim.cmd('command! LspLog tabnew ' .. vim.lsp.get_log_path())

local servers = { 'vimls', 'lua_ls', 'ts_ls', 'ty' }
for _, server in ipairs(servers) do
	vim.lsp.enable(server)
end
