--------------------------------------------------
--    LICENSE: MIT
--     Author: Cosson2017
--    Version: 0.3
-- CreateTime: 2018-07-23 15:57:53
-- LastUpdate: 2018-07-23 15:57:53
--       Desc: go key length > 3 show
--------------------------------------------------

local module = {}
local private = {}

local cm = require("nvim-completor/complete")
local helper = require("nvim-completor/helper")
local log = require("nvim-completor/log")
local head_match = require("nvim-completor/head-fuzzy-match")
local cu = require("complete-engine/complete-util")

private.keys = {
	"type",
	"struct",
	"interface",
	"import",
	"package",
	"const",
	"return",
	"chan",
	"continue",
	"break",
	"select",
	"case",
	"switch",
	"range",
	"func",
	"defer",
	"else",
	"default",
	"iota"
}

private.go_key_complete = function(ctx)
	local ft = helper.get_filetype()
	if ft == nil and ft ~= "go" then
		return
	end

	local typed = helper.get_line_last_word(ctx.col)
	if typed == nil or string.len(typed) == 0 then
		return
	end

	local matchs = head_match.simple_match(private.keys, typed)
	local candi = {}
	for _, match in ipairs(matchs) do
		local mw = string.sub(match, #typed + 1)
		local c = cu.convert_to_vim_completion(mw, match)
		if c ~= nil then
			table.insert(candi, c)
		end
	end
	cm.add_candidate(ctx, candi)
	return
end

private.init = function()
	cm.add_engine(private.go_key_complete, "go")
	log.info("add go key complete engine success")
end

module.init = private.init
return module
