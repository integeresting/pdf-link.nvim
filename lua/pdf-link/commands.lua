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

local M = {}

M.CMD_NAME = "PdfLink"

--- @type command
M.subcommands = {
	open = {
		impl = function()
			require("pdf-link.actions").open_pdf_link()
		end
	},
	paste = {
		impl = function()
			require("pdf-link.actions").put_pdf_link()
		end
	},
	wordlist = {
		impl = function()
			require("pdf-link.actions").make_word_list()
		end
	},
}

--------------
-- COMMANDS --
--------------

---@param opts table :h lua-guide-commands-create
local function to_cmd(opts)
	local fargs = opts.fargs
	local subcommand_key = fargs[1]

	local args = #fargs > 1 and vim.list_slice(fargs, 2, #fargs) or {}
	local subcommand = M.subcommands[subcommand_key]
	if not subcommand then
		vim.notify(M.CMD_NAME .. ": Unknown command: " .. subcommand_key, vim.log.levels.ERROR)
		return
	end

	subcommand.impl(args, opts)
end

M.create_user_command = function()
	vim.api.nvim_create_user_command(
		M.CMD_NAME,
		function(opts) to_cmd(opts) end,
		{
			nargs = "+",
			desc = "open pdf link, paste or create a wordlist of the PDF currently open",
			complete = function(arg_lead, cmdline, _)
				-- Get the subcommand.
				local subcmd_key, subcmd_arg_lead =
						cmdline:match("^['<,'>]*" .. M.CMD_NAME .. "[!]*%s(%S+)%s(.*)$")
				if subcmd_key
						and subcmd_arg_lead
						and M.subcommands[subcmd_key]
						and M.subcommands[subcmd_key].complete
				then
					-- The subcommand has completions. Return them.
					return M.subcommands[subcmd_key].complete(subcmd_arg_lead)
				end
				-- Check if cmdline is a subcommand
				if cmdline:match("^['<,'>]*" .. M.CMD_NAME .. "[!]*%s+%w*$") then
					-- Filter subcommands that match
					local subcommand_keys = vim.tbl_keys(M.subcommands)
					return vim.iter(subcommand_keys)
							:filter(function(key)
								return key:find(arg_lead) ~= nil
							end)
							:totable()
				end
			end,
			bang = false,
		}
	)
end

return M
