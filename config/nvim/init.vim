" TABLE OF CONTENTS:
" 1. GENERIC SETTINGS
" 2. VIM-PLUG PLUGINS
" 3. USER INTERFACE
" 4. COLORS AND FONTS
" 5. FILE SETTINGS
" 6. TEXT SETTINGS
" 7. VISUAL MODE
" 8. NAVIGATION
" 9. EDITING
" 10. VIMGREP
" 11. Spell Checking
" 12. MISC
" 13. HELPER FUNCTIONS
" 14. PLUGIN SETTINGS

" ==============================================================================
" 1. GENERIC SETTINGS
" ==============================================================================
" Disable vi compatibility mode
set nocompatible

" Increase history size
set history=1000

"Set the width of a page
set textwidth=80

"Map leader to \ and space to the leader
let mapleader='\'
let maplocalleader=','
map <space> <leader>
map <space><space> <leader><leader>

" save all files on focus lost, ignoring warnings about untitled buffers
autocmd FocusLost * silent! wa
" ==============================================================================
" 2. VIM-PLUG PLUGINS
" ==============================================================================
" Init vim-plug
if has("win32") || has("win64")
    call plug#begin('$USERPROFILE/vimfiles/plugged/')
else
    call plug#begin('~/.vim/plugged/')
end

" Plug-ins
Plug 'tpope/vim-fugitive'                     " Git
Plug 'vim-airline/vim-airline'                " Airline
Plug 'vim-airline/vim-airline-themes'         " themes for vim-airline
Plug 'ctrlpvim/ctrlp.vim'                     " Ctrl-P
Plug 'Chiel92/vim-autoformat'                 " Autoformat
Plug 'scrooloose/nerdcommenter'               " Comments
Plug 'ervandew/screen'                        " Tmux

Plug 'benekastah/neomake'                     " Syntastic for neovim
Plug 'ervandew/supertab'                      " Tab Completion
Plug 'Yggdroot/indentLine'                    " Indent Lines
Plug 'justincampbell/vim-eighties'            " Auto Resize splits
Plug 'godlygeek/tabular'                      " Align Comments
Plug 'rhysd/vim-grammarous'                   " Grammar Checking

" Language support
Plug 'JuliaEditorSupport/julia-vim'           " Julia
Plug 'junegunn/vim-emoji'                     " Emojis
Plug 'vim-scripts/indentpython.vim'           " Python
Plug 'lervag/vimtex'                          " LaTeX
Plug 'SirVer/ultisnips'                       " Snippets
Plug 'honza/vim-snippets'                     " Snippets
Plug 'tikhomirov/vim-glsl'                    " GLSL

" Colorschemes
Plug 'chriskempson/base16-vim'

" Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
" let g:deoplete#enable_at_startup = 1

call plug#end()

" ==============================================================================
" 3. USER INTERFACE
"
" ==============================================================================
" Set 7 lines to the cursor - when moving vertically using j/k
set so=7

" Turn on the WiLd menu
set wildmenu

" Ignore compiled files
set wildignore=*.o,*~,*.pyc

"Always show current position
set ruler

" Height of the command bar
set cmdheight=2

" A buffer becomes hidden when it is abandoned
set hid

" Configure backspace so it acts as it should act
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

" Ignore case when searching
set ignorecase

" When searching try to be smart about cases
set smartcase

" Highlight search results
set hlsearch

" Makes search act like search in modern browsers
set incsearch

" Don't redraw while executing macros (good performance config)
set lazyredraw

" For regular expressions turn magic on
set magic

" Show matching brackets when text indicator is over them
set showmatch
" How many tenths of a second to blink when matching brackets
set mat=2

" No annoying sound on errors
set noerrorbells
set novisualbell
set t_vb=
set tm=500

" Always show which mode we are in
set showmode

" Always show statusbr
set laststatus=2

" Format the status line
set statusline=\ %{HasPaste()}%F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ \ Line:\ %l

" Don't wrap long lines
set nowrap

