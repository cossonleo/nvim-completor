
local log = require('nvim-completor/log')
local manager = require("nvim-completor/src-manager")
local completor = require("nvim-completor/completor")
local ncp_lsp = require("nvim-completor/lsp")
local semantics = require("nvim-completor/semantics")

local private = {}

function private.filter_items(ctx, items)
	if not items or #items == 0 then
		return {}
	end

	local new_items = items
	local prefix = ctx:typed_to_cursor()
	prefix = prefix:match("[%w_]+$")
	if prefix and #prefix > 0 then
		new_items = vim.tbl_filter(function(item)
		  local word = item.filterText or item.insertText or item.label
		  return vim.startswith(word, prefix)
		end, items)
	end

	-- 暂时去除snippet支持
	-- if new_items then
	-- 	for _, item in pairs(new_items) do
	-- 		local ft = semantics.get_ft()
	-- 		if ft == "rust" then
	-- 			item.textEdit.newText = item.textEdit.newText:match("^[%w_]+[!]?")
	-- 		elseif ft == "lua" then
	-- 			item.insertText = item.insertText:match("^[%w_]+")
	-- 		end
	-- 	end
	-- end
	log.trace("new items num: ", #new_items, " old items num: ", #items)
	return new_items
end

function private.request_src(ctx)
	if not ctx then
		return
	end
	local bufno = vim.api.nvim_get_current_buf()
	log.trace("builtin_lsp complete request")
	vim.lsp.buf_request(
        bufno,
        'textDocument/completion',
        ctx.pos,
        function(err, _, result)
			if err or not result then
				log.debug("lsp complete err ", err)
				return
			end

			log.trace("builtin lsp response")
			local items = result.items or result
			local incomplete = result.incomplete
			if incomplete then
				incomplete = "builtin_lsp"
			end
			--log.debug("---------------------------")
			--log.debug(items)
			--log.debug("+++++++++++++++++++++++++++")
			items = private.filter_items(ctx, items)
			items = ncp_lsp.lsp_items2vim(ctx, items)
			if not items or #items == 0 then
				return
			end
			completor.add_complete_items(ctx, items, incomplete)
        end
    )
end

manager:add_src("builtin_lsp", private.request_src)
log.info("add builtin lsp complete source finish")
