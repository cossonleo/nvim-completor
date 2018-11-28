""""""""""""""""""""""""""""""""""""""""""
"    LICENSE: MIT
"     Author: Cosson2017
"    Version: 0.2
" CreateTime: 2018-03-11 15:59:12
" LastUpdate: 2018-03-18 18:17:50
"       Desc: 
""""""""""""""""""""""""""""""""""""""""""
"let s:log_level = get(g: "nvim_completor_log_level", 2)


func! nvim_completor#on_insert_leave()
	call luaeval("require('nvim-completor/complete').leave()")
endfunc


func! nvim_completor#on_insert_enter()
	setlocal completeopt-=longest
	setlocal completeopt+=menuone
	setlocal completeopt-=menu
	setlocal completeopt+=noselect
	setlocal completeopt+=noinsert
	call luaeval("require('nvim-completor/complete').enter()")
endfunc

func! nvim_completor#on_text_changed()
	if nvim_completor#menu_selected() == 1
		return
	endif
	call luaeval("require('nvim-completor/complete').text_changed()")
endfunc

func! nvim_completor#on_text_changedp()
	if !empty(v:completed_item)
		return
	endif
	call luaeval("require('nvim-completor/complete').text_changedp()")
endfunc

func! nvim_completor#on_complete(startcol, matchs)
	if mode() == "i" || mode() == "ic" || mode() == "ix"
		call complete(a:startcol, a:matchs)
	endif
	return ''
endfunc

func! nvim_completor#menu_selected()
	if pumvisible() && !empty(v:completed_item)
		return 1
	endif
	return 0
endfunc

