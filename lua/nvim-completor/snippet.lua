
local log = require("nvim-completor/log")

local M = {}

local function exract_var(str)
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
					local rp = exract_var(str:sub(ss, ee))
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
				str = (str:sub(1, ss - 1) or '') .. (str:sub(ee + 1) or '')
				table.insert(pos, {col = ss - 1, len = 0})
				offset = s
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
