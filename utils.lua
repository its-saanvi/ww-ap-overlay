local M = {}

--- @param path string | nil
--- @return string | nil
M.normalize_path = function(path)
	if path == nil then
		return nil
	end
	local userhome = os.getenv("HOME") or nil
	if userhome == nil then
		return nil
	end
	path = path:gsub("~", userhome)
	path = path:gsub("(.*)/", "%1")
	return path
end

--- @param path string
--- @return boolean
M.file_exists = function(path)
	return os.execute("test -f " .. path) == 0
end

--- @param path string
--- @return string | nil
M.get_parent_dir = function(path)
	local parent = path:match("(.*)[/\\]")
	if not parent then
		return "."
	end

	-- Edge case: if it returns empty string (e.g. "/file.txt"), the parent is the root "/"
	if parent == "" then
		Log:error("Parent directory is empty string. This should not happen.")
		return nil
	end

	return parent
end

return M
