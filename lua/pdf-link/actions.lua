local M = {}

M.open_pdf_link = function()
	local utils = require("pdf-link.utils")
	local link = utils.parse_pdf_link()
	local buf_dir = utils.cur_buf_dir()

	if link and buf_dir then
		os.execute("cd " .. buf_dir .. ";" .. "zathura " .. link.path .. " --page=" .. link.pagenr .. " &")
	else
		utils.log("could not find a link to open", "error")
	end
end

M.put_pdf_link = function()
	local utils = require("pdf-link.utils")
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

	dbus_cmd:close()

	local link = utils.format_link(path, page)
	if link then
		vim.api.nvim_put({ link }, "l", true, false)
	end
end

M.make_word_list = function()
	local utils = require("pdf-link.utils")
	local link = utils.parse_pdf_link()

	if link == nil then
		utils.log("could not find a link to open", "error")
		return
	end

	local buf_dir = utils.cur_buf_dir()
	local pdf_name = "DICT-" .. link.path:gsub(".*/", "")
	local words = {}

	local text_cmd = io.popen("cd " .. buf_dir .. ";" .. "pdftotext " .. link.path .. " -")
	if text_cmd == nil then
		utils.log("failed to convert pdf '" .. link.path .. "' at '" .. buf_dir .. "' to text", "error")
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
