" CONFIGURATION FILE FOR VIM

if exists('s:script_full_name')
	let script_path = s:script_full_name
else
	let script_path = expand('<sfile>:p')
endif

" let g:indent_blankline_use_treesitter = v:true
" let g:indent_blankline_context_char = '│'
" let g:indent_blankline_show_current_context = v:true

execute 'source ' . expand('<sfile>:p:h') . '/custom_one.vim'

fu! s:firstInsertEnter()
	if s:fi == 1
		luafile $XDG_CONFIG_HOME/SpaceVim.d/lua/nvim-cmp.lua
		map / <C-/>
		map ? <C-?>
		let s:fi = 0
	endif
endfunction

let s:fi = 1
augroup FirstInsertEnter
	autocmd!
	autocmd InsertEnter * call s:firstInsertEnter()
augroup END

augroup BackgroundChange
	autocmd!
	autocmd OptionSet background call CustomOne()
augroup END

" Don't write backup file
augroup NoBackup
	autocmd!
	au BufWrite /private/tmp/crontab.* set nowritebackup nobackup
	au BufWrite /private/etc/pw.* set nowritebackup nobackup
augroup END

if exists(':NERDTree') == 2
	execute 'source ' . expand('<sfile>:p:h') . '/nerdtree.vim'
endif

if exists(':Telescope') == 2
	augroup TelescopeConfig
		autocmd!
		autocmd User TelescopePreviewerLoaded execute 'source ' . expand('<sfile>:p:h') . '/telescope.vim' 
	augroup END
endif

" markdown 折行设置
augroup Markdown
	autocmd!
	au FileType markdown setlocal wrapmargin=2
	au FileType markdown setlocal matchpairs+=（:）,「:」
	au FileType markdown setlocal tabstop=4
    au FileType markdown setlocal shiftwidth=4
	au FileType markdown setlocal spell
augroup END

" When opening a new buffer, set copilot_workspace_folders to project root
if exists(':Copilot')
	augroup Copilot
		autocmd!
		autocmd BufNew * let b:copilot_workspace_folders = [getcwd()]
	augroup END
endif

set mouse=nicrv

let backspace=2

set foldmethod=manual

set encoding=utf-8
set fileencodings=utf-8,gb18030,default

set fillchars=vert:│,fold:·,eob:\ 

" 滚动时光标与边缘的距离
set scrolloff=5
set sidescrolloff=15
set listchars+=precedes:<,extends:>

" tab size
set tabstop=2

" 每级缩进的长度
" set shiftwidth=2

" 启用 256 色
set t_Co=256

fu! Tab(len)
	if a:len == ''
		let a:len = 4
	endif
	execute 'set shiftwidth='.a:len
	execute 'set tabstop='.a:len
endfunction

fu! Retab(before, after)
	if a:before != ''
		execute 'setlocal shiftwidth='.a:before
		execute 'setlocal tabstop='.a:before
	endif
	setlocal noexpandtab
	retab!
	if a:after == ''
		let len = 2
	else
		let len = a:after
	endif
	execute 'setlocal shiftwidth='.len
	execute 'setlocal tabstop='.len
	if a:after != ''
		set expandtab
		retab
	endif
endfunction

fu! GetSelection()
  let start_pos = getpos("'<")
  let end_pos = getpos("'>")
  let start_line = start_pos[1]
  let start_col = start_pos[2]
  let end_line = end_pos[1]
  let end_col = end_pos[2]
  echo start_line . ',' . start_col . ' ' . end_line . ' ' . end_col
  let selected_text = ""
  if start_line == end_line
    let selected_text = getline(start_line)[start_col-1:end_col-1]
    return selected_text
  endif
  for line in range(start_line, end_line)
    if line == start_line
      let line_text = getline(line)[start_col-1:]
    elseif line == end_line
      let line_text = getline(line)[:end_col-1]
    else
      let line_text = getline(line)
    endif
    let selected_text .= line_text
    if line != end_line
      let selected_text .= "\n"
    endif
  endfor
  return selected_text
endfunction

