call plug#begin(stdpath('data') . '/plugged')
" LSP Support
Plug 'neovim/nvim-lspconfig'
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
Plug 'nvim-treesitter/nvim-treesitter', {'tag': 'v0.9.2'}
Plug 'stevearc/aerial.nvim', {'tag': 'v1.4.0'}
Plug 'github/copilot.vim'
Plug 'catppuccin/nvim', { 'as': 'catppuccin' }
Plug 'BurntSushi/ripgrep'
Plug 'nvim-lua/plenary.nvim'
Plug 'ThePrimeagen/vim-be-good'
Plug 'nvim-telescope/telescope.nvim'
Plug 'puremourning/vimspector'
Plug 'BlackLight/nvim-http'
Plug 'terrortylor/nvim-comment'
Plug 'folke/todo-comments.nvim'

" Tests
Plug 'vim-test/vim-test'
"Coverage
Plug 'google/vim-maktaba'
Plug 'google/vim-coverage'
Plug 'google/vim-glaive'
call plug#end()

set number
set relativenumber
set nowrap

lua << EOF
require("catppuccin").setup({
	flavour = "frappe", -- latte, frappe, macchiato, mocha
        background = { -- :h background
	        light = "latte",
		dark = "mocha",
	},
	transparent_background = false, 
	dim_inactive = {
		enabled = false, -- dims the background color of inactive window
		shade = "dark",
		percentage = 0.15, -- percentage of the shade to apply to the inactive window
	},
})
EOF
" colorscheme catppuccin

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
"same but for visual mode:
vnoremap <leader>s y:%s/\V<C-R>=escape(@",'/\')<CR>/<C-R>"/g<Left><Left>

nnoremap <leader>y "+y
nnoremap <leader>Y "+Y

lua << EOF
-- Treesitter
require'nvim-treesitter.configs'.setup {
	ensure_installed = { "c", "java", "javascript", "lua", "vim", "vimdoc", "query" },
	auto_install = true,
	highlight = {
		enable = true,
	},
}
-- Tree sitter file structure
require("aerial").setup({
-- optionally use on_attach to set keymaps when aerial has attached to a buffer
on_attach = function(bufnr)
-- Jump forwards/backwards with '{' and '}'
vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
end,
})
-- You probably also want to set a keymap to toggle aerial
vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle!<CR>")
-- LSP
local lsp_zero = require('lsp-zero')
lsp_zero.on_attach(function(client, bufnr)
lsp_zero.default_keymaps({buffer = bufnr})
end)
require('mason').setup({})
require('mason-lspconfig').setup({
ensure_installed = {'tsserver', 'eslint', 'rust_analyzer', 'jsonls', 'vimls', 'pyright'},
handlers = {
	lsp_zero.default_setup,
	},
})
-- vim.lsp.set_log_level("debug")

-- Never request typescript-language-server for formatting
vim.lsp.buf.format {
	filter = function(client) return client.name ~= "tsserver" end
}
-- Telescope

require('telescope').setup{
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
	},
}
}
EOF

" Formatting
"autocmd FileType python noremap <buffer> <F3> :call Autopep8()<CR>
let g:autopep8_disable_show_diff=1
augroup autopep8
     autocmd!
     autocmd BufWritePre *.py Autopep8
augroup END

" Debugger func...
let g:vimspector_enable_mappings = 'VISUAL_STUDIO'

" Python 3 idiotic stuff
let g:python3_host_prog = '/usr/bin/python3'

" Tests
nmap <silent> <leader>t :TestNearest<CR>
nmap <silent> <leader>T :TestFile<CR>
let test#python#runner = 'pyunit'

" Also add Glaive, which is used to configure coverage's maktaba flags. See
" `:help :Glaive` for usage.
call glaive#Install()
" Optional: Enable coverage's default mappings on the <Leader>C prefix.
Glaive coverage plugin[mappings]

let s:covplugin = maktaba#plugin#Get('coverage')
let s:covplugin.globals._gcov_temp_search_paths =[ './coverage']
let s:covplugin.globals._gcov_temp_file_patterns = ['*.info']

" Sandboxing
function! JsEscFunction(text) 
	let input_text = a:text ==# '' ? getreg('+') : a:text
	let escaped_text = substitute(input_text, '\v"|\n', '\=submatch(0) == "\"" ? "\\\"" : "\\n"', 'g') 
	call setreg('+', escaped_text)
	echo 'Escaped JSON string'
endfunction

command! -nargs=? JsEsc :call JsEscFunction(<q-args>)

function! JsDescFunction(text)
	let input_text = a:text ==# '' ? getreg('+') : a:text
	let desc_text = substitute(input_text, '\\"', '"', 'g')
	let desc_text = substitute(desc_text, '\\n', "\n", 'g')
	call setreg('+', desc_text)
	echo 'De-escaped JSON string'
endfunction

command! -nargs=? JsDesc :call JsDescFunction(<q-args>)

" Etc
lua << EOF
require('nvim_comment').setup()
require('todo-comments').setup()
EOF
