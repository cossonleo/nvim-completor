local log = require("nvim-completor/log")
local vl = require("complete-engine/vim-lsp")

local lf = {}

lf.af = function() 
	lf.pre()
end

lf.pre = function()
	print("sss")
end
