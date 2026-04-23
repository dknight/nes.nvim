local Health = {}

function Health.check()
	local health = vim.health or require("health")

	health.start("nes.nvim")

	local config = require("nes.config").get()

	----------------------------------------------------------------------
	-- Compiler
	----------------------------------------------------------------------
	if vim.fn.executable(config.compiler) == 1 then
		health.ok("Compiler found: " .. config.compiler)
	else
		health.error("Compiler not found: " .. config.compiler)
	end

	----------------------------------------------------------------------
	-- Linker
	----------------------------------------------------------------------
	if vim.fn.executable(config.linker) == 1 then
		health.ok("Linker found: " .. config.linker)
	else
		health.error("Linker not found: " .. config.linker)
	end

	----------------------------------------------------------------------
	-- Emulator
	----------------------------------------------------------------------
	if vim.fn.executable(config.emulator) == 1 then
		health.ok("Emulator found: " .. config.emulator)
	else
		health.warn("Emulator not found: " .. config.emulator)
	end

	----------------------------------------------------------------------
	-- Filetype detection
	----------------------------------------------------------------------
	if vim.filetype.match({ filename = "test.s" }) == "asm_ca65" then
		health.ok("Filetype detection works (.s → asm_ca65)")
	else
		health.warn("Filetype detection not active for .s files")
	end

	----------------------------------------------------------------------
	-- Syntax
	----------------------------------------------------------------------
	local syntax_path = "./syntax/asm_ca65.vim"
	if vim.fn.filereadable(syntax_path) == 1 then
		health.ok("Custom syntax found: asm_ca65")
	else
		health.warn("Custom syntax not found (syntax/asm_ca65.vim)")
	end

	----------------------------------------------------------------------
	-- Treesitter (optional)
	----------------------------------------------------------------------
	local ok_ts, _ = pcall(require, "vim.treesitter")
	if ok_ts then
		health.ok("Treesitter available")
	else
		health.info("Treesitter not installed (optional)")
	end
end

return Health