if exists('$TMUX') && $TMUX != ''
	fu! YankToTmux()
		let @o = GetSelection()
		let tmux_sess = system('tmux display -p \#S')
		silent execute '! ~/.local/bin/altr -w com.nyako520.tmux -t reg2buf -v reg=o -v "socket='. v:servername .'" -v sess=' . tmux_sess
	endfunction

	fu! PasteInTmux(pane, run)
		" run selected code in tmux pane
		let @o = GetSelection()
		let tmux_pane = system('tmux display -p "#S:#{window_index}"')
		let tmux_pane = substitute(tmux_pane, '\n', '', '') . '.' . a:pane
		silent execute '! ~/.local/bin/altr -w com.nyako520.tmux -t vim2tmux -v reg=o -v "socket='. v:servername .'" -v "pane=' . tmux_pane . '" -v run=' . a:run
	endfunction

	fu! PasteFromTmux(v)
		let @o = system('tmux show-buffer')
		if a:v == 1
			normal! gv"op
		else
			normal! "op
		endif
	endfunction

	xnoremap <silent> <Space>[ :<C-u>cal YankToTmux()<CR>
	nnoremap <silent> <Space>] :<C-u>cal PasteFromTmux(0)<CR>
	xnoremap <silent> <Space>] :<C-u>cal PasteFromTmux(1)<CR>
	inoremap <silent> <C-]> <ESC>:<C-u>cal PasteFromTmux(0)<CR>
	xnoremap <silent> <Space>- :<C-u>cal PasteInTmux(v:count, 1)<CR>
	xnoremap <silent> <Space>_ :<C-u>cal PasteInTmux(v:count, 0)<CR>
endif

fu! Chezmoi(action)
	let p = shellescape(expand('%:p')) 
	if a:action == 'add' || a:action == 'a'
		let o = system('chezmoi -n add ' . p)
		if v:shell_error != 0
			echoerr o
			return
		endif
		silent execute '!chezmoi add ' . p
		echo 'File added to chezmoi' | redraw
	elseif a:action == 'aa'
		call system("chezmoi status -i files -p absolute | grep -vE '^D' | choose 1.. | xargs -I _ chezmoi add '_'")
		call system("chezmoi status -i files -p absolute | grep -E '^D' | choose 1.. | xargs -I _ chezmoi forget --force '_'")
		if v:shell_error == 0
			echo 'All changes added to chezmoi' | redraw
		endif
	elseif a:action == 'restore' || a:action == 'r'
		let o = system('chezmoi -n status ' . p)
		if v:shell_error != 0
			echoerr o
			return
		endif
		silent execute '!chezmoi apply --force ' . p
		echo 'File restored' | redraw
	elseif a:action == 'diff' || a:action == 'd'
		let o = system('chezmoi source-path ' . p)
		if v:shell_error != 0
			echoerr o
			return
		endif
		execute 'vsp ' . o
		windo diffthis
	elseif a:action == 'status' || a:action == 's'
		echo system('chezmoi status ' . p)
	elseif a:action == 'sa'
		echo system('chezmoi status')
	endif
endfunction

fu! PasteAndKeepReg()
	let l:reg = getreg('"')
	let l:regtype = getregtype('"')
	normal! gvp
	call setreg('"', l:reg, l:regtype)
endfunction

fu! ToggleDiff()
	if exists(':NERDTree') == 2
		execute 'NERDTreeClose'
	endif
	if winnr('$') == 1
		return
	endif
	if &diff
		windo diffoff
	else
		windo diffthis
	endif
endfunction

" 对于只有一个大写字母的搜索词大小写敏感；其他情况大小写不敏感
set ignorecase
set smartcase

" 命令模式下，底部操作指令按 Tab 自动补全
" set wildmenu
set wildmode=longest:list,full

" 开启文件类型检查，并载入对应的缩进规则
filetype plugin indent on

set splitbelow
set splitright

" neovim specific configs
if has('nvim')
else
endif

" terminal app specific configs
if getenv('COLORTERM') == "truecolor"
	set termguicolors
	let g:spacevim_enable_guicolors = 1
else
	set notermguicolors
	let g:spacevim_enable_guicolors = 0
endif

