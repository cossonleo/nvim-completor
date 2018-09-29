""""""""""""""""""""""""""""""""""""""""""
"    LICENSE: MIT
"     Author: Cosson2017
"    Version: 0.2
" CreateTime: 2018-03-11 15:59:12
" LastUpdate: 2018-03-18 18:17:50
"       Desc: 
""""""""""""""""""""""""""""""""""""""""""
"let s:log_level = get(g: "nvim_completor_log_level", 2)


"func! nvim_completor#on_insert_leave()
"	call luaeval("require('nvim-completor/complete').reset_default()")
"endfunc


func! nvim_completor#on_insert_enter()
	setlocal completeopt-=longest
	setlocal completeopt+=menuone
	setlocal completeopt-=menu
	setlocal completeopt+=noselect
	setlocal completeopt+=noinsert
	call luaeval("require('nvim-completor/lang-spec').set_ft()")
endfunc

func! nvim_completor#on_text_changed()
	if nvim_completor#menu_selected() == 1
		return
	endif
	call luaeval("require('nvim-completor/complete').text_changed()")
endfunc

func! nvim_completor#on_text_changedp()
	if nvim_completor#menu_selected() == 1
		return
	endif
	call luaeval("require('nvim-completor/complete').text_changedp()")
endfunc

func! nvim_completor#on_complete(startcol, matchs)
	call complete(a:startcol, a:matchs)
	return ''
endfunc

func! nvim_completor#menu_selected()
	if pumvisible() "&& !empty(v:completed_item)
		return 1
	endif
	return 0
endfunc

func! s:log_prefix(level)
	let l:prefix = strftime("%Y-%m-%d %H:%M:%S ") . "[" . a:level . "] "
	return l:prefix
endfunc

func! s:write_log(line)
	let l:log_file = "/tmp/nvim-completor.log"
	let l:max_file_size = 10 * 1024 * 1024
	let l:file_flag = "a"
	let l:file_size = getfsize(l:log_file)
	
	if l:file_size > l:max_file_size
		let l:file_flag = ""
	endif

	call writefile([a:line], l:log_file, l:file_flag)
endfunc

" log level: 4
func! nvim_completor#log_debug(line)
	"if s:log_level < 4
	"	return
	"end

	let l:prefix = s:log_prefix("debug")
	call s:write_log(l:prefix . a:line)
endfunc
