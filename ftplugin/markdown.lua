---`open` - open markdown link to pdf
---`paste`- paste currently open pdf page as markdown link
---`wordlist` - create a dictionary for autocompletion from markdown link under
---the cursor
---@class command
---@field open command.open
---@field paste command.paste
---@field wordlist command.wordlist
---
---
---open markdown link to pdf
---@class command.open
---@field impl fun(args:string[], opts: table)
---
---paste currently open pdf page as markdown link
---@class command.paste
---@field impl fun(args:string[], opts: table)
---
---create a dictionary for autocompletion from currently open pdf
---@class command.wordlist
---@field impl fun(args:string[], opts: table)


if vim.g.loaded_md_pdf_link == true then
	return
end

vim.g.loaded_md_pdf_link = true
local CMD_NAME = "MdPdfLink"

--- @type command
local subcommands = {
	open = {
		impl = function()
			require("md-pdf-link.actions").open_pdf_link()
		end
	},
	paste = {
		impl = function()
			require("md-pdf-link.actions").put_pdf_link()
		end
	},
	wordlist = {
		impl = function()
			require("md-pdf-link.actions").make_word_list()
		end
	},
}

-------------
-- KEYMAPS --
-------------

vim.keymap.set("n", "<Plug>(" .. CMD_NAME .. "Open)", function()
		subcommands.open.impl({}, {})
	end,
	{
		desc = "open markdown link to pdf",
		silent = true,
	}
)

vim.keymap.set("n", "<Plug>(" .. CMD_NAME .. "Paste)", function()
		subcommands.paste.impl({}, {})
	end,
	{
		desc = "paste currently open pdf page as markdown link",
		silent = true,
	}
)

vim.keymap.set("n", "<Plug>(" .. CMD_NAME .. "WordList)", function()
		subcommands.wordlist.impl({}, {})
	end,
	{
		desc = "create a dictionary for autocompletion from markdown link under the cursor",
		silent = true,
	}
)

--------------
-- COMMANDS --
--------------

---@param opts table :h lua-guide-commands-create
local function my_cmd(opts)
	local fargs = opts.fargs
	local subcommand_key = fargs[1]

	local args = #fargs > 1 and vim.list_slice(fargs, 2, #fargs) or {}
	local subcommand = subcommands[subcommand_key]
	if not subcommand then
		vim.notify(CMD_NAME .. ": Unknown command: " .. subcommand_key, vim.log.levels.ERROR)
		return
	end

	subcommand.impl(args, opts)
end

vim.api.nvim_create_user_command(CMD_NAME, my_cmd, {
	nargs = "+",
	desc = "open pdf link, paste or create a wordlist of the PDF currently open",
	complete = function(arg_lead, cmdline, _)
		-- Get the subcommand.
		local subcmd_key, subcmd_arg_lead = cmdline:match("^['<,'>]*" .. CMD_NAME .. "[!]*%s(%S+)%s(.*)$")
		if subcmd_key
				and subcmd_arg_lead
				and subcommands[subcmd_key]
				and subcommands[subcmd_key].complete
		then
			-- The subcommand has completions. Return them.
			return subcommands[subcmd_key].complete(subcmd_arg_lead)
		end
		-- Check if cmdline is a subcommand
		if cmdline:match("^['<,'>]*" .. CMD_NAME .. "[!]*%s+%w*$") then
			-- Filter subcommands that match
			local subcommand_keys = vim.tbl_keys(subcommands)
			return vim.iter(subcommand_keys)
					:filter(function(key)
						return key:find(arg_lead) ~= nil
					end)
					:totable()
		end
	end,
	bang = false,
})
