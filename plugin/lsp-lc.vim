""""""""""""""""""""""""""""""""""""""""""
"    LICENSE: 
"     Author: 
"    Version: 
" CreateTime: 2018-09-26 15:10:29
" LastUpdate: 2018-09-26 15:10:29
"       Desc: 
""""""""""""""""""""""""""""""""""""""""""

let g:load_nvim_completor_languageclient_neovim = get(g:, "load_nvim_completor_languageclient_neovim", 0)
if g:load_nvim_completor_languageclient_neovim == 0
	finish
endif

if exists("s:is_load")
	call nvim_completor#log_debug("lsp-lc complete is load")
	finish
end
let s:is_load = 1

call lsp_lc#reg_lsc()
