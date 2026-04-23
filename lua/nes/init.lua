local NESPlugin = {}

local initialized = false

local function load_from_lazy()
	local ok, lazy_config = pcall(require, "lazy.core.config")
	if not ok then return {} end

	local plugins = lazy_config.plugins

	if plugins["nes.nvim"] then
		return plugins["nes.nvim"].opts or {}
	end

	for _, plugin in pairs(plugins) do
		if plugin.dir and plugin.dir:find("nes.nvim", 1, true) then
			return plugin.opts or {}
		end
	end

	return {}
end

function NESPlugin.setup(opts)
	if initialized then
		return
	end
	initialized = true

	if not opts then
		opts = load_from_lazy()
	end

	require("nes.config").setup(opts)
	pcall(function() require("nes.ft").setup(opts) end)
	pcall(function() require("nes.commands").setup() end)
end

return NESPlugin
