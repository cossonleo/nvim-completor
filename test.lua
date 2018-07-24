local log = require("nvim-completor/log")
local vl = require("complete-engine/vim-lsp")

local lf = {}

lf.af = function() 
	lf.pre()
end

lf.pre = function()
	print("sss")
end

function test(param, ...)
	local m = {"ss", "ddd"}
	table.remove(m, 2)
	for i, m in pairs(m) do
		print(m)
	end
end

test("sss")
