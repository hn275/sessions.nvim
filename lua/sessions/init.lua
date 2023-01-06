local c = require("sessions.constants")
local fn = require("sessions.finder")
local make_session = require("sessions.util").make_session
local saved_sessions = require("sessions.util").get_all_sessions

-- check for file existence
local f = io.popen("ls " .. c.DIR)

if f == nil then
	error("Failed to find session path")
	return
end

local output = f:read("*a")
if output ~= nil then
	local handle = io.popen("mkdir -p " .. c.DIR)
	if handle == nil then
		error("Failed to create a cache sesison dir")
	end
end

Sessions = {}

Sessions.setup = function()
	-- Autocmd
	vim.api.nvim_create_autocmd({ "BufEnter", "BufLeave" }, {
		group = c.SESSION_GR,
		pattern = { "*.*" },
		callback = function()
			make_session(c.CACHED_SESSION)
		end,
	})

	-- User command
	vim.api.nvim_create_user_command("SessionFind", fn.find_session, {})

	vim.api.nvim_create_user_command("SessionNew", function(opt)
		local new_session = opt.args
		fn.new_session(new_session)
	end, { nargs = 1, complete = saved_sessions })

	vim.api.nvim_create_user_command("SessionDel", function(opt)
		local arg = opt.args
		fn.delete_session(arg)
	end, { nargs = 1, complete = saved_sessions })

	vim.api.nvim_create_user_command("SessionLast", fn.last_session, {})
end

return Sessions
