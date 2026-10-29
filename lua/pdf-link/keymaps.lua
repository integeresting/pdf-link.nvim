local M = {}

M.configure_keymaps = function()
	local commands = require("pdf-link.commands")

	vim.keymap.set("n", "<Plug>(" .. commands.CMD_NAME .. "Open)", function()
			commands.subcommands.open.impl({}, { type = "md" })
		end,
		{
			desc = "open link to pdf",
			silent = true,
		}
	)

	vim.keymap.set("n", "<Plug>(" .. commands.CMD_NAME .. "Paste)", function()
			commands.subcommands.paste.impl({}, {})
		end,
		{
			desc = "paste currently open pdf page as link",
			silent = true,
		}
	)

	vim.keymap.set("n", "<Plug>(" .. commands.CMD_NAME .. "WordList)", function()
			commands.subcommands.wordlist.impl({}, {})
		end,
		{
			desc = "create a dictionary for autocompletion from link under the cursor",
			silent = true,
		}
	)
end

return M
