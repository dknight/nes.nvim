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

vim.api.nvim_create_user_command("NesBuild", function()
	require("nes").setup()
	require("nes.build").build()
end, {})

vim.api.nvim_create_user_command("NesRun", function()
	require("nes").setup()
	require("nes.build").run()
end, {})

vim.api.nvim_create_user_command("NesClean", function()
	require("nes").setup()
	require("nes.build").clean()
end, {})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "asm_ca65",
	callback = function()
		require("nes").setup()
	end,
})
