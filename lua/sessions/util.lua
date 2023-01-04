local c = require("sessions.constants")

M = {}

M.load_session = function(session)
	local sourced_ok, _ = pcall(vim.cmd, ("silent source %s/%s"):format(c.DIR, session))
	if not sourced_ok then
		print("Failed to source session ", session)
	end
end

return M
