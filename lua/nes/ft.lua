local Config = require("nes.config")
local FileType = {}

local function map_opts(buf, desc)
	return {
		buffer = buf,
		silent = true,
		desc = desc,
	}
end

function FileType.setup()
	local opts = Config.get()

	vim.api.nvim_create_autocmd("FileType", {
		pattern = "asm_ca65",
		callback = function(args)
			vim.bo[args.buf].commentstring = "; %s"
			vim.cmd("setlocal syntax=asm_ca65")

			vim.keymap.set("n", opts.build_key, "<cmd>NesBuild<cr>",
				map_opts(args.buf, "NES Build"))

			vim.keymap.set("n", opts.run_key, "<cmd>NesRun<cr>",
				map_opts(args.buf, "NES Run"))

			vim.keymap.set("n", opts.run_debug_key, "<cmd>NesRunDebug<cr>",
				map_opts(args.buf, "NES Run with debug"))

			vim.keymap.set("n", opts.clean_key, "<cmd>NesClean<cr>",
				map_opts(args.buf, "NES Clean"))

			vim.keymap.set("n", opts.create_makefile_key, "<cmd>NesCreateMakefile<cr>",
				map_opts(args.buf, "Create Makefile"))

			vim.keymap.set("n", opts.simulate_key, "<cmd>Nes6502Simulate<cr>",
				map_opts(args.buf, "6502 Simulator"))

			vim.keymap.set("n", "]q", "<cmd>cnext<cr>",
				map_opts(args.buf, "Next error"))

			vim.keymap.set("n", "[q", "<cmd>cprev<cr>",
				map_opts(args.buf, "Prev error"))
		end,
	})
end

return FileType
