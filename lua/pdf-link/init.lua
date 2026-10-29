local M = {}

M.setup = function(opts)
	local config = require("pdf-link.config")
	config.setup(opts)
end

M.load = function()
	if vim.g.__loaded_md_pdf_link == true then
		return
	end

	vim.g.__loaded_pdf_link = true

	local keymaps = require("pdf-link.keymaps")
	local commands = require("pdf-link.commands")

	commands.create_user_command()
	keymaps.configure_keymaps()
end

return M
