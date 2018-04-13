""""""""""""""""""""""""""""""""""""""""""
"    LICENSE: MIT
"     Author: Cosson2017
"    Version: 0.2
" CreateTime: 2018-03-11 15:59:12
" LastUpdate: 2018-03-18 18:17:50
"       Desc: 
""""""""""""""""""""""""""""""""""""""""""
func! lsp_completor#server_initialized()
	call luaeval("require('vim-lsp').server_initialized()")
endfunc

func! lsp_completor#server_exited()
	call luaeval("require('vim-lsp').server_exited()")
endfunc

func! lsp_completor#on_insert_leave()
	call luaeval("require('complete').reset_default()")
endfunc


func! lsp_completor#on_insert_enter()
	setlocal completeopt-=longest
	setlocal completeopt+=menuone
	setlocal completeopt-=menu
	setlocal completeopt+=noselect
	setlocal completeopt+=noinsert
	call luaeval("require('trigger').set_ft()")
endfunc

func! lsp_completor#on_text_changed()
	call luaeval("require('complete').text_changed()")
endfunc

func! lsp_completor#on_text_changedp()
	call luaeval("require('complete').direct_complete()")
endfunc

"return { 'line': line('.') - 1, 'character': col('.') -1 }
"character: 下标从1开始
"\   'position': {'line': a:ctx.line - 1, 'character': a:ctx.trigger_pos},
func! lsp_completor#lsp_complete(server_name, ctx)
    call lsp#send_request(a:server_name, {
        \ 'method': 'textDocument/completion',
        \ 'params': {
        \   'textDocument': lsp#get_text_document_identifier(),
        \   'position': {'line': a:ctx.line - 1, 'character': len(a:ctx.typed)},
        \ },
        \ 'on_notification': function('lsp_completor#handle_lsp_completion', [a:ctx]),
        \ })
endfunc

func! lsp_completor#handle_lsp_completion(ctx, data)
"    if lsp#client#is_error(a:data) || !has_key(a:data, 'response') || !has_key(a:data['response'], 'result')
"		echo "err"
"	else
"		echo string(a:data)
"	endif
	
	call luaeval("require('complete').handle_completion(_A.ctx, _A.data)", {
				\ "ctx": a:ctx,
				\ "data": a:data,
				\ })
endfunc


func! lsp_completor#on_complete(startcol, matchs)
	call complete(a:startcol, a:matchs)
	return ''
endfunc

func! lsp_completor#menu_selected()
	if pumvisible() && !empty(v:completed_item)
		return 1
	endif
	return 0
endfunc