" dir of current file
cnoremap ;d <C-r>=expand('%:p:h').'/'<CR>
" name of current file
cnoremap ;f <C-r>=expand('%')<CR>
cnoremap ;/ \{-}
command EF execute "tabe " . script_path
command! ER execute "source " . script_path
command P execute 'tabe '.@+
" browse current file in alfred
command AF execute "!alfred " . shellescape(expand("%:p"), 1)
command VS execute "!code " . shellescape(getcwd()) . " && sleep 1 && code -g " . shellescape(expand("%:p"))
command -nargs=1 TA cal Tab(<args>)
command -nargs=1 TR cal Retab(<args>, 2)
command -nargs=+ Se cal SpaceVim#plugins#iedit#start({'expr': <q-args>, 'selectall': 1})
command -nargs=+ SE cal SpaceVim#plugins#iedit#start({'expr': <q-args>, 'selectall': 0})
command -nargs=+ Sw cal SpaceVim#plugins#iedit#start({'word': <q-args>, 'selectall': 1})
command -nargs=+ SW cal SpaceVim#plugins#iedit#start({'word': <q-args>, 'selectall': 0})
command -nargs=1 SL setlocal spelllang=<args>
command -nargs=* CM call Chezmoi(<q-args>)
command TES execute '20sp +ter'
command TER execute '65vsp +ter'
command PER execute '!chmod +x "%:p"'
command DF call ToggleDiff()

nnoremap <Up> gk
nnoremap <Down> gj
nnoremap <A-k> 12k
nnoremap <A-j> 12j
noremap gj [e
noremap gk ]e
nnoremap g. gi
nnoremap <Space>/ :nohl<CR>
nnoremap <Space>x= =`]
nnoremap <Space>w\| :vsp<CR>
nnoremap <silent> <Space>fO :call system('open ' . shellescape(expand('%:p')))<CR>
map <silent> <f1> <Space>ft
noremap <silent><buffer> <f4> :TES<CR>
map <silent> <f4> :TES<CR>
silent! nunmap ma
nnoremap ml :<C-U>BookmarkShowAll<CR>

xnoremap <Up> gk
xnoremap <Down> gj
xnoremap <M-k> 12k
xnoremap <M-j> 12j
xnoremap C "+y
xnoremap X "+x
xnoremap <silent> p :<C-u>call PasteAndKeepReg()<CR>
xnoremap <silent> <CR> "oy<ESC>:call system('open ' . shellescape(getreg('o')))<CR>
xnoremap gs "oy/<C-r>o<CR>
xnoremap <silent> g<CR> "os<CR><ESC>k:r!<C-r>o<CR>kJJ
xnoremap <silent> <Space>se "1y:Se <C-r>1<CR><CR>
xnoremap <silent> <Space>sE "1y:SE <C-r>1<CR><CR>

tmap <ESC> <C-\><C-n>
tmap <silent> <f4> <ESC>:q<CR>
tmap <C-J> <C-Down>
tmap <C-K> <C-Up>
tmap <C-H> <C-Left>
tmap <C-L> <C-Right>
tmap <A-Left> <A-b>
tmap <A-Right> <A-f>

" EasyMotion
let g:EasyMotion_verbose = 0
let g:EasyMotion_leader_key = ";"
let g:EasyMotion_skipfoldedline = 0
let g:EasyMotion_space_jump_first = 1
let g:EasyMotion_move_highlight = 0
let g:EasyMotion_use_migemo = 1
let g:EasyMotion_startofline = 0
noremap s <Plug>(easymotion-fl2)
noremap ; <Plug>(easymotion-prefix)
noremap ;f <Plug>(easymotion-fl)
noremap ;s <Plug>(easymotion-overwin-f2)
" `s` 和 surround 冲突, 比如 ds
onoremap z <Plug>(easymotion-f2)
noremap ;/ <Plug>(easymotion-sn)
noremap ;L <Plug>(easymotion-overwin-line)
" noremap ;. <Plug>(easymotion-repeat)
noremap ;; <Plug>(easymotion-next)
noremap ;, <Plug>(easymotion-prev)

imap <silent><script><expr> <Plug>(vimrc:copilot-dummy-map) copilot#Accept("\<Tab>")
