local build = require("nes.build")

local Commands = {}

function Commands.setup()
	vim.api.nvim_create_user_command("NesBuild", function()
		build.build()
	end, {})

	vim.api.nvim_create_user_command("NesRun", function()
		build.run()
	end, {})

	vim.api.nvim_create_user_command("NesClean", function()
		build.clean()
	end, {})
end

return Commands
