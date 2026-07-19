local M = {}

M.setup = function(opts)
	local config = require("md-pdf-link.config")
	config.setup(opts)
end

return M
