augroup NERDTree
  autocmd!
  " Open the existing NERDTree on each new tab.
  autocmd BufWinEnter * if &buftype != 'quickfix' && getcmdwintype() == '' | silent NERDTreeMirror | endif
  autocmd FileType nerdtree noremap <silent> <buffer> <C-h> :TmuxNavigateLeft<CR>
  autocmd FileType nerdtree noremap <silent> <buffer> <C-j> :TmuxNavigateDown<CR>
  autocmd FileType nerdtree noremap <silent> <buffer> <C-k> :TmuxNavigateUp<CR>
  autocmd FileType nerdtree noremap <silent> <buffer> <C-l> :TmuxNavigateRight<CR>
  autocmd FileType nerdtree noremap <silent> <buffer> <C-r> :NERDTreeRefreshRoot<CR>
  autocmd FileType nerdtree noremap <silent> <buffer> y :cal NERDTreeCopyPath()<CR>
  autocmd FileType nerdtree noremap <silent> <buffer> <Tab> :cal NERDTreeQuickLook()<CR>
  autocmd FileType nerdtree noremap <silent> <buffer> M :cal NERDTreeMoveNode()<CR>
augroup END

call NERDTreeAddKeyMap({
  \ 'key': 'a',
  \ 'callback': 'NERDTreeOpenInAlfred',
  \ 'quickhelpText': 'open in alfred',
  \ 'scope': 'Node' })

function! NERDTreeOpenInAlfred(node)
    execute "!~/bin/alfred " . shellescape(a:node.path.str(), 1)
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
