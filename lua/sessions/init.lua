local c = require("sessions.constants")
local fn = require("sessions.finder")
local make_session = require("sessions.util").make_session

local flag_map = {
	["list"] = fn.find_session,
	["new"] = fn.new_session,
	["delete"] = fn.delete_session,
	["last"] = fn.last_session,
}

local get_all_flags = function()
	local flags = {}
	for k in pairs(flag_map) do
		table.insert(flags, k)
	end

	return flags
end

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

M = {}

M.setup = function()
	-- Autocmd
	vim.api.nvim_create_autocmd({ "VimEnter", "VimLeave" }, {
		group = c.SESSION_GR,
		pattern = { "*.*" },
		callback = function()
			make_session(c.CACHED_SESSION)
		end,
	})

	-- User command
	vim.api.nvim_create_user_command("Session", function(opt)
		local arg = opt.args
		flag_map[arg]()
	end, { nargs = 1, complete = get_all_flags })
end

M.setup()
return M
