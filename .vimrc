"Instructions:
"Copy colors/monokai.vim ~/.vim/colors/
"
""*****************************************************************************
"" Vim-PLug core
"*****************************************************************************
if has('vim_starting')
  set nocompatible               " Be iMproved
endif

let vimplug_exists=expand('~/.vim/autoload/plug.vim')

let g:vim_bootstrap_langs = "c,python"
let g:vim_bootstrap_editor = "vim"				" nvim or vim

if !filereadable(vimplug_exists)
  if !executable("curl")
    echoerr "You have to install curl or first install vim-plug yourself!"
    execute "q!"
  endif
  echo "Installing Vim-Plug..."
  echo ""
  silent !\curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  let g:not_finish_vimplug = "yes"

  autocmd VimEnter * PlugInstall
endif

"Required:
call plug#begin(expand('~/.vim/plugged'))

"Plugins
"*****************************************************************************
call plug#begin('~/.vim/plugged')
"Plug 'scrooloose/nerdtree'
" fuzzy finder
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'scrooloose/nerdcommenter'
" custom plugin for code assitant
Plug 'srikanthmalla/vim-tgi-plugin'
" vim tmux navigator
Plug 'christoomey/vim-tmux-navigator'
" Initialize plugin system
call plug#end()

"syntax on
"set number relativenumber 
set number
"set nu rnu
set ruler
"highlight Comment ctermfg=Grey
highlight LineNr ctermfg=Grey
"highlight Comment ctermfg=244
syntax enable
colorscheme monokai
"set tabstop=4
"set shiftwidth=4 " controls the depth of autoindentation
"set expandtab    " converts tabs to spaces
set laststatus=2 " show status line always
"Hotkeys 
"***************************************
let mapleader = ","
let mapSpace = " "
nmap <leader>f :GFiles<cr>
nmap <leader><leader>f :Files<cr>
nmap <leader>F :Locate /<cr>
nmap <leader>b :Buffers<cr>
nmap <leader>l :Lines<cr>
nmap <leader><leader>l :BLines<cr>
nmap <leader>t :Tags<cr>
nmap <leader>ct :BTags<cr>

autocmd Filetype cpp setlocal expandtab tabstop=2 shiftwidth=2
filetype indent plugin on
autocmd Filetype python set list listchars=tab:>-,trail:-,eol:$ expandtab tabstop=4 shiftwidth=4
autocmd Filetype python retab

" Uncomment the following to have Vim jump to the last position when
" reopening a file
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

set clipboard=unnamedplus

" To toggle between split vim screens
nnoremap <leader>ww <C-w>w

" Map Ctrl-a + Arrow keys for Vim and terminal split navigation
nnoremap <silent> <C-a><Left>  <C-w>h   " Navigate left
nnoremap <silent> <C-a><Down>  <C-w>j   " Navigate down
nnoremap <silent> <C-a><Up>    <C-w>k   " Navigate up
nnoremap <silent> <C-a><Right> <C-w>l   " Navigate right

" Tmux pane navigation (with tmux)
let g:tmux_navigator_no_mappings = 1
nnoremap <silent> <C-a><Up>    :TmuxNavigateUp<cr>
nnoremap <silent> <C-a><Down>  :TmuxNavigateDown<cr>
nnoremap <silent> <C-a><Left>  :TmuxNavigateLeft<cr>
nnoremap <silent> <C-a><Right> :TmuxNavigateRight<cr>

" split vim screen
" Horizontal split with , + h
nnoremap <leader>h :split<CR>
" Vertical split with , + v
nnoremap <leader>v :vsplit<CR>

set mouse=

" Map Ctrl-D to close window or split 
nnoremap <silent> <C-d> :call CloseWindow()<CR>

" Function to check the situation and close accordingly
function! CloseWindow()
    " If the buffer is modified (unsaved changes)
    if &modified
      " Show a confirmation prompt before saving and quitting
      let confirm_result = confirm("There are unsaved changes. Do you want to save and quit?", "&Yes\n&No", 1)
      if confirm_result == 1
        " If Yes is selected, save and quit the buffer (write and quit)
        exec ":wq!"
      else
	exec ":q!"
      endif
    else
      " If No is selected, don't save, just quit
      exec ":q!"
    endif
endfunction

" Map Ctrl-B to close window or split 
nnoremap <silent> <C-b> :call CloseBuffer()<CR>
" Function to handle buffer closing
function! CloseBuffer()
  " If the buffer is modified (unsaved changes)
  if &modified
    " Show a confirmation prompt before saving and quitting the buffer
    let confirm_result = confirm("There are unsaved changes. Do you want to save the buffer?", "&Yes\n&No", 1)
    if confirm_result == 1
      " If Yes is selected, save and delete the buffer
      exec ":w"
      exec ":bd!"
    else
      " If No is selected, forcefully delete the buffer without saving
      exec ":bd!"
    endif
  else
    " If the buffer is not modified
    if &buftype == 'nofile' || &buftype == 'nowrite'
      " For temporary buffers, force delete
      exec ":bd!"
    else
      " For regular buffers, just delete the buffer
      exec ":bd"
    endif
  endif
endfunction
