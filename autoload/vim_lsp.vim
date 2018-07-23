""""""""""""""""""""""""""""""""""""""""""
"    LICENSE: MIT
"     Author: Cosson2017
"    Version: 0.2
" CreateTime: 2018-07-22 14:15:13
" LastUpdate: 2018-07-22 14:15:13
"       Desc: 
""""""""""""""""""""""""""""""""""""""""""


func! vim_lsp#server_initialized()
	call luaeval("require('complete-engine/vim-lsp').server_initialized()")
endfunc

func! vim_lsp#server_exited()
	call luaeval("require('complete-engine/vim-lsp').server_exited()")
endfunc

"return { 'line': line('.') - 1, 'character': col('.') -1 }
"character: 下标从1开始
"\   'position': {'line': a:ctx.line - 1, 'character': a:ctx.trigger_pos},
"
func! vim_lsp#lsp_complete(server_name, ctx)
	let l:col = a:ctx.col
	let l:line = a:ctx.line - 1
    call lsp#send_request(a:server_name, {
        \ 'method': 'textDocument/completion',
        \ 'params': {
        \   'textDocument': lsp#get_text_document_identifier(),
        \   'position': {'line': l:line, 'character': l:col},
        \ },
        \ 'on_notification': function('vim_lsp#handle_lsp_completion', [a:ctx]),
        \ })
endfunc

func! vim_lsp#handle_lsp_completion(ctx, data)
"    if lsp#client#is_error(a:data) || !has_key(a:data, 'response') || !has_key(a:data['response'], 'result')
"		echo "err"
"	else
"		echo string(a:data)
"	endif
"
	call nvim_completor#log_debug(string(a:data))

	call luaeval("require('complete-engine/vim-lsp').handle_lsp_complete(_A.ctx, _A.data)", {
				\ "ctx": a:ctx,
				\ "data": a:data,
				\ })
endfunc
