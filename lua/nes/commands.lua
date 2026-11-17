local builder = require("nes.builder")

local Commands = {}

function Commands.setup()
	vim.api.nvim_create_user_command("NesBuild", function()
		builder.build()
	end, {})

	vim.api.nvim_create_user_command("NesRun", function()
		builder.run()
	end, {})

	vim.api.nvim_create_user_command("NesRunDebug", function()
		builder.run(true)
	end, {})

	vim.api.nvim_create_user_command("NesClean", function()
		builder.clean()
	end, {})

	vim.api.nvim_create_user_command("NesCreateMakefile", function()
		builder.create_makefile()
	end, {})

	vim.api.nvim_create_user_command("Nes6502Simulate", function()
		builder.simulate()
	end, {})
end

return Commands
