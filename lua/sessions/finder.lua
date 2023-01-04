local c = require("sessions.constants")

local util = require("sessions.util")

M = {}

M.find_session = function()
	-- TODO: untrack current track session (if any)
	util.telescope("Saved sessions", function(session)
		util.load_session(session)
		print("Sourced session:", session)
	end)
end

M.delete_session = function(session)
	-- TODO: handle session not found
	util.remove_session(session)
	print("Deleted session:", session)
end

M.new_session = function(s)
	util.make_session(s)
	util.load_session(s)
	print("Saved and tracked session:", s)
end

M.last_session = function()
	util.load_session(c.CACHED_SESSION)
	print("Sourced cached session.")
end

return M
