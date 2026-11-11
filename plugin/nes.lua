if vim.g.loaded_nes then
	return
end
vim.g.loaded_nes = true

vim.filetype.add({
	extension = {
		s = "asm_ca65",
		S = "asm_ca65",
		inc = "asm_ca65",
		INC = "asm_ca65",
	},
})

local setup = require("nes").setup
local builder = require("nes.builder")

vim.api.nvim_create_user_command("NesBuild", function()
	setup()
	builder.build()
end, {})

vim.api.nvim_create_user_command("NesRun", function()
	setup()
	builder.run()
end, {})

vim.api.nvim_create_user_command("NesClean", function()
	setup()
	builder.clean()
end, {})

vim.api.nvim_create_user_command("NesCreateMakegile", function()
	setup()
	builder.create_makefile()
end, {})

vim.api.nvim_create_user_command("Nes6502Simulate", function()
	setup()
	builder.simulate()
end, {})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "asm_ca65",
	callback = function()
		setup()
	end,
})
