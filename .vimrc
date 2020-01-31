" vim:fileencoding=utf-8:ft=vim:foldmethod=marker:nomodeline:
" ============================================================================
" VIM-PLUG {{{
" ============================================================================

" automatic installation
let s:vim_plug = has('nvim') ?
      \ stdpath('data') . '/site/autoload/plug.vim' :
      \ '~/.vim/autoload/plug.vim'
let s:plug_home = has('nvim') ?
      \ stdpath('data') . '/plugged' :
      \ '~/.vim/plugged'

if empty(glob(s:vim_plug))
  silent! execute '!curl -fLo ' . s:vim_plug . ' --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" load plugins
call plug#begin(s:plug_home)

Plug 'tpope/vim-sensible'
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-rsi'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'wellle/targets.vim'
Plug 'wellle/tmux-complete.vim'
Plug 'airblade/vim-gitgutter'
Plug 'tmux-plugins/vim-tmux-focus-events'
Plug 'tmux-plugins/vim-tmux'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'chriskempson/base16-vim'
Plug 'tridactyl/vim-tridactyl'

call plug#end()

" automatically install missing plugins on startup
autocmd VimEnter *
      \  if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
      \|   PlugInstall --sync | q
      \| endif

" }}}
" ============================================================================
" BASIC SETTINGS {{{
" ============================================================================

augroup vimrc
  autocmd!
augroup END

"set number
"set relativenumber
set cursorline
set cursorcolumn
set ignorecase
set smartcase
set hlsearch
set expandtab
set showmatch
set showcmd
set hidden
set list
set splitright
set nowrap
set notimeout
set shortmess-=S
set gdefault

" a simple statusline with filetype and git status
set statusline=%<%f\ %h%m%r%y
set statusline+=%{FugitiveStatusline()}
set statusline+=%=
set statusline+=%-14.(%l,%c%V%)\ %P

" theme
if exists("$BASE16_THEME")
  let base16colorspace=256
  colorscheme base16-default-dark
endif

" }}}
" ============================================================================
" MAPPINGS {{{
" ============================================================================

" make using "<C-c>" do the same as "<Esc>" to trigger autocmd commands
inoremap <C-C> <Esc>

" cycle windows
nnoremap <C-Q> <C-W><C-W>

" make "Y" behave like other capitals
nnoremap Y y$

" "qq "to record, "Q" to replay
nnoremap Q @q

" "g." to repeat Ex command
nnoremap g. @:
vnoremap g. @:

" "gp" to mark last pasted
nnoremap gp `[v`]

" "gr" to discard
nnoremap gr :edit!<CR>

" tab completion
inoremap <expr> <Tab> pumvisible() ? "\<C-N>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-P>" : "\<S-Tab>"
inoremap <expr> <CR> pumvisible() ? "\<C-Y>" : "\<CR>"

" "<C-Space>" to trigger omnifunc
imap <C-Space> <C-X><C-O>
imap <C-@> <C-X><C-O>

" make it easier to search from command history
cnoremap <C-P> <Up>
cnoremap <C-N> <Down>

" simulate emacs-style "<C-g>"
cnoremap <C-G> <C-c><C-G>
vnoremap <C-G> <C-c><C-G>

