""""""""""""""""""""""""""""""""""""""""""
"    LICENSE: MIT
"     Author: Cosson2017
"    Version: 0.1
" CreateTime: 2018-03-07 12:13:15
" LastUpdate: 2018-03-07 12:13:15
"       Desc: 
""""""""""""""""""""""""""""""""""""""""""

if exists('g:neo_completor_load')
    finish
endif
let g:neo_completor_load = 1

setlocal completeopt-=longest
setlocal completeopt+=menuone
setlocal completeopt-=menu
setlocal completeopt+=noselect

"autocmd TextChangedI * call On_text_changed()
func! On_text_changed()
	lua << EOF
	local cm = require("complete")
	cm.text_changed()
EOF
endfunc
