
local log = require('nvim-completor/log')
local manager = require("nvim-completor/src-manager")
local completor = require("nvim-completor/completor")
local ncp_lsp = require("nvim-completor/lsp")

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

	log.trace("new items num: ", #new_items, " old items num: ", #items)
	return new_items
end

function private.request_src(ctx)
	if not ctx then
		return
	end
	local bufno = vim.api.nvim_get_current_buf()
	log.trace("builtin_lsp complete request")
	params = {
		textDocument = { uri = vim.uri_from_bufnr(0) },
		position = {
			line = ctx.pos[1]; 
			character = vim.str_utfindex(ctx.typed, ctx.pos[2]); 
			-- character = ctx.pos[2]; 
		}
	}
	vim.lsp.buf_request(
        bufno,
        'textDocument/completion',
        params,
        function(err, _, result)
			if err or not result then
				log.warn("lsp complete err ", err)
				return
			end

			log.trace("builtin lsp response")
			local items = result.items or result
			local incomplete = result.incomplete
			if incomplete then
				incomplete = "builtin_lsp"
			end
			log.trace(items)
			items = private.filter_items(ctx, items)
			log.debug(items)
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
