""""""""""""""""""""""""""""""""""""""""""
"    LICENSE: 
"     Author: 
"    Version: 
" CreateTime: 2018-08-01 12:27:03
" LastUpdate: 2018-08-01 12:27:03
"       Desc: 
""""""""""""""""""""""""""""""""""""""""""

let g:load_nvim_completor_lsc = get(g:, "load_nvim_completor_lsc", 0)
if g:load_nvim_completor_lsc == 0
	finish
endif

if exists("s:is_load")
	call nvim_completor#log_debug("vim-lsc complete is load")
	finish
end
let s:is_load = 1

call vim_lsc#reg_lsc()
