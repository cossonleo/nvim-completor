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

autocmd TextChangedP * call lsp_completor#on_text_changedp()
autocmd TextChangedI * call lsp_completor#on_text_changed()
autocmd InsertLeave * call lsp_completor#on_insert_leave()
autocmd InsertEnter * call lsp_completor#on_insert_enter()
"autocmd MenuPopup * call lsp_completor#on_menupopup()
"autocmd CompleteDone * call lsp_completor#on_text_changedp()
