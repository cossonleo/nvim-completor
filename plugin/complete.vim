""""""""""""""""""""""""""""""""""""""""""
"    LICENSE: MIT
"     Author: Cosson2017
"    Version: 0.1
" CreateTime: 2018-03-07 12:13:15
" LastUpdate: 2018-03-08 18:36:00
"       Desc: 
""""""""""""""""""""""""""""""""""""""""""

if exists('g:neo_completor_load')
    finish
endif
let g:neo_completor_load = 1

setlocal completeopt-=longest
setlocal completeopt+=menuone
setlocal completeopt-=menu
setlocal completeopt+=noselect

autocmd TextChangedP * call complete#on_text_changedp()
autocmd TextChangedI * call complete#on_text_changed()
"autocmd MenuPopup * call complete#on_menupopup()
autocmd InsertLeave * call complete#on_insert_leave()
autocmd InsertEnter * call complete#on_insert_enter()
"autocmd CompleteDone * call complete#on_text_changedp()
inoremap <c-n> <C-R>=complete#on_manual()<CR>

func! complete#on_manual()
	call complete(1, ["aa", "bb", "cc", "dd"])
	call complete(1, ["ee", "gg", "ff", "ii"])
	return ''
endfunc

func! complete#on_insert_leave()
lua << EOF
	local cm = require("complete")
	cm.reset_default()
EOF
endfunc

func! complete#on_insert_enter()
lua << EOF
	local ft = require("ft")
	ft.set_ft()
EOF
endfunc

func! complete#on_menupopup()
endfunc

let s:count = 0
func! complete#on_text_changed()
	let s:count = s:count + 1
	echo "changed" . s:count
lua << EOF
	local cm = require("complete")
	cm.text_changed()
EOF
endfunc

func! complete#on_text_changedp()
	echo "changedp"
lua << EOF
	local cm = require("complete")
	cm.direct_complete()
EOF
endfunc

"return { 'line': line('.') - 1, 'character': col('.') -1 }
"character: 下标从1开始
func! complete#lsp_complete(server_name, ctx)
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
        \ 'on_notification': function('complete#handle_lsp_completion', [a:ctx]),
        \ })
endfunc

func! complete#handle_lsp_completion(ctx, data)
	
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

