""""""""""""""""""""""""""""""""""""""""""
"    LICENSE: MIT
"     Author: Cosson2017
"    Version: 0.2
" CreateTime: 2018-03-07 12:13:15
" LastUpdate: 2018-03-18 18:19:05
"       Desc: 
""""""""""""""""""""""""""""""""""""""""""
if exists('g:nvim_completor_load')
    finish
endif
let g:nvim_completor_load = 1

lua ncp = require('nvim-completor')
lua ncp.on_load()
lua ncp.set_log_level(4)
lua require("builtin-src")

autocmd TextChangedP * lua ncp.on_text_changed_p()
autocmd TextChangedI * lua ncp.on_text_changed_i()
autocmd InsertEnter * lua ncp.on_insert()
autocmd InsertLeave * lua ncp.on_insert_leave()
"autocmd CompleteDone * lua ncp.on_complete_done()
autocmd BufEnter * lua ncp.on_buf_enter()

"inoremap <expr> <cr> (pumvisible() ? <C-R>=TComplete()<CR> : "\<CR>")
inoremap <cr> <c-r>=CompleteDone()<CR>


func! CompleteDone()
	if pumvisible()
		call v:lua.ncp.on_complete_done()
		return "\<c-y>"
	else
		return "\<cr>"
	endif
endfunc