" visualstar
vnoremap <silent> * :<C-U>
      \ let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
      \ gvy/<C-R><C-R>=substitute(
      \ escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
      \ gV:call setreg('"', old_reg, old_regtype)<CR>
vnoremap <silent> # :<C-U>
      \ let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
      \ gvy?<C-R><C-R>=substitute(
      \ escape(@", '?\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
      \ gV:call setreg('"', old_reg, old_regtype)<CR>

" MapMeta from vim-rsi
function! s:MapMeta() abort
  noremap! <M-y> <C-E>
endfunction

if has("gui_running") || has('nvim')
  call s:MapMeta()
else
  silent! exe "set <F36>=\<Esc>y"
  noremap! <F36> <C-E>
  augroup vimrc
    autocmd GUIEnter * call s:MapMeta()
  augroup END
endif

" leader
let mapleader = ' '

nnoremap <Leader>ev :EV<CR>
nnoremap <Leader>sv :SV<CR>

nnoremap <Leader><Tab> <C-^>
nnoremap <Leader><Leader> :Commands<CR>
nnoremap <Leader><C-@> :History:<CR>
nnoremap <Leader><C-Space> :History:<CR>
nnoremap <Leader>? :Maps<CR>
nnoremap <Leader>h :Helptags<CR>

nnoremap <Leader>Q :qa!<CR>
nnoremap <Leader>W :wa!<CR>
nnoremap <Leader>q :qa<CR>
nnoremap <Leader>w :w<CR>
nnoremap <Leader>z :x<CR>
nnoremap <Leader>Z :X<CR>

nnoremap <Leader>bb :Buffers<CR>
nnoremap <Leader>bd :bdelete<CR>
nnoremap <Leader>bn :bnext<CR>
nnoremap <Leader>bp :bprevious<CR>

nnoremap <Leader>ff :Files<CR>
nnoremap <Leader>fr :History<CR>
nnoremap <Leader>ft :Filetypes<CR>

nnoremap <Leader>gs :Gstatus<CR>
nnoremap <Leader>gd :GitGutterPreviewHunk<CR>
nnoremap <Leader>gr :GitGutterUndoHunk<CR>

nnoremap <Leader>sw :Windows<CR>
nnoremap <Leader>sf :FZF<CR>
nnoremap <Leader>sm :Marks<CR>
nnoremap <Leader>sr :Rg<CR>
nnoremap <Leader>ss :BLines<CR>
nnoremap <Leader>sj :BTags<CR>
nnoremap <Leader>sJ :Tags<CR>

" }}}
" ============================================================================
" FUNCTIONS & COMMANDS {{{
" ============================================================================

" quick edit and source vimrc
command! EV edit $MYVIMRC
command! SV source $MYVIMRC

" enhance w, q
command! W w !sudo tee % > /dev/null
command! Q qa!

" }}}
" ============================================================================
" PLUGINS {{{
" ============================================================================

" gitgutter
set updatetime=100  " most important option
let g:gitgutter_map_keys = 0

nmap [h <Plug>(GitGutterPrevHunk)
nmap ]h <Plug>(GitGutterNextHunk)

" fzf
imap <C-X><C-K> <Plug>(fzf-complete-word)
imap <C-X><C-L> <Plug>(fzf-complete-buffer-line)

if has('nvim') && !exists('g:fzf_layout')
  autocmd! FileType fzf
  autocmd  FileType fzf set laststatus=0 noshowmode noruler
        \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler
endif

" }}}
" ============================================================================
" AUTOCMD {{{
" ============================================================================

augroup vimrc

  " last-position-jump
  autocmd BufReadPost *
        \ if line("'\"") > 1 && line("'\"") <= line("$") && &ft !~# 'commit'
        \ |   exe "normal! g`\""
        \ | endif

  " ft-syntax-omni
  autocmd FileType *
        \ if &omnifunc == "" |
        \   setlocal omnifunc=syntaxcomplete#Complete |
        \ endif

  " close preview window on CompleteDone
  autocmd CompleteDone * silent! pclose

  " "q" to close quickfix window
  autocmd FileType qf nnoremap <silent> <buffer> q <C-W>c

  " help from new tab (https://github.com/junegunn/dotfiles/blob/master/vimrc)
  function! s:helptab() abort
    if &buftype == 'help'
      wincmd T
      nnoremap <buffer> q :q<CR>
    endif
  endfunction
  autocmd BufEnter *.txt call s:helptab()

  " eighty column rule
  function! s:eightycolumn() abort
    if exists('&textwidth') && &textwidth
      set colorcolumn=+1
    else
      set colorcolumn=80
    endif
  endfunction
  autocmd FileType * call s:eightycolumn()

augroup END

" }}}
" ============================================================================
" LOCAL CUSTOMIZATIONS {{{
" ============================================================================

if filereadable(glob('~/.vimrc.local'))
  source ~/.vimrc.local
endif

" }}}
" ============================================================================
