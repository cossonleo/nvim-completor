""""""""""""""""""""""""""""""""""""""""""
"    LICENSE: 
"     Author: 
"    Version: 
" CreateTime: 2018-08-01 12:20:21
" LastUpdate: 2018-08-01 12:20:21
"       Desc: 
""""""""""""""""""""""""""""""""""""""""""
if g:load_go_key_complete == 0
	finish
endif

if exists("s:is_load")
	call nvim_completor#log_debug("go key complete is load")
	finish
end
let s:is_load = 1

call luaeval("require('complete-engine/go-key').init()")
