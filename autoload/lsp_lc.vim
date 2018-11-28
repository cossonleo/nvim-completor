""""""""""""""""""""""""""""""""""""""""""
"    LICENSE: 
"     Author: 
"    Version: 
" CreateTime: 2018-09-26 14:58:22
" LastUpdate: 2018-09-26 14:58:22
"       Desc: 
""""""""""""""""""""""""""""""""""""""""""

func! lsp_lc#reg_lsc()
	call luaeval("require('complete-engine/lsp-lc').init()")
endfunc

func! lsp_lc#complete(ctx)
	"\ 'character': LSP#character(),
    let l:params = {
                \ 'filename': LSP#filename(),
                \ 'line': LSP#line(),
                \ 'character': a:ctx.col,
                \ 'handle': v:true,
                \ }

    "call extend(l:params, a:0 >= 1 ? a:1 : {})
    let l:Callback = function('lsp_lc#complete_callback', [a:ctx])
    return LanguageClient#Call('textDocument/completion', l:params, l:Callback)
endfunc

func! lsp_lc#complete_callback(ctx, ret_data)
	call nvim_completor#log_debug(string(a:ret_data))
	"call nvim_completor#log_debug(string(len(a:ret_data.result.items)))
	call luaeval("require('complete-engine/lsp-lc').complete_callback(_A.ctx, _A.data)", {
				\ "ctx": a:ctx,
				\ "data": a:ret_data,
				\ })
endfunc
