require 'lint'.linters_by_ft = {
	javascript = { 'eslint_d' },
	python = { 'ruff' },
	sh = { 'shellcheck' },
}
local conform = require 'conform'
conform.setup {
	stop_after_first = true,
	formatters_by_ft = {
		javascript = { "oxfmt", "oxlint", "biome", "prettierd", "prettier", "eslint_d", "eslint", stop_after_first = true, },
		typescript = { "oxfmt", "oxlint", "biome", "prettierd", "prettier", "eslint_d", "eslint", stop_after_first = true, },
		typescriptreact = { "oxfmt", "oxlint", "biome", "prettierd", "prettier", "eslint_d", "eslint", stop_after_first = true, },
		json = { "oxfmt", "oxlint", "biome", "prettierd", "prettier", stop_after_first = true, },
		jsonc = { "oxfmt", "oxlint", "biome", "prettierd", "prettier", stop_after_first = true, },
		python = { "autopep8", "ruff_fix", "ruff_format", "ruff_organize_imports", stop_after_first = true, },
		haskell = { "fourmolu", stop_after_first = true, },
	},
}
vim.g.auto_conform = 1
function Conform()
	if vim.b.auto_conform == 1 or (vim.b.auto_conform == nil and vim.g.auto_conform == 1) then
		conform.format({ bufnr = vim.api.nvim_get_current_buf(), lsp_format = "fallback" })
	end
end

function ToggleAutoConform()
	if vim.b.auto_conform == 1 or vim.b.auto_conform == nil then
		vim.b.auto_conform = 0
		print('AutoConform disabled')
	else
		vim.b.auto_conform = 1
		print('AutoConform enabled')
	end
end
