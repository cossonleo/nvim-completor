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

autocmd TextChangedP * call nvim_completor#on_text_changedp()
autocmd TextChangedI * call nvim_completor#on_text_changed()
autocmd InsertEnter * call nvim_completor#on_insert_enter()
autocmd InsertLeave * call nvim_completor#on_insert_leave()
autocmd CompleteDone * call nvim_completor#on_complete_done()
