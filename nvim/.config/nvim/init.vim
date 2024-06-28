call plug#begin(stdpath('data') . '/plugged')
" LSP Support
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'L3MON4D3/LuaSnip'
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'VonHeikemen/lsp-zero.nvim', {'branch': 'v3.x'}
Plug 'tell-k/vim-autopep8'
" Etc
Plug 'tpope/vim-fugitive'
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'stevearc/aerial.nvim', {'tag': '*'}
Plug 'github/copilot.vim'
Plug 'catppuccin/nvim', { 'as': 'catppuccin' }
Plug 'rose-pine/neovim', { 'as': 'rose-pine' }
Plug 'BurntSushi/ripgrep'
Plug 'nvim-lua/plenary.nvim', {'tag': '*'}
Plug 'ThePrimeagen/vim-be-good'
Plug 'nvim-telescope/telescope.nvim'
Plug 'puremourning/vimspector'
Plug 'terrortylor/nvim-comment'
Plug 'folke/todo-comments.nvim'
Plug 'michaelb/sniprun', { 'tag': '*', 'do': 'sh ./install.sh' }
Plug 'elzr/vim-json'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && npx --yes yarn install', 'tag': '*' }
" Tests
Plug 'vim-test/vim-test'
"Coverage
Plug 'google/vim-maktaba'
Plug 'google/vim-coverage'
Plug 'google/vim-glaive'

Plug 'oxcafedead/vimyac'
call plug#end()

" Visual and UI / mappings

set number
set relativenumber
set nowrap

lua << EOF
require("catppuccin").setup({
	flavour = "frappe", 
	transparent_background = true, 
})
-- require("rose-pine").setup({ disable_background = false })
EOF
" colorscheme catppuccin
colorscheme rose-pine

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
	ensure_installed = {'tsserver', 'eslint', 'rust_analyzer', 'jsonls', 'vimls', 'pyright'},
	handlers = {
		lsp_zero.default_setup,
	},
}
-- vim.lsp.set_log_level("debug")

-- Never request typescript-language-server for formatting
local lspconfig = require"lspconfig"
 
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
EOF

" Formatting
let g:autopep8_disable_show_diff=1
augroup autopep8
	autocmd!
	autocmd BufWritePre *.py if filereadable(".pep8") | Autopep8
augroup END
augroup autoeslint
	autocmd!
	autocmd BufWritePre *.js if filereadable(".eslintrc.json") | EslintFixAll
augroup END


lua << EOF
_G.lsp_organize_imports = function()
local params = {
	command = "_typescript.organizeImports",
	arguments = {vim.api.nvim_buf_get_name(0)},
	title = ""
}
vim.lsp.buf.execute_command(params)
end
EOF

command! LspOrganize lua lsp_organize_imports()

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

" Also add Glaive, which is used to configure coverage's maktaba flags. See
" `:help :Glaive` for usage.
call glaive#Install()
" Optional: Enable coverage's default mappings on the <Leader>C prefix.
Glaive coverage plugin[mappings]

let s:covplugin = maktaba#plugin#Get('coverage')
let s:covplugin.globals._gcov_temp_search_paths =[ './coverage']
let s:covplugin.globals._gcov_temp_file_patterns = ['*.info']

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
let g:python3_host_prog = '/usr/bin/python3'

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

" Markdown preview
nmap <leader>md <Plug>MarkdownPreviewToggle
