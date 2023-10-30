" This must be first, because it changes other options as side effect
set nocompatible

" One particularly useful setting is hidden. Its name isn’t too descriptive, though.
" It hides buffers instead of closing them. This means that you can have unwritten
" changes to a file and open a new file using :e, without being forced to write or
" undo your changes first. Also, undo buffers and marks are preserved while the
" buffer is open. This is an absolute must-have.
set hidden

"set nowrap               " don't wrap lines
set tabstop=3             " a tab is four spaces
"set softtabstop=4        " makes the spaces feel like real tabs

"set expandtab tabstop=4 shiftwidth=4
"set noexpandtab tabstop=4 softtabstop=4 shiftwidth=4

set backspace=indent,eol,start
                          " allow backspacing over everything in insert mode
set autoindent            " always set autoindenting on
set copyindent            " copy the previous indentation on autoindenting
"set number               " always show line numbers
set shiftwidth=3          " number of spaces to use for autoindenting
set shiftround            " use multiple of shiftwidth when indenting with '<' and '>'
set showmatch             " set show matching parenthesis
set ignorecase            " ignore case when searching
set smartcase             " ignore case if search pattern is all lowercase,
                          "    case-sensitive otherwise
"set smarttab             " insert tabs on the start of a line according to
                          "    shiftwidth, not tabstop
set hlsearch              " highlight search terms
"set incsearch            " show search matches as you type
set history=1000          " remember more commands and search history
set undolevels=1000       " use many muchos levels of undo
set wildignore=*.swp,*.bak,*.pyc,*.class
set title                 " change the terminal's title
set visualbell            " don't beep
set noerrorbells          " don't beep

" never ever let Vim write a backup file! They did that in the 70’s.
" Use modern ways for tracking your changes, for God’s sake.
set nobackup
set noswapfile

"set expandtab

"set nosmartindent
"set smartindent

set background=dark
" set background=light

set noautoindent
set nocindent

set paste
set laststatus=2
if version >= 700
  au InsertEnter * hi StatusLine term=reverse ctermbg=5 gui=undercurl guisp=Magenta
  au InsertLeave * hi StatusLine term=reverse ctermfg=0 ctermbg=2 gui=bold,reverse
endif
set statusline=%f\ %y\ Spalte\=%c\ Zeile\=%l/%L\ %PATCH
set showmode

" if &t_Co >= 256 || has("gui_running")
"    colorscheme mustang
" endif

if &t_Co > 2 || has("gui_running")
   " switch syntax highlighting on, when the terminal has colors
   syntax on
endif

if &background == "dark"
   " schemen unter /usr/share/vim/vim74/colors/
   colorscheme elflord
endif
