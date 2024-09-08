function CustomOne()
  if vim.g.colors_name == 'one' then
    local col
    if vim.o.background == 'dark' then
      col = '090020'
      local highlights = {
        'Normal', 'Conceal', 'PMenuSbar', 'SignColumn', 'Error',
        'Todo', 'SpellBad', 'SpellCap', 'SpellRare', 'VertSplit',
        'SPCFloatBorder', 'ErrorMsg', 'Folded', 'SpellLocal',
        'EndOfBuffer'
      }
      for _, group in ipairs(highlights) do
        vim.fn['one#highlight'](group, '', col, '')
      end
      highlights = {
        'EndOfBuffer', 'SPCNormalFloat', 'Search', 'TabLineSel'
      }
      for _, group in ipairs(highlights) do
        vim.fn['one#highlight'](group, col, '', '')
      end
      
    else
      col = 'e6e6e6'
      vim.fn['one#highlight']('PMenuSel', '', col, '')
      vim.cmd('hi WinSeparator gui=NONE guifg=#' .. col)
    end
  end
end

CustomOne()
