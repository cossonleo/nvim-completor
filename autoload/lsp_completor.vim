""""""""""""""""""""""""""""""""""""""""""
"    LICENSE: MIT
"     Author: Cosson2017
"    Version: 0.2
" CreateTime: 2018-03-11 15:59:12
" LastUpdate: 2018-03-18 18:17:50
"       Desc: 
""""""""""""""""""""""""""""""""""""""""""


func! lsp_completor#on_insert_leave()
lua << EOF
	local cm = require("complete")
	cm.reset_default()
EOF
endfunc


func! lsp_completor#on_insert_enter()
	setlocal completeopt-=longest
	setlocal completeopt+=menuone
	setlocal completeopt-=menu
	setlocal completeopt+=noselect
lua << EOF
	local ft = require("ft")
	ft.set_ft()
EOF
endfunc

let s:lock = 0

func! lsp_completor#on_text_changed()
lua << EOF
	local cm = require("complete")
	cm.text_changed()
EOF
endfunc

func! lsp_completor#on_text_changedp()
lua << EOF
	local cm = require("complete")
	cm.direct_complete()
EOF
endfunc

"return { 'line': line('.') - 1, 'character': col('.') -1 }
"character: 下标从1开始
func! lsp_completor#lsp_complete(server_name, ctx)
	" 当输入非[%w_] 字符时 ctx.start 会超前 此时需要矫正
	let l:start = a:ctx.start
	if l:start > a:ctx.ed
		let l:start = a:ctx.ed
	endif

    call lsp#send_request(a:server_name, {
        \ 'method': 'textDocument/completion',
        \ 'params': {
        \   'textDocument': lsp#get_text_document_identifier(),
        \   'position': {'line': a:ctx.line - 1, 'character': l:start},
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

lua << EOF
	local ctx = vim.api.nvim_eval('a:ctx')
	local data = vim.api.nvim_eval('a:data')
	local cm = require("complete")
	cm.handle_completion(ctx, data)
EOF
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


