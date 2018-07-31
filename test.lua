local log = require("nvim-completor/log")
--local vl = require("complete-engine/vim-lsp")

--local lf = {}
--
--lf.af = function() 
--	lf.pre()
--end
--
--lf.pre = function()
--	print("sss")
--end
--
--function test(param, ...)
--	local args = { ... }
--	if args[1] == "all" then
--		print("true")
--	end
--	print(args[1])
--end
--
--local table_to_string = function(t)
--	if t == nil then
--		return ""
--	end
--	if type(t) ~= "table" then
--		return ""
--	end
--	if #t == 0 then
--		return "{}"
--	end
--
--	local str = "{"
--	for i, v in pairs(t) do
--		str = str .. "[" .. i .. "]" .. "=" .. v .. ","
--	end
--
--	local len = string.len(str)
--	local chars = string.byte(str, 1, len)
--	chars[len] = '}'
--	return str
--end
--
--table_to_string({"ssss"})
--
--test("all", "all")
local ss = function()
	local str = "hello word dadfas, afdadfsf , afasdfs ,a fasd"
	for w in string.gmatch(str, "%w+") do
		print(w)
	end
end

ss()
