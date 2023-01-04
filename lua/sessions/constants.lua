M = {}

M.DIR = vim.fn.stdpath("data") .. "/session_manager"

M.SESSION_GR_NAME = "SessionManagerGr"
M.SESSION_GR = vim.api.nvim_create_augroup(M.SESSION_GR_NAME, { clear = true })
M.SESSION_DIR = vim.fn.stdpath("data") .. "/session_manager"

-- M.CACHED_GR_NAME = "SessionManagerCached"
-- M.CACHED_GR = vim.api.nvim_create_augroup(M.SESSION_GR_NAME, { clear = true })
M.CACHED_SESSION = ".cached_session.vim"

M.SUB = "SessionManagerSub"

return M
