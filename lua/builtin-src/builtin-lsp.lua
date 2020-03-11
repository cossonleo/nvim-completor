
local manager = require("nvim-completor/src_manager")
local completor = require("nvim-completor/completor")

function request_src(ctx)
end

function response(ctx)
	completor.add_complete_items()
end

manager.add_src("builtin_lsp", request_src)
