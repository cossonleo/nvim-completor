""""""""""""""""""""""""""""""""""""""""""
"    LICENSE: MIT
"     Author: Cosson2017
"    Version: 0.1
" CreateTime: 2018-11-28 22:22:45
" LastUpdate: 2018-11-28 22:22:45
"       Desc: log file
""""""""""""""""""""""""""""""""""""""""""

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
" info 1
" error 2
" warn 3
" debug 4
func! nvim_log#log_debug(line)
	let g:ncp_log_level = get(g:, "ncp_log_level", 1)
	if g:ncp_log_level < 4
		return
	endif

	let l:prefix = s:log_prefix("debug")
	call s:write_log(l:prefix . a:line)
endfunc

func! nvim_log#log_warn(line)
	let g:ncp_log_level = get(g:, "ncp_log_level", 1)
	if g:ncp_log_level < 3
		return
	endif

	let l:prefix = s:log_prefix("warn")
	call s:write_log(l:prefix . a:line)
endfunc

func! nvim_log#log_error(line)
	let g:ncp_log_level = get(g:, "ncp_log_level", 1)
	if g:ncp_log_level < 2
		return
	endif

	let l:prefix = s:log_prefix("error")
	call s:write_log(l:prefix . a:line)
endfunc

func! nvim_log#log_info(line)
	let g:ncp_log_level = get(g:, "ncp_log_level", 1)
	if g:ncp_log_level < 1
		return
	endif

	let l:prefix = s:log_prefix("info")
	call s:write_log(l:prefix . a:line)
endfunc
