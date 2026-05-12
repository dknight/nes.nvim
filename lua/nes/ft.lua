local FileType = {}

function FileType.setup(opts)
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "asm_ca65",
		callback = function(args)
			vim.bo[args.buf].commentstring = "; %s"
			vim.cmd("setlocal syntax=asm_ca65")
			vim.api.nvim_set_hl(0, "asm_ca65HexNumber", { link = "Number" })
			vim.api.nvim_set_hl(0, "nesPPURegister", { fg = "#ff6b6b" })
			vim.api.nvim_set_hl(0, "nesAPURegister", { fg = "#feca57" })
			vim.api.nvim_set_hl(0, "nesZeroPage", { fg = "#1dd1a1" })
			vim.api.nvim_set_hl(0, "nesROM", { fg = "#54a0ff" })

			local mergeDesc = function(desc)
				local t = {}
				for k, v in pairs({ buffer = args.buf, silent = true }) do
					t[k] = v
				end
				t.desc = desc
				return t
			end

			vim.keymap.set(
				"n",
				opts.build_key or "<leader>b",
				"<cmd>NesBuild<cr>",
				mergeDesc("NES Build")
			)
			vim.keymap.set(
				"n",
				opts.run_key or "<leader>r",
				"<cmd>NesRun<cr>",
				mergeDesc("NES Run")
			)
			vim.keymap.set(
				"n",
				"<leader>x",
				"<cmd>NesClean<cr>",
				mergeDesc("NES Clean output files")
			)
			vim.keymap.set(
				"n",
				"]q",
				"<cmd>cnext<cr>",
				{ desc = "Next error" }
			)
			vim.keymap.set(
				"n",
				"[q",
				"<cmd>cprev<cr>",
				{ desc = "Prev error" }
			)
		end,
	})
end

return FileType
