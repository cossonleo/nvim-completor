""""""""""""""""""""""""""""""""""""""""""
"    LICENSE: MIT
"     Author: Cosson2017
"    Version: 0.1
" CreateTime: 2018-03-07 12:13:15
" LastUpdate: 2018-03-07 12:13:15
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

autocmd TextChangedI * call complete#on_text_changed()
"inoremap <c-n> <C-R>=complete#on_text_changed()<CR>
func! complete#on_text_changed()
	lua << EOF
	local cm = require("complete")
	cm.text_changed()
EOF
endfunc

        "\ 'on_notification': function('complete#handle_lsp_completion', [a:ctx]),
func! complete#lsp_complete(server_name, ctx)
	"call complete(a:ctx.start, [a:ctx.typed, a:server_name])
    call lsp#send_request(a:server_name, {
        \ 'method': 'textDocument/completion',
        \ 'params': {
        \   'textDocument': lsp#get_text_document_identifier(),
        \   'position': lsp#get_position(),
        \ },
        \ 'on_notification': function('complete#handle_lsp_completion', [a:ctx]),
        \ })
endfunc

func! complete#handle_lsp_completion(ctx, data)
	"echomsg a:data[0]["insertText"]
	
    if lsp#client#is_error(a:data) || !has_key(a:data, 'response') || !has_key(a:data['response'], 'result')
		--echo "err"
	else
		--echo string(a:data)
	endif


	"for key in keys(a:data[0])
	"   echo key . ': ' . a:data[0][key]
	"endfor


	local ctx = vim.api.nvim_eval('a:ctx')
	local data = vim.api.nvim_eval('a:data')

	local cm = require("complete")
	cm.handle_completion(cx, dt)
EOF
endfunc

