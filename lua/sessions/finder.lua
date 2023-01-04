local picker = require("telescope.pickers")
local finder = require("telescope.finders")
local conf = require("telescope.config").value
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local theme = require("telescope.themes").get_ivy

local c = require("sessions.constants")

local load_session = require("sessions.util").load_session
local make_session = require("sessions.util").make_session

local telescope = function(title, callback)
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
				sorter = conf.generic_sorter(config),
				attach_mappings = function(prompt_bufnr)
					actions.select_default:replace(function()
						actions.close(prompt_bufnr)
						local entry = action_state.get_selected_entry()
						local query = action_state.get_current_line()

						if entry ~= nil then
							local matched = entry[1]:find("^[*]")
							if matched then
								print("Session in used.")
							else
								callback(entry[1], nil)
							end
						else
							callback(nil, query)
						end
					end)
					return true
				end,
			})
			:find()
	end)(theme({}))
end

M = {}

M.find_session = function()
	telescope("Find session", function(session, _)
		load_session(session)
	end)
end

M.delete_session = function()
	telescope("Delete session", function(session, _)
		vim.cmd(("silent !rm -rf %s/%s"):format(c.DIR, session))
		print(("Deleted session: %s"):format(session))
	end)
end

M.new_session = function()
	telescope("Save session", function(session, query)
		local s = session or query
		vim.cmd(("silent mksession! %s/%s"):format(c.DIR, s))
		print(("Session overloaded: %s"):format(s))
		load_session(s)
	end)
end

M.last_session = function()
	vim.cmd(("silent source %s/%s"):format(c.DIR, c.CACHED_SESSION))
	print("Sourced cached session.")
end

return M
