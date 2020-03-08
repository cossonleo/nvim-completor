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

lua	require('nvim-completor/event_handle').on_load()

autocmd TextChangedP * lua require('nvim-completor/event_handle').on_text_changed_p()
autocmd TextChangedI * lua require('nvim-completor/event_handle').on_text_changed_i()
autocmd InsertEnter * lua require('nvim-completor/event_handle').on_insert()
autocmd InsertLeave * lua require('nvim-completor/event_handle').on_leave()
autocmd CompleteDone * lua require('nvim-completor/event_handle').on_complete_done()
autocmd BufEnter * lua require('nvim-completor/event_handle').on_buf_enter()

"BufAdd
"
