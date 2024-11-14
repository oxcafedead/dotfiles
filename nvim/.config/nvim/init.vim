" netrw prewiew to 1:
let g:netrw_banner = 0
let g:netrw_preview   = 1
let g:netrw_winsize   = 30

call plug#begin(stdpath('data') . '/plugged')
" LSP Support & linting
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'L3MON4D3/LuaSnip'
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'rshkarin/mason-nvim-lint'
Plug 'neovim/nvim-lspconfig'
Plug 'VonHeikemen/lsp-zero.nvim', {'branch': 'v3.x'}
Plug 'mfussenegger/nvim-lint'
Plug 'stevearc/conform.nvim'
Plug 'ThePrimeagen/refactoring.nvim'
" Etc
Plug 'tpope/vim-dotenv'
Plug 'tpope/vim-fugitive'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'stevearc/aerial.nvim', {'tag': '*'}
Plug 'github/copilot.vim'
Plug 'LunarVim/bigfile.nvim'
Plug 'tpope/vim-dispatch'
Plug 'BurntSushi/ripgrep'
Plug 'nvim-lua/plenary.nvim', {'tag': '*'}
Plug 'nvim-telescope/telescope.nvim'
Plug 'terrortylor/nvim-comment'
Plug 'folke/todo-comments.nvim'
Plug 'elzr/vim-json'
" Debug
Plug 'michaelb/sniprun', { 'tag': '*', 'do': 'sh ./install.sh' }
Plug 'puremourning/vimspector'
Plug 'oxcafedead/vimyac'

" Tests
Plug 'vim-test/vim-test'
" Coverage
Plug 'google/vim-maktaba'
Plug 'andythigpen/nvim-coverage'
Plug 'google/vim-glaive'

" Colors and visual
Plug 'rose-pine/neovim'
Plug 'lifepillar/vim-solarized8', {'branch': 'neovim'}
Plug 'oxcafedead/auto-dark-mode.nvim', {'branch': 'fix_reg_wsl'}

" Dispatch comiple plugin
Plug '5long/pytest-vim-compiler'
Plug 'oxcafedead/vitest-vim-compiler'
call plug#end()

" Visual and UI / mappings

set number
set relativenumber
set nowrap

set termguicolors
colorscheme solarized8
lua << EOF
require('auto-dark-mode').setup()
EOF

inoremap jk <esc>

nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
nnoremap <leader>fr <cmd>Telescope oldfiles<cr>
nnoremap <C-p> <cmd>Telescope git_files<cr>
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

