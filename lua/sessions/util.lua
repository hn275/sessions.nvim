local picker = require("telescope.pickers")
local finder = require("telescope.finders")
local conf = require("telescope.config").value
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local theme = require("telescope.themes").get_ivy
local c = require("sessions.constants")

M = {}

M.get_all_sessions = function()
	local all_sessions = {}

	local handle = io.popen("ls " .. c.DIR)

	if handle ~= nil then
		local sessions = handle:read("*a"):gmatch("([^\n]+)")
		for session in sessions do
			table.insert(all_sessions, session)
		end
	end

	return all_sessions
end

M.load_session = function(session)
	local selected_session = c.DIR .. "/" .. session
	local session_inprogress = ("%s/.%s"):format(c.DIR, session)

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
	vim.cmd(("silent mksession! %s/%s"):format(c.DIR, session))
end

M.remove_session = function(session)
	vim.cmd(("silent !rm %s/%s"):format(c.DIR, session))
	-- TODO: delete session autocmd
end

M.telescope = function(title, callback)
	local all_sessions = {}

	local handle = io.popen("ls " .. c.DIR)

	if handle ~= nil then
		local sessions = handle:read("*a"):gmatch("([^\n]+)")
		for session in sessions do
			table.insert(all_sessions, session)
		end
	end

	(function(opts)
		local config = opts or {}
		picker
			.new(config, {
				prompt_title = title,
				finder = finder.new_table({
					results = all_sessions,
				}),
				sorter = conf and conf.generic_sorter(config),
				attach_mappings = function(prompt_bufnr)
					actions.select_default:replace(function()
						actions.close(prompt_bufnr)
						local entry = action_state.get_selected_entry()

						if entry ~= nil then
							callback(entry[1])
						else
							callback(nil)
						end
					end)
					return true
				end,
			})
			:find()
	end)(theme({}))
end

return M
