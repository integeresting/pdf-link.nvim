local M = {}

M.open_pdf_link = function()
	local utils = require("md-pdf-link.utils")
	local pagenr, path = utils.parse_pdf_link()
	local buf_dir = utils.cur_buf_dir()

	if pagenr and path and buf_dir then
		os.execute("cd " .. buf_dir .. ";" .. "zathura " .. path .. " --page=" .. pagenr .. " &")
	end
end

M.put_pdf_link = function()
	local utils = require("md-pdf-link.utils")
	local options = require("md-pdf-link.config").options
	local pwd = vim.fn.getcwd()
	local pid_cmd =
			io.popen("busctl list --unique --user | awk '$0 ~ /zathura/ {print $2}'")
	if pid_cmd == nil then
		utils.log("failed to query dbus", "error")
		return
	end
	local pid = pid_cmd:read("*l")
	pid_cmd:close()

	if pid == nil then
		utils.log("could not find zathura instance", "error")
		return
	end
	local dbus_cmd = io.popen(
		"busctl get-property --user org.pwmt.zathura.PID-" ..
		pid .. " /org/pwmt/zathura org.pwmt.zathura pagenumber filename"
	)
	if dbus_cmd == nil then
		utils.log("failed to query dbus for zathura", "error")
		return
	end
	local page = dbus_cmd:read("*l"):sub(3) + 1
	local path = dbus_cmd:read("*l"):sub(4, -2)
	local relative_path = path:gsub(pwd, "", 1)

	if #path > #relative_path then
		path = "." .. relative_path
	end

	dbus_cmd:close()

	vim.api.nvim_put(
		{ "[" .. options.markdown_link.description .. " (" .. page .. ")](" .. path .. ")" },
		"l", true, false
	)
end

M.make_word_list = function()
	local utils = require("md-pdf-link.utils")
	local _, path = utils.parse_pdf_link()
	local buf_dir = utils.cur_buf_dir()
	local pdf_name = "DICT-" .. path:gsub(".*/", "")
	local words = {}

	local text_cmd = io.popen("cd " .. buf_dir .. ";" .. "pdftotext " .. path .. " -")
	if text_cmd == nil then
		utils.log("failed to convert pdf '" .. path .. "' at '" .. buf_dir .. "' to text", "error")
		return
	end

	for line in text_cmd:lines() do
		if line == nil then goto continue end
		for match in line:gmatch("[a-zA-ZüöäÜÖÄß" .. utils.diaeresis .. "]+") do
			if #match < 3 then goto continue end
			match = utils.decode_umlaute(match)
			words[match] = (words[match] or 0) + 1
		end
		:: continue ::
	end

	local scratch = vim.api.nvim_create_buf(true, true)
	if scratch == 0 then
		utils.log("failed to create scratch buffer", "error")
		return
	end

	if not pcall(vim.api.nvim_buf_set_name, scratch, pdf_name) then
		vim.api.nvim_buf_delete(scratch, {})
		utils.log("Word list for '" .. pdf_name .. "' seems to exist... ABORTING", "warn")
		return
	end

	for word in pairs(words) do
		vim.api.nvim_buf_set_lines(scratch, 0, 0, true, { word })
	end
	utils.log("Created word list for '" .. pdf_name .. "'!", "info")
end

return M
