" Clipboard management - CTRL-SHIFT-C to copy and CTRL-SHIFT-V to paste using system clipboard
set clipboard=unnamedplus
tnoremap <C-S-c> <C-\><C-N>"+y
tnoremap <C-S-v> <C-\><C-N>"+p

" See relative and absolute number of lines
set number
set relativenumber

" Mapping ALT-UP and ALT-DOWN to swap lines
map <A-Up> :m-2<CR>
map <A-Down> :m+1<CR>

" Search features
set incsearch      " Incremental search
set ignorecase     " Ignore case when searching
set hlsearch       " Highlight search matches

" Set tab and space settings
set expandtab      " Use spaces instead of tabs
set tabstop=2      " Number of spaces in a tab
set shiftwidth=2   " Indentation level for each shift
set softtabstop=2  " Number of spaces for a tab while editing

" Enable syntax highlighting
syntax enable

" Enable filetype-specific plugins
filetype plugin indent on

" Enable auto-completion
set completeopt=menuone,noinsert,noselect

" Enable mouse support
set mouse=a

" Highlight trailing spaces
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/

" Enable persistent undo
set undofile
set undodir=~/.vim/undo

" Avoid backup files
set nobackup
set nowritebackup
set noswapfile

" Enable line wrapping
set wrap


" Git things for status line
" Function to get the current Git branch
function! GitBranch()
  " Run git command to get the branch name
  let l:branch = system('git rev-parse --abbrev-ref HEAD 2>/dev/null')
  if v:shell_error
    return ''
  endif
  return l:branch
endfunction

" Function to get Git status (added, removed, modified files)
function! GitStatus()
  " Run git status to get the status of the working directory
  let l:status = system('git status --porcelain 2>/dev/null')
  if v:shell_error
    return ''
  endif

  " Check if there are any added or removed files
  let l:added = len(filter(split(l:status), 'v:val[0] == "A"'))
  let l:removed = len(filter(split(l:status), 'v:val[0] == "D"'))

  let l:status_str = ''
  if l:added > 0
    let l:status_str .= ' +'.l:added
  endif
  if l:removed > 0
    let l:status_str .= ' -'.l:removed
  endif

  return l:status_str
endfunction

" Customize the status line to include Git branch and status
set statusline=%f\ %y\ %m\ %r\ %=%l/%L\ %c\ %p%%\ %{GitBranch()}\ %{GitStatus()}
