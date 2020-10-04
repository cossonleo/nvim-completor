local log = require('nvim-completor/log')
local manager = require("nvim-completor/src-manager")
local completor = require("nvim-completor/completor")

local ts_locals = require'nvim-treesitter.locals'
local parsers = require'nvim-treesitter.parsers'
local ts_utils = require'nvim-treesitter.ts_utils'
local api = vim.api

local M = {}

M.match_kinds = {
	var = '[ts v]',
	method = '[ts m]',
	['function'] = '[ts fn]',
	['type'] = '[ts type]',
}

local function get_smallest_context(source)
	local scopes = ts_locals.get_scopes()
	local current = source

	while current ~= nil and not vim.tbl_contains(scopes, current) do
		current = current:parent()
	end

	return current or nil
end

local function prepare_match(match, kind)
	local matches = {}

	if match.node then
		table.insert(matches, { kind = M.match_kinds[kind] or '', def = match.node })
	else
		-- Recursion alert! Query matches can be nested N times deep (usually only 1 or 2).
		-- Go down until we find a node.
		for name, item in pairs(match) do
			vim.list_extend(matches, prepare_match(item, name))
		end
	end

	return matches 
end

local function get_complete_items(prefix, bufnr)
	if parsers.has_parser() then
		local at_point = ts_utils.get_node_at_cursor()
		local _, line_current, _, _, _ = unpack(vim.fn.getcurpos())

		local complete_items = {}
		-- Support completion-nvim customized label map

		-- Step 2 find correct completions
		for _, definitions in ipairs(ts_locals.get_definitions(bufnr)) do
			local matches = prepare_match(definitions)

			for _, match in ipairs(matches) do
				local node = match.def
				local node_scope = get_smallest_context(node)
				local start_line_node, _, _= node:start()

				local node_text = ts_utils.get_node_text(node, bufnr)[1]
				local full_text = vim.trim(
					api.nvim_buf_get_lines(bufnr, start_line_node, start_line_node + 1, false)[1] or '')

				if node_text 
					and (not node_scope or ts_utils.is_parent(node_scope, at_point) or match.kind == "f") 
					and (start_line_node <= line_current) then

			if vim.startswith(node_text, prefix) then
				table.insert(complete_items, {
					word = node_text:sub(#prefix + 1),
					abbr = node_text,
					kind = match.kind,
					menu = full_text,
					score = score,
					icase = 1,
					dup = 0,
					empty = 1
				})
			end
				end
			end
		end

		return complete_items
	else
		return {}
	end
end

local function request(ctx)
	local prefix = ctx.typed:match('[%w_]+$') or ""
	local items = get_complete_items(prefix, ctx.buf)
	completor.add_complete_items(ctx, items)
end

manager:add_src("ts_complete", request)
log.info("add treesitter complete source finish")
