function DiagnosticsToQuickfix()
	-- get diagnostics from the current buffer
	local diagnostics = vim.diagnostic.get(0)
	-- convert to quickfix list
	local qflist = {}
	for _, diagnostic in ipairs(diagnostics) do
		local bufnr = diagnostic.bufnr
		local filename = vim.api.nvim_buf_get_name(bufnr)
		table.insert(qflist, {
			filename = filename,
			lnum = diagnostic.lnum + 1, -- Lua is 0-indexed, Vim is 1-indexed
			col = diagnostic.col + 1, -- Lua is 0-indexed, Vim is 1-indexed
			text = diagnostic.message,
			type = vim.diagnostic.severity[diagnostic.severity],
		})
	end
	-- set quickfix list
	vim.fn.setqflist(qflist)
	-- show quickfix window
	vim.cmd('copen')
end

vim.api.nvim_create_user_command('DiagnosticsCurrentFocus', DiagnosticsToQuickfix, {})

require('todo-comments').setup()
