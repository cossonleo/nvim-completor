--------------------------------------------------
--    LICENSE: MIT
--     Author: Cosson2017
--    Version: 0.3
-- CreateTime: 2018-07-24 15:56:23
-- LastUpdate: 2018-07-24 15:56:23
--       Desc: complete lua key work size large than 3
--------------------------------------------------

local module = {}
local private = {}

local cm = require("nvim-completor/complete")
local helper = require("nvim-completor/helper")
local log = require("nvim-completor/log")
local head_match = require("nvim-completor/head-fuzzy-match")

private.keys = nil

private.get_keys = function()
	if private.keys ~= nil and #private.keys > 0 then
		return private.keys
	end

	private.keys = {}
	table.insert(private.keys, {word = "local", abbr = "local", menu = "key", icase = 1, dup = 0})
	table.insert(private.keys, {word = "nil", abbr = "nil", menu = "key", icase = 1, dup = 0})
	table.insert(private.keys, {word = "function", abbr = "function", menu = "key", icase = 1, dup = 0})
	table.insert(private.keys, {word = "end", abbr = "end", menu = "key", icase = 1, dup = 0})
	table.insert(private.keys, {word = "return", abbr = "return", menu = "key", icase = 1, dup = 0})
	table.insert(private.keys, {word = "module", abbr = "module", menu = "key", icase = 1, dup = 0})
	table.insert(private.keys, {word = "while", abbr = "while", menu = "key", icase = 1, dup = 0})
	table.insert(private.keys, {word = "not", abbr = "not", menu = "key", icase = 1, dup = 0})
	table.insert(private.keys, {word = "or", abbr = "or", menu = "key", icase = 1, dup = 0})
	table.insert(private.keys, {word = "and", abbr = "and", menu = "key", icase = 1, dup = 0})
	table.insert(private.keys, {word = "repeat", abbr = "repeat", menu = "key", icase = 1, dup = 0})
	table.insert(private.keys, {word = "util", abbr = "util", menu = "key", icase = 1, dup = 0})
	table.insert(private.keys, {word = "break", abbr = "break", menu = "key", icase = 1, dup = 0})
	table.insert(private.keys, {word = "then", abbr = "then", menu = "key", icase = 1, dup = 0})
	table.insert(private.keys, {word = "elseif", abbr = "elseif", menu = "key", icase = 1, dup = 0})
	table.insert(private.keys, {word = "true", abbr = "true", menu = "key", icase = 1, dup = 0})
	table.insert(private.keys, {word = "false", abbr = "false", menu = "key", icase = 1, dup = 0})
	return private.keys
end

private.lua_key_complete = function(ctx)
	local ft = helper.get_filetype()
	if ft == nil and ft ~= "lua" then
		return
	end

	local typed = helper.get_line_last_word(ctx.col)
	if typed == nil or string.len(typed) == 0 then
		return
	end
	local all_keys = private.get_keys()
	local matchs = head_match.simple_match(all_keys, typed)
	for _, match in ipairs(matchs) do
		match.word = string.sub(match.word, #typed + 1)
	end
	cm.add_candidate(ctx, matchs)
	return
end

private.init = function()
	cm.add_engine(private.lua_key_complete, "lua")
	log.debug("add lua key complete engine success")
end

module.init = private.init
return module
