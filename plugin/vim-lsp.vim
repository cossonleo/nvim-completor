""""""""""""""""""""""""""""""""""""""""""
"    LICENSE: 
"     Author: 
"    Version: 
" CreateTime: 2018-08-01 12:32:13
" LastUpdate: 2018-08-01 12:32:13
"       Desc: 
""""""""""""""""""""""""""""""""""""""""""

let g:load_nvim_completor_lsp = get(g:, "load_nvim_completor_lsp", 0)
if g:load_nvim_completor_lsp == 0
	finish
endif

if exists("s:is_load")
	call nvim_completor#log_debug("vim-lsp complete is load")
	finish
end
let s:is_load = 1

au User lsp_server_init call vim_lsp#server_initialized()
au User lsp_server_exit call vim_lsp#server_exited()
call vim_lsp#init()
