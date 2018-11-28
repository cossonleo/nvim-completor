""""""""""""""""""""""""""""""""""""""""""
"    LICENSE: 
"     Author: 
"    Version: 
" CreateTime: 2018-09-28 21:38:54
" LastUpdate: 2018-09-28 21:38:54
"       Desc: 
""""""""""""""""""""""""""""""""""""""""""

if exists("g:load_rust_key_complete") != 0 && g:load_rust_key_complete == 0
	finish
endif

if exists("s:is_load")
	call nvim_log#log_info("rust key complete is load")
	finish
end
let s:is_load = 1

call luaeval("require('complete-engine/rust-key').init()")
