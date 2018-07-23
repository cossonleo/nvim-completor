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

" level
" debug 4
" warn 3
" info 2
" error 1
"let g:nvim_completor_log_level = 4

autocmd TextChangedP * call nvim_completor#on_text_changedp()
autocmd TextChangedI * call nvim_completor#on_text_changed()
"autocmd InsertLeave * call lsp_completor#on_insert_leave()
autocmd InsertEnter * call nvim_completor#on_insert_enter()
"
au User lsp_server_init call vim_lsp#server_initialized()
au User lsp_server_exit call vim_lsp#server_exited()

au FileType go call go_key#complete_engine_reg()

"call lsp_completor#server_initialized()

"augroup ayncomplete
"    autocmd! * <buffer>
"    autocmd InsertEnter <buffer> call s:on_insert_enter()
"    autocmd InsertLeave <buffer> call s:on_insert_leave()
"    autocmd TextChangedI <buffer> call s:on_text_changed()
"    autocmd TextChangedP <buffer> call s:on_text_changed()
"augroup END
