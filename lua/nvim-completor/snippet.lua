
local log = require("nvim-completor/log")

local M = {}

local function exract_placeholder(str)
	local s, e = str:find("[0-9]+")
	if s and s == 3 and e == #str - 1 then
		return '$' .. str:sub(s, e)
	end

	s = str:find(":")
	if not s then
		return nil
	end
	return str:sub(s+1, #str-1)
end

local convert_step = function(str, offset)
	local s = str:find("%$", offset)
	if not s or s == #str then return end
	local next_char = str:sub(s+1, s+1)
	if next_char == "{" then
		local ss, ee = str:find("%$%b{}", s)
		if not ss then return str, s + 2 end

		local ph = exract_placeholder(str:sub(ss, ee))
		if not ph then return str, ee + 1 end

		local fstr = (str:sub(1, ss - 1) or '') .. ph .. (str:sub(ee + 1) or '')
		return fstr, ss + #ph, {col = ss - 1, len = #ph}
	end

	if '0' <= next_char and next_char <= '9' then
		local ss, ee = str:find("%$[0-9]+", s)
		return str, ee + 1, {col = ss - 1, len = ee - ss + 1}
	end

	return str, s + 1
end

local convert_iter = function(str)
	local phs = {}
	local offset = 1
	local fstr = str
	return function()
		fstr, offset, ph = convert_step(fstr, offset)
		if not fstr then return end

		if ph then table.insert(phs, ph) end
		return fstr, phs
	end
end

M.convert_to_str_item = function(str)
	local final_phs = {}
	local final_str = str

	for fstr, phs in convert_iter(str) do
		final_str,final_phs = fstr, phs
	end

	print(final_str, vim.fn.string(final_phs))
	return {str = final_str, phs = final_phs}
end

M.replace_snippet = function(str)
	local pos = {}
	local stop = false
	local offset = 1
	repeat
		local s = str:find("%$", offset)
		if not s or s == #str then
			stop = true
		else
			local next_char = str:sub(s+1, s+1)
			if next_char == "{" then
				local ss, ee = str:find("%$%b{}", s)
				if ss then
					local rp = exract_placeholder(str:sub(ss, ee))
					if rp then
						str = (str:sub(1, ss - 1) or '') .. rp .. (str:sub(ee + 1) or '')
						table.insert(pos, {col = ss - 1, len = #rp})
						offset = ss + #rp
					else
						offset = ee + 1
					end
				else
					offset = s + 2
				end
			elseif '0' <= next_char and next_char <= '9' then
				local ss, ee = str:find("%$[0-9]+", s)
				-- str = (str:sub(1, ss - 1) or '') .. (str:sub(ee + 1) or '')
				table.insert(pos, {col = ss - 1, ee - ss + 1})
				offset = ee + 1
			else
				offset = s + 1
			end
		end
	until stop

	local ret = {str = str}
	if #pos > 0 then
		ret.pos = pos
	end
	return ret
end

return M
