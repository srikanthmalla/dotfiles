syntax on
set number
set ruler
highlight Comment ctermbg=Blue ctermfg=White
highlight LineNr ctermfg=Grey

set tabstop=4
set shiftwidth=4 " controls the depth of autoindentation
set expandtab    " converts tabs to spaces
set laststatus=2 " show status line always

autocmd Filetype cpp setlocal expandtab tabstop=2 shiftwidth=2
autocmd Filetype python setlocal expandtab tabstop=4 shiftwidth=4
