""""""""""""""""""""""""""""""""""""""""""
"    LICENSE: 
"     Author: 
"    Version: 
" CreateTime: 2018-08-01 12:02:10
" LastUpdate: 2018-08-01 12:02:10
"       Desc: 
""""""""""""""""""""""""""""""""""""""""""
if exists("g:load_lua_key_complete") != 0 && g:load_lua_key_complete == 0
	finish
endif

if exists("s:is_load")
	call nvim_completor#log_debug("lua key complete is load")
	finish
end
let s:is_load = 1

call luaeval("require('complete-engine/lua-key').init()")