" show line numbers
set number

" show numbers as relative by default
set relativenumber

set splitbelow
set splitright

" highlght line where the cursor is
"set cursorline

" highlight column where the cursor is
"set cursorcolumn

"Toggle Relative Number
nmap <F6> :call ToggleRelativeNumber()<CR>

" ==============================================================================
" 4. COLORS AND FONTS
" ==============================================================================

syntax enable
set colorcolumn=80

if exists('$BASE16_THEME')
      \ && (!exists('g:colors_name') || g:colors_name != 'base16-$BASE16_THEME')
    let base16colorspace=256
    colorscheme base16-$BASE16_THEME
endif

"Airline Settings
"let g:airline_powerline_fonts=1
let g:airline_left_sep=''
let g:airline_right_sep=''
let g:airline_theme='base16'

" Use Unix as the standard file type
set ffs=unix,dos,mac

" ==============================================================================
" 5. FILE SETTINGS
" ==============================================================================
" Turn backup off, since most stuff is in SVN, git et.c anyway...
set nobackup
set nowb
set noswapfile
filetype plugin on
filetype indent on

" ==============================================================================
" 6. TEXT SETTINGS
" ==============================================================================
" Use spaces instead of tabs
set expandtab

" Be smart when using tabs ;)
set smarttab

" 1 tab == 4 spaces
set shiftwidth=4
set tabstop=4

" Linebreak on 80 characters
set lbr
set tw=80

set ai "Auto indent
set si "Smart indent
set wrap "Wrap lines
set wm=8

"Split lines as break lines (useful when moving around in them)
map j gj
map k gk

"Resize horizontal splits fast
if bufwinnr(1)
    map + <C-W>+
    map - <C-W>-
endif

"Scroll window faster
nnoremap <C-e> 3<C-e>
nnoremap <C-y> 3<C-y>

" Disable highlight when <leader><cr> is pressed
map <silent> <leader><cr> :noh<cr>

" Smart way to move between windows
map <C-h> :call WinMove('h')<cr>
map <C-j> :call WinMove('j')<cr>
map <C-k> :call WinMove('k')<cr>
map <C-l> :call WinMove('l')<cr>

" Move between matching braces
noremap % v%

"Source and edit .vimrc without reload
nnoremap <leader>sv :source $MYVIMRC<cr>
nnoremap <leader>ev :e! $MYVIMRC<cr> " edit $MYVIMRC

"Save and Close files
nnoremap <leader>w :w!<cr>
nnoremap <leader>qw :x!<cr>

" Close the current buffer
map <leader>bd :Bclose<cr>

" Close all the buffers
map <leader>ba :1,1000 bd!<cr>

" Useful mappings for managing tabs
map <leader>tn :tabnew<cr>
map <leader>to :tabonly<cr>
map <leader>tc :tabclose<cr>
map <leader>tm :tabm
map <leader>th :tabn<cr>
map <leader>tl :tabp<cr>
map <leader>tj :tabfirst<cr>
map <leader>tk :tablast<cr>

" Opens a new tab with the current buffer's path
" Super useful when editing files in the same directory
map <leader>te :tabedit <c-r>=expand("%:p:h")<cr>/<cr>

" Switch CWD to the directory of the open buffer
map <leader>cd :cd %:p:h<cr>:pwd<cr>

" Specify the behavior when switching between buffers
try
    set switchbuf=useopen,usetab,newtab
    set stal=2
catch
endtry

" Return to last edit position when opening files (You want this!)
autocmd BufReadPost *
            \ if line("'\"") > 0 && line("'\"") <= line("$") |
            \   exe "normal! g`\"" |
            \ endif
" Remember info about open buffers on close
set viminfo^=%

" ==============================================================================
" 9. EDITING
" ==============================================================================
" Remap VIM 0 to first non-blank character
map 0 ^

"Nicer Enter Key
nnoremap <CR> o<Esc>
nnoremap <S-CR> i<CR><Esc>

