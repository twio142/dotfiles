let g:NERDTreeBookmarksFile = expand('$XDG_STATE_HOME') . '/nerdtree/bookmarks'
let g:NERDTreeSortOrder = ['\/$', '*', '\.swp$', '\.bak$', '\~$', '[[-timestamp]]']
let g:NERDTreeDirArrowExpandable = ''
let g:NERDTreeDirArrowCollapsible = ''

fu! NERDTreeBookmark(action)
  let l:key = nr2char(getchar())
  if a:action == 'add'
    execute 'Bookmark ' . l:key
  elseif a:action == 'reveal'
    execute 'RevealBookmark ' . l:key
  elseif a:action == 'open'
    execute 'OpenBookmark ' . l:key
  endif
endf

augroup NERDTree
  autocmd!
  " Open the existing NERDTree on each new tab.
  autocmd BufWinEnter * if &buftype != 'quickfix' && getcmdwintype() == '' | silent NERDTreeMirror | endif
  autocmd FileType nerdtree noremap <silent> <buffer> <C-h> :TmuxNavigateLeft<CR>
  autocmd FileType nerdtree noremap <silent> <buffer> <C-j> :TmuxNavigateDown<CR>
  autocmd FileType nerdtree noremap <silent> <buffer> <C-k> :TmuxNavigateUp<CR>
  autocmd FileType nerdtree noremap <silent> <buffer> <C-l> :TmuxNavigateRight<CR>
  autocmd FileType nerdtree noremap <silent> <buffer> r :NERDTreeRefreshRoot<CR>
  autocmd FileType nerdtree noremap <silent> <buffer> <C-r> :NERDTreeRefreshRoot<CR>
  autocmd FileType nerdtree noremap <silent> <buffer> y :cal NERDTreeCopyPath()<CR>
  autocmd FileType nerdtree noremap <silent> <buffer> <Tab> :cal NERDTreeQuickLook()<CR>
  autocmd FileType nerdtree noremap <silent> <buffer> R :cal NERDTreeMoveNode()<CR>
  autocmd FileType nerdtree noremap <silent> <buffer> M :call nerdtree#ui_glue#invokeKeyMap("m")<CR>
  autocmd FileType nerdtree noremap <silent> <buffer> mm :call NERDTreeBookmark('add')<CR>
  autocmd FileType nerdtree noremap <silent> <buffer> mf :call NERDTreeBookmark('reveal')<CR>
  autocmd FileType nerdtree noremap <silent> <buffer> mo :call NERDTreeBookmark('open')<CR>
  autocmd FileType nerdtree noremap <silent> <buffer> mc :ClearBookmarks<CR>
  autocmd FileType nerdtree noremap <silent> <buffer> mC :ClearAllBookmarks<CR>
augroup END

call NERDTreeAddKeyMap({
  \ 'key': 'a',
  \ 'callback': 'NERDTreeOpenInAlfred',
  \ 'quickhelpText': 'open in alfred',
  \ 'scope': 'Node' })

function! NERDTreeOpenInAlfred(node)
  call system("~/bin/alfred " . shellescape(a:node.path.str(), 1))
endfunction

call NERDTreeAddKeyMap({
  \ 'key': 'g<CR>',
  \ 'callback': 'NERDTreeSystemOpen',
  \ 'quickhelpText': 'open in system',
  \ 'scope': 'Node' })

function! NERDTreeSystemOpen(node)
  let cmd = has('mac') ? 'open' : 'xdg-open'
  call system(cmd . ' ' . shellescape(a:node.path.str(), 1))
endfunction

call NERDTreeAddKeyMap({
  \ 'key': '>',
  \ 'scope': 'Node',
  \ 'callback': '_NERDTreeRunCommand',
  \ 'quickhelpText': 'run command' })

function _NERDTreeRunCommand(node)
  call feedkeys(": ")
  call feedkeys(shellescape(a:node.path.str()), 't')
  call feedkeys("\<Home>")
  call feedkeys("!")
endfunction
