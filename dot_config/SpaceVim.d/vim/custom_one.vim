function! CustomOne()
	if g:colors_name ==# 'one'
		if &background ==# 'dark'
			let s:col='101020'
			" call one#highlight('Normal', '', s:col, '')
			" call one#highlight('Conceal', '', s:col, '')
			" call one#highlight('PMenuSbar', '', s:col, '')
			" call one#highlight('SignColumn', '', s:col, '')
			" call one#highlight('Error', '', s:col, '')
			" call one#highlight('Todo', '', s:col, '')
			" call one#highlight('SpellBad', '', s:col, '')
			" call one#highlight('SpellCap', '', s:col, '')
			" call one#highlight('SpellRare', '', s:col, '')
			" call one#highlight('VertSplit', '', s:col, '')
			" call one#highlight('SPCFloatBorder', '', s:col, '')
			" call one#highlight('ErrorMsg', '', s:col, '')
			" call one#highlight('Folded', '', s:col, '')
			" call one#highlight('SpellLocal', '', s:col, '')
      " call one#highlight('EndOfBuffer', s:col, s:col, '')
			call one#highlight('SPCNormalFloat', s:col, '', '')
			call one#highlight('Search', s:col, '', '')
			call one#highlight('TabLineSel', s:col, '', '')
      " hi IndentBlanklineContextChar ctermfg=16 guifg=#3b4048
		else
			let s:col='e6e6e6'
			call one#highlight('Conceal', s:col, '', '')
			call one#highlight('LineNr', s:col, '', '')
			call one#highlight('PMenuSel', '', s:col, '')
      " hi IndentBlanklineContextChar ctermfg=251 guifg=#d3d3d3
		endif
    hi Normal guibg=NONE ctermbg=NONE
    hi EndOfBuffer guibg=NONE ctermbg=NONE
    hi Conceal guibg=NONE ctermbg=NONE
    hi PMenuSbar guibg=NONE ctermbg=NONE
    hi SignColumn guibg=NONE ctermbg=NONE
    hi Error guibg=NONE ctermbg=NONE
    hi Todo guibg=NONE ctermbg=NONE
    hi SpellBad guibg=NONE ctermbg=NONE
    hi SpellCap guibg=NONE ctermbg=NONE
    hi SpellRare guibg=NONE ctermbg=NONE
    hi VertSplit guibg=NONE ctermbg=NONE
    hi SPCFloatBorder guibg=NONE ctermbg=NONE
    hi ErrorMsg guibg=NONE ctermbg=NONE
    hi Folded guibg=NONE ctermbg=NONE
    hi SpellLocal guibg=NONE ctermbg=NONE
	endif
endfunction

call CustomOne()