" Move a line of text using ALT+[jk] or Comamnd+[jk] on mac
nmap <M-j> mz:m+<cr>`z
nmap <M-k> mz:m-2<cr>`z
vmap <M-j> :m'>+<cr>`<my`>mzgv`yo`z
vmap <M-k> :m'<-2<cr>`>my`<mzgv`yo`z

"Align Comments
noremap <leader>cf :Tab /#<cr>

"Autoformat
noremap <F3> :Autoformat<CR>

" helpers for dealing with other people's code
nmap ,t :set ts=4 sts=4 sw=4 noet<cr>
nmap ,s :set ts=4 sts=4 sw=4 et<cr>

" Delete trailing white space on save, useful for Python and CoffeeScript ;)
func! DeleteTrailingWS()
    exe "normal mz"
    %s/\s\+$//ge
    exe "normal `z"
endfunc
autocmd BufWrite *.py :call DeleteTrailingWS()
autocmd BufWrite *.coffee :call DeleteTrailingWS()
nnoremap ds :call DeleteTrailingWS()<cr>

" ==============================================================================
" 10. VIMGREP
" ==============================================================================
" When you press gv you vimgrep after the selected text
vnoremap <silent> <leader>gv :call VisualSelection('gv')<CR>

" Open vimgrep and put the cursor in the right position
map <leader>g :vimgrep // **/*.<left><left><left><left><left><left><left>

" When you press <leader>r you can search and replace the selected text
vnoremap <silent> <leader>gr :call VisualSelection('replace')<CR>

" Do :help cope if you are unsure what cope is. It's super useful!
"
" When you search with vimgrep, display your results in cope by doing:
"   <leader>cc
"
" To go to the next search result do:
"   <leader>n
"
" To go to the previous search results do:
"   <leader>p

" map <leader>n :cn<cr>
" map <leader>p :cp<cr>
"
" IMPORTANT: grep will sometimes skip displaying the file name if you
" search in a singe file. This will confuse Latex-Suite. Set your grep
" program to always generate a file-name.
set grepprg=grep\ -nH\ $*
" ==============================================================================
" 11. Spell Checking
" ==============================================================================
" Pressing ,ss will toggle and untoggle spell checking
map <leader>ss :setlocal spell!<cr>

