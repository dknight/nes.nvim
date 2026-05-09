local Config = {}

local options = nil

function Config.setup(opts)
	if options then return end

	options = vim.tbl_deep_extend("force", {
		save_before_compile = true,
		compiler = "ca65",
		linker = "cl65",
		emulator = "fceux",
		target = "nes",
	}, opts or {})
end

function Config.get()
	if not options then
		Config.setup()
	end
	return options
end

return Config
