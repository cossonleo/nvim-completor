
local log = require('nvim-completor/log')
local manager = require("nvim-completor/src-manager")
local completor = require("nvim-completor/completor")
local ncp_lsp = require("nvim-completor/lsp")

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
			if err then
				log.debug("lsp complete err ", err)
				return
			end

			local items = result.items or result
			local items = ncp_lsp.lsp_items2vim(ctx, items)

			if not items or #items == 0 then
				return
			end
			completor.add_complete_items(ctx, items)
			log.debug(result)
            -- on_completion_result(context, err, _, result)
        end
    )
end

function response(ctx)
	completor.add_complete_items()
end

manager:add_src("builtin_lsp", request_src)
log.info("add builtin lsp complete source finish")