nnoremap <leader>s :%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>
" same but for visual mode:
vnoremap <leader>s y:%s/\V<C-R>=escape(@",'/\')<CR>/<C-R>"/g<Left><Left>

nnoremap <leader>y "+y
nnoremap <leader>Y "+Y
nnoremap <leader>p "+p
nnoremap <leader>P "+P

" Language support, refactoring...

lua << EOF
-- Treesitter
require'nvim-treesitter.configs'.setup {
	ensure_installed = { "c", "java", "javascript", "lua", "vim", "vimdoc", "query", "http", "json" },
	auto_install = true,
	highlight = {
		enable = true,
	},
	indent = {
		enable = true,
	},
}
require'aerial'.setup {
	-- optionally use on_attach to set keymaps when aerial has attached to a buffer
	on_attach = function(bufnr)
	-- Jump forwards/backwards with '{' and '}'
	vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
	vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
	end,
}
vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle!<CR>")
-- LSP
local lsp_zero = require('lsp-zero')
lsp_zero.on_attach(function(client, bufnr)
lsp_zero.default_keymaps({buffer = bufnr, preserve_mappings = false}) 
end)
require'mason'.setup {}
require'mason-lspconfig'.setup {
	ensure_installed = {'vimls'},
	handlers = {
		lsp_zero.default_setup,
	},
}
require'mason-nvim-lint'.setup {
	-- ensure_installed = {'eslint_d', 'ruff'}, -- will be set manually
}
require'lspconfig'.basedpyright.setup {
	settings = {
		basedpyright = {
			analysis = {
				-- turn off annoying strict mode
				typeCheckingMode = "basic",
			},
		},
	},
}

require('nvim_comment').setup()
require('todo-comments').setup()


-- Telescope
local telescope = require("telescope")
local telescopeConfig = require("telescope.config")

telescope.setup {
	defaults = {
		vimgrep_arguments = {
			'rg',
			'--color=never',
			'--no-heading',
			'--with-filename',
			'--line-number',
			'--column',
			'--smart-case',
			'--hidden',
			'--glob',
			'!**/.git/*',
		},
	},
	pickers = {
		find_files = {
			find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*", },
		},
	},	
}


require'lint'.linters_by_ft = {
	javascript = {'eslint_d'},
	-- python = {'ruff'}, -- ruff linter automatically registers as LSP and duplicates the linting
	sh = {'shellcheck'},
}
local conform = require'conform'
conform.setup {
	formatters_by_ft = {
		javascript = { { "prettierd", "prettier" }, { "eslint_d", "eslint" } },
		python = { "autopep8", "ruff_fix", "ruff_format", "ruff_organize_imports" },
	},
}
vim.g.auto_conform = 1
function Conform()
	-- by default, also auto conform
	if vim.b.auto_conform == 1 or ( vim.b.auto_conform == nil and vim.g.auto_conform == 1 ) then
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
EOF
autocmd BufWritePost,BufReadPost,InsertLeave,TextChanged,TextChangedI * lua require'lint'.try_lint()
command! AutoConform :lua ToggleAutoConform()
command! Conform :lua Conform()
autocmd BufWritePre * Conform

" Debugger func...
" let g:vimspector_enable_mappings = 'HUMAN'
nmap <F5> <Plug>VimspectorContinue
nmap <Leader>di <Plug>VimspectorBalloonEval
nmap <F6> :VimspectorReset<CR>
nmap <F9> <Plug>VimspectorToggleBreakpoint
nmap <Leader><F9> <Plug>VimspectorToggleConditionalBreakpoint
nmap <F10> <Plug>VimspectorStepOver
nmap <F11> <Plug>VimspectorStepInto
nmap <F12> <Plug>VimspectorStepOut


" Tests
nmap <silent> <leader>t :TestNearest<CR>
nmap <silent> <leader>T :TestFile<CR>

lua << EOF
require("coverage").setup({})
EOF
nmap <leader>cs :CoverageShow<CR>
nmap <leader>cc :CoverageToggle<CR>
nmap <leader>cl :CoverageLoad<CR>

" Useful functions of mine, utils
function! JsEscFunction(text) 
	let input_text = a:text ==# '' ? getreg('+') : a:text
	let escaped_text = substitute(input_text, '\v"|\n', '\=submatch(0) == "\"" ? "\\\"" : "\\n"', 'g') 
	call setreg('+', escaped_text)
	echo 'Escaped JSON string'
endfunction

function! JsDescFunction(text)
	let input_text = a:text ==# '' ? getreg('+') : a:text
	let desc_text = substitute(input_text, '\\"', '"', 'g')
	let desc_text = substitute(desc_text, '\\n', "\n", 'g')
	call setreg('+', desc_text)
	echo 'De-escaped JSON string'
endfunction

function! ExtractJwt(rawJwt)
	let jwt = a:rawJwt ==# '' ? getreg('+') : a:rawJwt
	" const payload = JSON.parse(atob(parts[1].replace(/_/g, '/').replace(/-/g, '+')));
	let jwt = substitute(jwt, '_', '/', 'g')
	let jwt = substitute(jwt, '-', '+', 'g')
	let result = system('echo '.jwt.' | cut -d. -f2 | base64 -d')
	echo result
	call setreg('+', result)
	echo '-----------------'
	echo 'Extracted JWT payload and saved to clipboard'
endfunction

function! YankCurrentLineAnchor()
	let line_number = line('.')
	let rel_file_path = expand('%:~:.')
	let anchor = rel_file_path.':'.line_number
	call setreg('+', anchor)
	echo 'Yanked ' . anchor
endfunction

command! -nargs=? JsEsc :call JsEscFunction(<q-args>)
command! -nargs=? JsDesc :call JsDescFunction(<q-args>)
command! -nargs=? JwtExt :call ExtractJwt(<q-args>)
command! YankAnchor :call YankCurrentLineAnchor()
nnoremap <leader>^ :YankAnchor<CR>

" Python 3 interpreter for core neovim functions
let g:python3_host_prog = expand('$HOME/globalvenvs/nvim/bin/python3')

" Copilot
autocmd BufRead,BufNewFile *.env set ft=env
let g:copilot_filetypes = {
			\ 'env': v:false,
			\ 'gitcommit': v:true,
			\ }

" Clipboard hacks
" if win32yank.exe is available in $PATH
if executable('win32yank.exe')
	let g:clipboard = {
				\'name': 'win32yank', 
				\ 'copy': { '+': 'win32yank.exe -i --crlf', '*': 'win32yank.exe -i --crlf', }, 
				\ 'paste': { '+': 'win32yank.exe -o --lf', '*': 'win32yank.exe -o --lf', }, 
				\ 'cache_enabled': 0,
				\}
endif

let g:vim_json_syntax_conceal = 0

" Spelling! Very important for such people like me who can't spell
autocmd BufRead,BufNewFile *.md,COMMIT_EDITMSG setlocal spell spelllang=en_us

" Telescope & LSP, lsp_dynamic_workspace_symbols to search for symbols in the
" workspace
nmap <leader>ws :Telescope lsp_dynamic_workspace_symbols<CR>

" Vim test stuff
let test#strategy = "dispatch"

let g:dispatch_compilers = {
			\ 'vitest': 'node_modules/.bin/vitest',
			\ 'pytest': 'pytest',
			\ 'python -m pytest': 'pytest',
			\ 'python3 -m pytest': 'pytest' }

" Finally, exrc
set exrc
