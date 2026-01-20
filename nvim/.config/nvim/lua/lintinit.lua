require 'lint'.linters_by_ft = {
	javascript = { 'eslint_d' },
	python = { 'ruff' },
	sh = { 'shellcheck' },
}
local conform = require 'conform'
conform.setup {
	formatters = {
		biome = {
			cwd = require 'conform.util'.root_file({ 'biome.json', 'biome.config.js' }),
			require_cwd = true,
		},
	},
	formatters_by_ft = {
		javascript = { "biome", "prettierd", "prettier", "eslint_d", "eslint", stop_after_first = true, },
		typecript = { "biome", "prettierd", "prettier", "eslint_d", "eslint", stop_after_first = true, },
		typescriptreact = { "biome", "prettierd", "prettier", "eslint_d", "eslint", stop_after_first = true, },
		json = { "biome", "prettierd", "prettier", stop_after_first = true, },
		python = { "autopep8", "ruff_fix", "ruff_format", "ruff_organize_imports" },
		haskell = { "fourmolu" },
	},
}
vim.g.auto_conform = 1
function Conform()
	-- by default, also auto conform
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
