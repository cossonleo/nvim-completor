""""""""""""""""""""""""""""""""""""""""""
"    LICENSE: MIT
"     Author: Cosson2017
"    Version: 0.2
" CreateTime: 2018-03-07 12:13:15
" LastUpdate: 2018-03-18 18:19:05
"       Desc: 
""""""""""""""""""""""""""""""""""""""""""

if exists('g:neo_completor_load')
    finish
endif
let g:neo_completor_load = 1

autocmd TextChangedP * call lsp_completor#on_text_changedp()
"autocmd TextChangedP * call lsp_completor#on_text_changed()
autocmd TextChangedI * call lsp_completor#on_text_changed()
autocmd InsertLeave * call lsp_completor#on_insert_leave()
autocmd InsertEnter * call lsp_completor#on_insert_enter()


"augroup ayncomplete
"    autocmd! * <buffer>
"    autocmd InsertEnter <buffer> call s:on_insert_enter()
"    autocmd InsertLeave <buffer> call s:on_insert_leave()
"    autocmd TextChangedI <buffer> call s:on_text_changed()
"    autocmd TextChangedP <buffer> call s:on_text_changed()
"augroup END
