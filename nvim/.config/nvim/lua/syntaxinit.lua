-- Treesitter
require 'nvim-treesitter.configs'.setup {
	ensure_installed = { "c", "java", "javascript", "lua", "vim", "vimdoc", "query", "http", "json" },
	auto_install = true,
	highlight = {
		enable = true,
	},
	indent = {
		enable = true,
	},
}

require 'aerial'.setup {
	-- optionally use on_attach to set keymaps when aerial has attached to a buffer
	on_attach = function(bufnr)
		-- Jump forwards/backwards with '{' and '}'
		vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
		vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
	end,
}
vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle!<CR>")
