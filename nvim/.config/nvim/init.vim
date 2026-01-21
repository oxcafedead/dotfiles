" netrw prewiew to 1:
let g:netrw_banner = 0
let g:netrw_preview   = 1
let g:netrw_winsize   = 30

call plug#begin(stdpath('data') . '/plugged')
Plug 'neovim/nvim-lspconfig', {'tag': 'v2.*'}
Plug 'stevearc/conform.nvim', {'tag': 'v9.*'}
Plug 'williamboman/mason.nvim', {'tag': 'v2.*'}
Plug 'rshkarin/mason-nvim-lint'
Plug 'mfussenegger/nvim-lint'

Plug 'ThePrimeagen/refactoring.nvim'

Plug 'tpope/vim-dotenv'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-dispatch'

Plug 'github/copilot.vim'

Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate', 'tag': '*'}
Plug 'stevearc/aerial.nvim', {'tag': 'v3.*'}
Plug 'LunarVim/bigfile.nvim'

Plug 'nvim-lua/plenary.nvim', {'tag': '*'} " required by telescope and nvim-coverage
Plug 'nvim-telescope/telescope.nvim'
Plug 'folke/todo-comments.nvim'

Plug 'michaelb/sniprun', { 'tag': 'v1.*', 'do': 'sh ./install.sh' }
Plug 'puremourning/vimspector'
Plug 'oxcafedead/vimyac', {'tag': 'v1.*'}

Plug 'vim-test/vim-test'
Plug 'andythigpen/nvim-coverage'

Plug 'lifepillar/vim-solarized8', {'branch': 'neovim'}
Plug 'f-person/auto-dark-mode.nvim'

Plug 'aklt/plantuml-syntax'
Plug 'oxcafedead/vitest-vim-compiler'
Plug 'oxcafedead/ruff-compiler-plugin'
call plug#end()

" Visual and UI / mappings

set number
set relativenumber
set nowrap
set statusline=%<%f\ %h%m%r%{FugitiveStatusline()}%=%-14.(%l,%c%V%)\ %P

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
require("init")
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

" Spelling! Very important for such people like me who can't spell
autocmd BufRead,BufNewFile *.md,COMMIT_EDITMSG setlocal spell spelllang=en_us

" Telescope & LSP, lsp_dynamic_workspace_symbols to search for symbols in the
" workspace
nmap <leader>ws :Telescope lsp_dynamic_workspace_symbols<CR>

" Vim test stuff
let test#strategy = "dispatch"

let g:dispatch_compilers = {
			\ 'vitest': 'node_modules/.bin/vitest',
			\ 'ruff': 'ruff',
                        \ 'mypy': 'pytest',
			\ 'python -m pytest': 'pytest',
			\ 'python3 -m pytest': 'pytest' }

" Useful utilities

function! CloseOtherBuffers()
	let current_buffer = bufnr('%')
	let buffers = filter(range(1, bufnr('$')), 'buflisted(v:val) && v:val != current_buffer')
	for buffer in buffers
		execute 'bwipeout' buffer
	endfor
endfunction

command! CloseOtherBuffers :call CloseOtherBuffers()

" Finally, exrc
set exrc
