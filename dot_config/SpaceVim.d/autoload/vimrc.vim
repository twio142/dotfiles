function! SetBackground()
  let g:spacevim_colorscheme_bg = system('~/.local/bin/background')
  if g:spacevim_colorscheme_bg == 'light'
    set background=light
  else
    set background=dark
  endif
endfunction

function! vimrc#before() abort
  call SetBackground()
  if has('vim')
    set shadafile=$XDG_STATE_HOME/vim/viminfo
  endif
  let g:python3_host_prog='~/miniconda3/envs/py3/bin/python'
  let g:python_host_prog='~/miniconda3/envs/py2/bin/python'
  let g:node_host_prog='/usr/local/bin/node'
  let g:tern#command = ['node', expand('$XDG_DATA_HOME') . '/npm/bin/tern', '--no-port-file']
  let g:loaded_ruby_provider = 0
  let g:loaded_perl_provider = 0
  let g:copilot_no_tab_map = v:true
  let g:WebDevIconsOS = 'Darwin'
  let g:DevIconsEnableFoldersOpenClose = 1
  let g:DevIconsDefaultFolderOpenSymbol = ''
  let g:CtrlSpaceCacheDir = $XDG_CACHE_HOME . '/SpaceVim.d'

  " let g:sneak#s_next = 1
  
  augroup JavaScript
    autocmd!
    au FileType javascript nnoremap <buffer> <f5> :call SpaceVim#plugins#runner#open('node ' . expand('%'))<CR>
  augroup END

endfunction

function! vimrc#after() abort
  source $XDG_CONFIG_HOME/SpaceVim.d/vim/config.vim
endfunction
