""""""""""""""""""""""""""""""""""""""""""
"    LICENSE: 
"     Author: 
"    Version: 
" CreateTime: 2018-07-23 16:32:15
" LastUpdate: 2018-07-23 16:32:15
"       Desc: 
""""""""""""""""""""""""""""""""""""""""""

func! lua_key#complete_engine_reg()
	if &filetype != "lua"
		return
	endif
	call luaeval("require('complete-engine/lua-key')")
endfunc
