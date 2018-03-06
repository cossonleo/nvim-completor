local api = {}

function api.get_curpos()
	local pos = vim.api.nvim_call_function('getcurpos', {})
	return {buf=pos[1], line=pos[2], col=pos[3]}
end

function api.cursor_pre_content()
	local pos = api.get_curpos()
	local pe = pos['col']
	if pe > 1 then
		pe = pe -1
	end

	return vim.api.nvim_call_function('getline', {'.'}):sub(1, pe)
end

function api.get_filetype()
	local pos = api.get_curpos()
	return vim.api.nvim_buf_get_option(pos['buf'], 'filetype')
end

function api.get_bufname()
	--return vim.api.nvim_call_function('buffer_name', {'%'})
	return vim.api.nvim_call_function('expand', {'%:p'})
end

return api

