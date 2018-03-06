

autocmd! * <buffer>
autocmd TextChangedI <buffer> call ListMonths()
"autocmd TextChangedP call s:on_text_changed()

inoremap <F4> <C-R>=On_text_changed()<CR>

func! On_text_changed()
	lua << EOF
	local cm = require("complete")
	cm.text_changed()
EOF
endfunc

func! ListMonths()
  call complete(col('.'), ['January', 'February', 'March',
	\ 'April', 'May', 'June', 'July', 'August', 'September',
	\ 'October', 'November', 'December'])
  return ''
endfunc

