""""""""""""""""""""""""""""""""""""""""""
"    LICENSE: 
"     Author: 
"    Version: 
" CreateTime: 2018-08-01 12:20:21
" LastUpdate: 2018-08-01 12:20:21
"       Desc: 
""""""""""""""""""""""""""""""""""""""""""
if exists("g:load_lua_key_complete") != 0 && g:load_go_key_complete == 0
	finish
endif

if exists("s:is_load")
	call nvim_log#log_info("go key complete is load")
	finish
end
let s:is_load = 1

call luaeval("require('complete-engine/go-key').init()")
