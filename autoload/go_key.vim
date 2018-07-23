""""""""""""""""""""""""""""""""""""""""""
"    LICENSE: 
"     Author: 
"    Version: 
" CreateTime: 2018-07-23 16:32:15
" LastUpdate: 2018-07-23 16:32:15
"       Desc: 
""""""""""""""""""""""""""""""""""""""""""

func! go_key#complete_engine_reg()
	call luaeval("require('complete-engine/go-key')")
endfunc
