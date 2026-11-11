local build = require("nes.builder")

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

	vim.api.nvim_create_user_command("NesCreateMakefile", function()
		build.create_makefile()
	end, {})

	vim.api.nvim_create_user_command("Nes6502Simulate", function()
		build.simulate()
	end, {})
end

return Commands
