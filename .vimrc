colorscheme slatedpf

filetype plugin indent on
syntax on               " turn syntax highlighting on by default

set guifont=Monaco:h14
set smartindent
set tabstop=4
set shiftwidth=4
set expandtab
set nowritebackup
set noswapfile

set showcmd             " display incomplete commands
set nobackup            " do not keep a backup file
set number              " show line numbers
set ruler               " show the current row and column

set noic

set hlsearch            " highlight searches
set incsearch           " do incremental searching
set showmatch           " jump to matches when entering regexp
set noignorecase        " ensure do not ignore case when searching
set smartcase           " no ignorecase if Uppercase char present

set visualbell t_vb=    " turn off error beep/flash
set novisualbell        " turn off visual bell

set backspace=indent,eol,start  " make that backspace key work the way it should

set hidden
set shell=/bin/bash

"Set up folding
set foldmethod=manual
set foldcolumn=1

" hi LineNr         ctermbg=black ctermfg=cyan
hi FoldColumn     ctermbg=black ctermfg=green
hi Folded         ctermbg=black ctermfg=green 

" Set up file info
set statusline+=%F
  
hi StatusLine       ctermbg=white ctermfg=black       cterm=NONE
hi StatusLineNC     ctermbg=black    ctermfg=white       cterm=NONE
hi TabLine          ctermbg=darkgreen    ctermfg=white  cterm=NONE
hi TabLineFill      ctermbg=darkgreen    ctermfg=white cterm=NONE
hi TabLineSel       ctermbg=white  ctermfg=black       cterm=NONE

" Remappings for pane navigation - requires shift
nnoremap <C-k> <C-W><C-J> " Down
nnoremap <C-l> <C-W><C-K> " Up
nnoremap <C-;> <C-W><C-L> " Right
nnoremap <C-j> <C-W><C-H> " Left

se cursorcolumn
  
set background=dark
