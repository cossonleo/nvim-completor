--------------------------------------------------
--    LICENSE: MIT
--     Author: Cosson2017
--    Version: 0.1
-- CreateTime: 2018-03-06 11:52:05
-- LastUpdate: 2018-03-06 11:52:05
--       Desc: relative filetype 
--------------------------------------------------

local ft = {}

local api = require("api")

local _ft_trigger = nil
local  _ft = nil

local _context = {
	bname = "",
	bno = 0,
	line = 0,
	filetype = "",
	typed = "",
	start = 0,
	ed = 0,
}

function _context:new(ctx)
	if ctx == nil then
		ctx = {}
		ctx.bname = ""
		ctx.bno = 0
		ctx.line = 0
		ctx.filetype = ""
		ctx.typed = ""
		ctx.start = 0
		ctx.ed = 0
	end

	setmetatable(ctx, self)
	self.__index = self
	return ctx
end

function _context:eq(ctx)
	if self.bname ~= ctx.bname then
		return false
	end
	if self.bno ~= ctx.bno then 
		return false
	end
	if self.line ~= ctx.line then
		return false
	end
	if self.filetype ~= ctx.filetype then
		return false
	end
	if self.start ~= ctx.start then
		return false
	end

	return true
end

local function _cfamily_trigger(str)
	if string.match(str, '.$') ~= nil then
		return true
	end
	if string.match(str, '->$') ~= nil then
		return true
	end
	if string.match(str, "::$") ~= nil then
		return true
	end
	return false
end

local function _lua_trigger(str)
	if string.match(str, "[.:]$") ~= nil then
		return true
	end
	return false
end

local function _go_trigger(str)
	if string.match(str, ".$") ~= nil then
		return true
	end
	return false
end

local function _trigger_request(str)
	local len = #str
	if len == 0 then
		return false
	end

	if len == 1 then
		if string.match(str, '[%a_]') ~= nil then
			return true
		end
		return false
	end


	st, ed = string.find(str, '[%a_][%w_]*$')

	-- 语义补全
	if st == nil then
		if _ft_trigger ~= nil then
			return _ft_trigger(str)
		end
		return false
	end

	if st < ed then
		return false
	end

	if _ft_trigger == nil then
		return false
	end

	local sub = string.sub(str, 1, ed - 1)

	return not _ft_trigger(sub)
end

local function _set_ft()
	_ft = api.get_filetype()

	if _ft == "lua" then
		_ft_trigger = _lua_trigger
	end

	if _ft == "c" or _ft == "cpp" or _ft == "cc" or _ft == "h" or _ft == "hpp" then
		_ft_trigger = _cfamily_trigger
	end

	if _ft == "go" then
		_ft_trigger = _go_trigger
	end

	ft.trigger_request = _trigger_request
	ft.filetype = _ft

end

ft.trigger_request = _trigger_request
ft.filetype = _ft
ft.set_ft = _set_ft
ft.context = _context

return ft

