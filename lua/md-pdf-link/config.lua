local M = {}

--- @class Config
--- @field markdown_link.description string
M.default_config = {
	markdown_link = {
		---default description to put in a markdown link `[DESCRIPTION](LINK)`
		description = "Pdf"
	},
}

--- @class (partial) Config
M.options = vim.tbl_deep_extend("force", M.default_config, {})

--- @param opts Config?
M.setup = function(opts)
	M.options = vim.tbl_deep_extend("force", M.default_config, opts or {})
end

return M
