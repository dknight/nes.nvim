local Config = {}

local options = nil

function Config.setup(opts)
	if options then return end

	options = vim.tbl_deep_extend("force", {
		save_before_compile = true,
		use_make = true,
		compiler = "ca65",
		linker = "cl65",
		emulator = "fceux",
		target = "nes",
		build_dir = "builds",
		target_name = "main",

		build_key = "<leader>b",
		run_key = "<leader>r",
		run_debug_key = "<leader>d",
		clean_key = "<leader>x",
		create_makefile_key = "<leader>m",
		simulate_key = "<leader>i",
	}, opts or {})
end

function Config.get()
	if not options then
		Config.setup()
	end
	return options
end

return Config
