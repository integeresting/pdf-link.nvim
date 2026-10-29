local M = {}

---parsed PDF link
---@class link
---@field path string
---@field pagenr string

M.diaeresis = "\204\136" -- "¨" unicode character

--- @param word string
--- @return string word
M.decode_umlaute = function(word)
	word = word
			:gsub("a" .. M.diaeresis, "ä")
			:gsub("u" .. M.diaeresis, "ü")
			:gsub("o" .. M.diaeresis, "ö")
			:gsub("A" .. M.diaeresis, "Ä")
			:gsub("U" .. M.diaeresis, "Ü")
			:gsub("O" .. M.diaeresis, "Ö")
			:gsub("\\303\\244", "ä")
			:gsub("\\303\\274", "ü")
			:gsub("\\303\\266", "ö")
			:gsub("\\303\\204", "Ä")
			:gsub("\\303\\234", "Ü")
			:gsub("\\303\\226", "Ö")

	return word
end

M.log = function(msg, level)
	local levels = { info = 2, warn = 3, error = 4 }
	vim.notify(msg, levels[level])
end

--- @return string | nil
M.git_root = function()
	local git_root = io.popen("git rev-parse --show-toplevel")
	if git_root == nil then
		return nil
	end

	local root = M.decode_umlaute(git_root:read("*l"))
	git_root:close()

	return root
end

--- links can be either absolute or relative to the git root
--- @return link | nil
M.parse_typst_pdf_link = function()
	local line = vim.api.nvim_get_current_line()
	local path, pagenr = line:match('#link%("(.*%.pdf)"%)%[.*%((%d+)%)%]')

	if path == nil or pagenr == nil then
		return nil
	end

	if path:sub(1, 1) == "/" then
		return { path = path, pagenr = pagenr }
	end

	local root = M.git_root()
	if root == nil then
		M.log("link appeared to be relative to a git root but no root was found", "error")
		return nil
	end

	return { path = root .. "/" .. M.decode_umlaute(path), pagenr = pagenr }
end

--- @return link | nil
M.parse_md_pdf_link = function()
	local line         = vim.api.nvim_get_current_line()
	local pagenr, path = line:match("%[.*%((%d+)%)%]%((%.?%.?/.*%.pdf)%)")

	if path == nil or pagenr == nil then
		return nil
	end

	return { path = M.decode_umlaute(path), pagenr = pagenr }
end

--- @return string buf_dir
M.cur_buf_dir = function()
	local cur_buf = vim.api.nvim_get_current_buf()
	local buf_path = vim.api.nvim_buf_get_name(cur_buf)
	return buf_path:match("(.*)/")
end

--- handles file format differences
--- @return link | nil
M.parse_pdf_link = function()
	local filetype = vim.o.filetype
	if filetype == "markdown" then
		return M.parse_md_pdf_link()
	elseif filetype == "typst" then
		return M.parse_typst_pdf_link()
	end
	error("unknown filetype: " .. filetype)
	return nil
end


--- @param page string
--- @param path string
--- @return string | nil
M.format_link = function(path, page)
	local filetype = vim.o.filetype
	local options = require("pdf-link.config").options
	local description = options.link.description
	path = M.decode_umlaute(path)
	if filetype == "markdown" then
		local pwd = M.decode_umlaute(vim.fn.getcwd())
		local relative_path = path:gsub(pwd, "", 1)

		if #path > #relative_path then
			path = "." .. relative_path
		end

		return "[" .. description .. " (" .. page .. ")](" .. path .. ")"
	elseif filetype == "typst" then
		local root = M.git_root()
		if root ~= nil and not options.link.typst_force_absolute then
			path = path:gsub(root .. "/", "", 1)
		end

		return '#link("' .. path .. '")' .. "[" .. description .. " (" .. page .. ")]"
	end
	error("unknown filetype: " .. filetype)
	return nil
end

return M
