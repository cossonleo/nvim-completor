""""""""""""""""""""""""""""""""""""""""""
"    LICENSE: 
"     Author: 
"    Version: 
" CreateTime: 2018-07-31 22:56:38
" LastUpdate: 2018-07-31 22:56:38
"       Desc: 
""""""""""""""""""""""""""""""""""""""""""

func! vim_lsc#reg_lsc()
	call luaeval("require('complete-engine/vim-lsc').init()")
endfunc

func! vim_lsc#complete(ctx)
	let l:col = a:ctx.col
	let l:line = a:ctx.line - 1
	let params = {
		\ 'textDocument': {'uri': lsc#uri#documentUri()},
		\ 'position': {'line': l:line, 'character': l:col}
		\ }
	call lsc#file#flushChanges()
	call lsc#server#call(&filetype, 'textDocument/completion', params,
		\ function('vim_lsc#complete_callback', [a:ctx]))
endfunc

func! vim_lsc#complete_callback(ctx, ret_data)
	call nvim_completor#log_debug(string(a:ret_data))
	call luaeval("require('complete-engine/vim-lsc').complete_callback(_A.ctx, _A.data)", {
				\ "ctx": a:ctx,
				\ "data": a:ret_data,
				\ })
endfunc
