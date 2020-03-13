
local log = require('nvim-completor/log')
local manager = require("nvim-completor/src-manager")
local completor = require("nvim-completor/completor")
local ncp_lsp = require("nvim-completor/lsp")
local semantics = require("nvim-completor/semantics")

function filter_items(ctx, items)
	if not items or #items == 0 then
		return {}
	end
	-- local ft = semantics.get_ft()
	-- if not ft or ft ~= "rust" then
	-- 	return items
	-- end

	local new_items = items
	local prefix = ctx:typed_to_cursor()
	prefix = prefix:match("[%w_]+$")
	if prefix and #prefix > 0 then
		new_items = vim.tbl_filter(function(item)
		  local word = (item.textEdit and item.textEdit.newText) or item.insertText or item.label
		  return vim.startswith(word, prefix)
		end, items)
	end

	-- 暂时去除snippet支持
	if new_items then
		for _, item in pairs(new_items) do
			local ft = semantics.get_ft()
			if ft == "rust" then
				item.textEdit.newText = item.textEdit.newText:match("^[%w_]+")
			elseif ft == "lua" then
				item.insertText = item.insertText:match("^[%w_]+")
			end
		end
	end
	return new_items
end

function request_src(ctx)
	log.debug("lsp request")
	if not ctx then
		return
	end
	local bufno = vim.api.nvim_get_current_buf()
	vim.lsp.buf_request(
        bufno,
        'textDocument/completion',
        ctx.pos,
        function(err, _, result)
			if err or not result then
				log.debug("lsp complete err ", err)
				return
			end

			local items = result.items or result
			log.debug(items)
			items = filter_items(ctx, items)
			items = ncp_lsp.lsp_items2vim(ctx, items)
			if not items or #items == 0 then
				return
			end
			completor.add_complete_items(ctx, items)
        end
    )
end

function response(ctx)
	completor.add_complete_items()
end

manager:add_src("builtin_lsp", request_src)
log.info("add builtin lsp complete source finish")