" Shortcutscusing <leader>
map <leader>sn ]s
map <leader>sp [s
map <leader>sa zg
map <leader>sr zw
map <leader>s? z=

" ==============================================================================
" 12. MISC
" ==============================================================================
" Remove the Windows ^M - when the encodings gets messed up
noremap <Leader>m mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm

" Toggle paste mode on and off
map <leader>pp :setlocal paste!<cr>

set clipboard=unnamedplus

"Set GLSL File Type
au BufNewFile,BufRead *.cls,*.tex set ft=tex
au BufNewFile,BufRead *.jl set ft=julia
au BufNewFile,BufRead *.m set ft=matlab
au BufNewFile,BufRead *.pde,*.pyde set ft=processing
au BufNewFile,BufRead *.py set ft=python
au BufNewFile,BufRead *.sage set ft=python
au BufNewFile,BufRead *.r set ft=r
au BufNewFile,BufRead *.vs,*.fs set ft=glsl

" ==============================================================================
" 13. HELPER FUNCTIONS
" ==============================================================================
" Now, in order to easily swap between relative numbers and non-relative
" numbers, let's declare a function that does the job for us: it sets
" relativenumbers if it's OFF, it unsets it if it's ON.
function! ToggleRelativeNumber()
    if &relativenumber == 1
        set norelativenumber
        set number
    else
        set relativenumber
    endif
endfunction

function! CmdLine(str)
    exe "menu Foo.Bar :" . a:str
    emenu Foo.Bar
    unmenu Foo
endfunction

function! VisualSelection(direction) range
    let l:saved_reg = @"
    execute "normal! vgvy"

    let l:pattern = escape(@", '\\/.*$^~[]')
    let l:pattern = substitute(l:pattern, "\n$", "", "")

    if a:direction == 'b'
        execute "normal ?" . l:pattern . "^M"
    elseif a:direction == 'gv'
        call CmdLine("vimgrep " . '/'. l:pattern . '/' . ' **/*.')
    elseif a:direction == 'replace'
        call CmdLine("%s" . '/'. l:pattern . '/')
    elseif a:direction == 'f'
        execute "normal /" . l:pattern . "^M"
    endif

    let @/ = l:pattern
    let @" = l:saved_reg
endfunction


" Returns true if paste mode is enabled
function! HasPaste()
    if &paste
        return 'PASTE MODE  '
    en
    return ''
endfunction

" Don't close window, when deleting a buffer
command! Bclose call <SID>BufcloseCloseIt()
function! <SID>BufcloseCloseIt()
    let l:currentBufNum = bufnr("%")
    let l:alternateBufNum = bufnr("#")

    if buflisted(l:alternateBufNum)
        buffer #
    else
        bnext
    endif

    if bufnr("%") == l:currentBufNum
        new
    endif

    if buflisted(l:currentBufNum)
        execute("bdelete! ".l:currentBufNum)
    endif
endfunction

" Window movement shortcuts
" move to the window in the direction shown, or create a new window
function! WinMove(key)
    let t:curwin = winnr()
    exec "wincmd ".a:key
    if (t:curwin == winnr())
        if (match(a:key,'[jk]'))
            wincmd v
        else
            wincmd s
        endif
        exec "wincmd ".a:key
    endif
endfunction

"===============================================================================
" 14. PLUGIN SETTINGS
"===============================================================================

" Nerd Commenter Settings

" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1
let g:NERDRemoveAltComs = 1

" map fuzzyfinder (CtrlP) plugin
" nmap <silent> <leader>t :CtrlP<cr>
nmap <silent> <leader>b :CtrlPBuffer<cr>
let g:ctrlp_map='<leader>t'
let g:ctrlp_dotfiles=1
let g:ctrlp_working_path_mode = 'ra'

" CtrlP ignore patterns
let g:ctrlp_custom_ignore = {
            \ 'dir': '\.git$\|node_modules$\|\.hg$\|\.svn$',
            \ 'file': '\.exe$\|\.so$'
            \ }

" search the nearest ancestor that contains .git, .hg, .svn
"let g:ctrlp_working_path_mode = 2

" When writing a buffer (no delay), and on normal mode changes (after 750ms).
call neomake#configure#automake('nw', 750)

"Vim Eighties Config
let g:eighties_enabled = 1
let g:eighties_minimum_width = 80
let g:eighties_extra_width = 0 " Increase this if you want some extra room
let g:eighties_compute = 1 " Disable this if you just want the minimum + extra
let g:eighties_bufname_additional_patterns = ['fugitiveblame'] " Defaults to [], 'fugitiveblame' is only an example. Takes a comma delimited list of bufnames as strings.

"Indent Line Settings
let g:indentLine_char = '│'

" vimtex
let g:tex_flavor='latex'
let g:vimtex_view_method = 'zathura'
let g:vimtex_latexmk_progname = 'nvr'
let g:vimtex_quickfix_mode = 2
set conceallevel=1
let g:tex_conceal='abdmg'
let g:vimtex_quickfix_autoclose_after_keystrokes = 3
let g:vimtex_indent_on_ampersands = 0

" let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-j>"
let g:UltiSnipsJumpBackwardTrigger="<c-k>>"
let g:UltiSnipsEditSplit="vertical"
let g:UltiSnipsSnippetDirectories=["Ultisnips","mysnippets"]

" "Deoplete
" call deoplete#custom#var('omni', 'input_patterns', {
            " \ 'tex': g:vimtex#re#deoplete
            " \})

let g:SuperTabDefaultCompletionType = "<tab>"

autocmd FileType javascript let g:SuperTabDefaultCompletionType = "<c-x><c-o>"
let g:UltiSnipsExpandTrigger="<c-j>"
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
