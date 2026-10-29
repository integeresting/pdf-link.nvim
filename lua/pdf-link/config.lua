local M = {}

--- @class Config
--- @field link.description string
--- @field link.typst_force_absolute boolean
M.default_config = {
	link = {
		---default description to put in a link
		---markdown example: `[DESCRIPTION](LINK)`
		description = "Pdf",
		---Typst links (file://) do not support relative paths by default.
		---If there is a git root, links will can be relative. This needs to be
		---configured in the Typst document to work properly.
		typst_force_absolute = false,
	},

}

--- @class (partial) Config
M.options = vim.tbl_deep_extend("force", M.default_config, {})

--- @param opts Config?
M.setup = function(opts)
	M.options = vim.tbl_deep_extend("force", M.default_config, opts or {})
end

return M
