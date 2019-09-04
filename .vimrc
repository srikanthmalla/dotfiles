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
Plug 'scrooloose/nerdtree'
Plug 'ctrlpvim/ctrlp.vim', {'on': ['CtrlP', 'CtrlPMixed', 'CtrlPMRU']}
Plug 'wikitopian/hardmode'
Plug 'scrooloose/nerdcommenter'
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
nmap <leader>ne :NERDTree<cr>
nmap <Space>f :CtrlP<cr>
nmap <Space>m :CtrlPMixed<cr>
nmap <Space>r :CtrlPMRU<cr>
nnoremap <leader>h <Esc>:call ToggleHardMode()<CR>

autocmd Filetype cpp setlocal expandtab tabstop=2 shiftwidth=2
filetype indent plugin on
autocmd Filetype python setlocal listchars=tab:>-,trail:-,eol:$ list expandtab tabstop=4 shiftwidth=4
autocmd Filetype python retab
