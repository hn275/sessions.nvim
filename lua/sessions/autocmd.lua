local c = require("sessions.constants")

M = {}

M.subscribe = function(session_name)
	vim.api.nvim_create_autocmd({ "BufEnter", "BufLeave" }, {
		group = c.SESSION_GR,
		callback = function()
			vim.cmd(("mksession! %s/%s"):format(c.DIR, session_name))
		end,
	})
end

return M
