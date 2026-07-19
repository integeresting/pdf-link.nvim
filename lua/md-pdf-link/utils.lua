local M = {}

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
	return word
end

M.log = function(msg, level)
	local levels = { info = 2, warn = 3, error = 4 }
	vim.notify(msg, levels[level])
end

--- @return string pagenr, string path
M.parse_pdf_link = function()
	local line = vim.api.nvim_get_current_line()
	return line:match("%[.*%((%d+)%)%]%((%.?%.?/.*%.pdf)%)")
end

--- @return string buf_dir
M.cur_buf_dir = function()
	local cur_buf = vim.api.nvim_get_current_buf()
	local buf_path = vim.api.nvim_buf_get_name(cur_buf)
	return buf_path:match("(.*)/")
end

return M
