
local log = require("nvim-completor/log")

local M = {}

local function exract_placeholder(str)
	local s = str:find(":")
	if not s then
		return nil
	end

	local e = str:find(":", s + 1)
	if not e then
		e = #str
	end
	return str:sub(s+1, e-1)
end

local one_loop = function(str, offset, phs)
	local s = str:find("%$", offset)
	if not s or s == #str then return end
	local ret = {str = str, offset = offset, phs = phs}
	local next_char = str:sub(s+1, s+1)
	if next_char == "{" then
		local ss, ee = str:find("%$%b{}", s)
		if not ss then ret.offset = s + 2; return ret end

		local ph = exract_placeholder(str:sub(ss, ee))
		--if not ph then return { offset = ee + 1, str = str, phs = phs } end
		if not ph then ret.offset = ee + 1; return ret end

		ret.str = (str:sub(1, ss - 1) or '') .. ph .. (str:sub(ee + 1) or '')
		table.insert(ret.phs, {col = ss - 1, len = #ph})
		ret.offset = ss + #rp
		return ret
	end

	if '0' <= next_char and next_char <= '9' then
		local ss, ee = str:find("%$[0-9]+", s)
		table.insert(ret.phs, {col = ss - 1, len = ee - ss + 1})
		ret.offset = ee + 1; return ret
	end

	ret.offset = s + 1; return ret
end

local iter = function(str)
	return function(unuse, stat)
		one_loop(stat.str, stat.offset, stat.phs)
	end, true, {str = str, offset = 1, phs = {}}
end

M.new_replace_snippet = function(str)
	local phs = {}
	local final_str = str

	for stat in iter(str) do
		final_str = stat.str
		phs = stat.phs
	end

	local ret = {str = final_str}
	if #phs > 0 then ret.pos = phs end
	return ret
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
