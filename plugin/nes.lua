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

require("nes").setup()
