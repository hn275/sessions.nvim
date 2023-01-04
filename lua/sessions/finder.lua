local picker = require("telescope.pickers")
local finder = require("telescope.finders")
local conf = require("telescope.config").value
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local theme = require("telescope.themes").get_cursor

local subscribe = require("sessions.autocmd").subscribe
local c = require("sessions.constants")

local load_session = require("sessions.util").load_session

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
				-- sorter = conf.generic_sorter(config),
				attach_mappings = function(prompt_bufnr)
					actions.select_default:replace(function()
						actions.close(prompt_bufnr)
						local entry = action_state.get_selected_entry()
						local query = action_state.get_current_line()

						if entry ~= nil then
							callback(entry[1], nil)
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
		vim.cmd(("silent !rm %s/%s"):format(c.DIR, session))
		-- cached in temp session
		vim.api.nvim_create_autocmd({ "BufEnter", "BufLeave" }, {
			group = c.SESSION_GR,
			callback = function()
				vim.cmd(("silent mksession! %s/.%s"):format(c.DIR, session))
			end,
		})
		-- rm cached, restore shada
		vim.api.nvim_create_autocmd({ "VimLeave" }, {
			group = c.SESSION_GR,
			callback = function()
				vim.cmd(("!mv %s/.%s %s/%s"):format(c.DIR, session, c.DIR, session))
			end,
		})
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
		if session ~= nil then
			vim.cmd(("silent mksession! %s/%s"):format(c.DIR, session))
			print(("Session overloaded: %s"):format(session))
		else
			vim.cmd(("silent mksession! %s/%s"):format(c.DIR, query))
			print(("Created session: %s"):format(query))
		end
		local sub = session or query
		print(sub)
		subscribe(sub)
	end)
end

M.last_session = function()
	vim.cmd(("silent source %s/%s"):format(c.DIR, c.CACHED_SESSION))
	print("Sourced cached session.")
end

return M
