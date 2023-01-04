local c = require("sessions.constants")

M = {}

M.load_session = function(session)
	local selected_session = c.DIR .. "/" .. session
	local session_inprogress = ("%s/*%s"):format(c.DIR, session)

	-- source session
	local sourced_ok, _ = pcall(vim.cmd, "silent source " .. selected_session)
	if not sourced_ok then
		print("Failed to source session ", session)
		return
	end

	vim.cmd("silent !rm " .. selected_session)
	vim.cmd("silent mksession! " .. session_inprogress)

	-- cached in temp session
	vim.api.nvim_create_autocmd({ "BufLeave" }, {
		group = c.SESSION_GR,
		callback = function()
			vim.cmd("silent mksession! " .. session_inprogress)
		end,
	})

	vim.api.nvim_create_autocmd({ "VimLeave" }, {
		group = vim.api.nvim_create_augroup(c.SUB, { clear = true }),
		callback = function()
			vim.cmd(("silent !rm %s"):format(session_inprogress))
			vim.cmd(("silent mksession! %s"):format(selected_session))
		end,
	})
end

M.make_session = function(session)
	vim.cmd("silent mksession! ", session)
end

return M
