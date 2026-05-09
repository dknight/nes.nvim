local config = require("nes.config")

local Builder = {}

local function notify(msg, level)
	vim.notify(msg, level or vim.log.levels.INFO, { title = "NES" })
end

local function safe_remove(path)
	if vim.fn.filereadable(path) == 1 then
		os.remove(path)
		return true
	end
	return false
end

local function parse_ca65(lines)
	local items = {}

	for _, line in ipairs(lines or {}) do
		if line ~= "" then
			local file, lnum, type_, msg =
				line:match("([^:]+)%((%d+)%)%: (%w+)%: (.+)")

			if file and lnum and msg then
				table.insert(items, {
					filename = file,
					lnum = tonumber(lnum),
					col = 1,
					text = msg,
					type = (type_ == "Error") and "E" or "W",
				})
			end
		end
	end

	return items
end

local function set_qf(items)
	vim.fn.setqflist({}, " ", {
		title = "NES Build",
		items = items,
	})

	if #items > 0 then
		vim.cmd("copen")
	else
		vim.cmd("cclose")
	end
end

local function run(cmd, opts)
	opts = opts or {}

	local stdout = {}
	local stderr = {}

	return vim.fn.jobstart(cmd, {
		stdout_buffered = true,
		stderr_buffered = true,

		on_stdout = function(_, data)
			if data then
				vim.list_extend(stdout, data)
			end
		end,

		on_stderr = function(_, data)
			if data then
				vim.list_extend(stderr, data)
			end
		end,

		on_exit = function(_, code)
			if opts.on_exit then
				opts.on_exit(code, stdout, stderr)
			end
		end,
	})
end

function Builder.compile(cb)
	local opts = config.get()
	local file = vim.fn.expand("%")
	local base = vim.fn.expand("%:r")

	if opts.save_before_compile then
		for _, buf in ipairs(vim.api.nvim_list_bufs()) do
			if vim.api.nvim_buf_is_valid(buf)
				and vim.api.nvim_buf_get_option(buf, "modified")
			then
				local name = vim.api.nvim_buf_get_name(buf)

				if name:match("%.s$") then
					vim.api.nvim_buf_call(buf, function()
						vim.cmd("write")
					end)
				end
			end
		end
	end

	if vim.fn.executable(opts.compiler) == 0 then
		notify(
			"Compiler not found: " .. opts.compiler,
			vim.log.levels.ERROR
		)
		return
	end

	run({ opts.compiler, file, "-o", base .. ".o" }, {
		on_exit = function(code, stdout, stderr)
			local items = parse_ca65(stderr)

			set_qf(items)

			if code == 0 then
				if cb then cb(true) end
			else
				notify("Compile failed", vim.log.levels.ERROR)
				if cb then cb(false) end
			end
		end,
	})
end

function Builder.link(cb)
	local opts = config.get()
	local base = vim.fn.expand("%:r")

	if vim.fn.executable(opts.linker) == 0 then
		notify("Linker not found: " .. opts.linker, vim.log.levels.ERROR)
		return
	end

	run({
		opts.linker,
		"-t",
		opts.target,
		base .. ".o",
		"-o",
		base .. ".nes",
	}, {
		on_exit = function(code, stdout, stderr)
			local items = parse_ca65(stderr)

			set_qf(items)

			if code == 0 then
				notify("Build done", vim.log.levels.INFO)
				if cb then cb(true) end
			else
				notify("Link failed", vim.log.levels.ERROR)
				if cb then cb(false) end
			end
		end,
	})
end

function Builder.build()
	Builder.compile(function(ok)
		if not ok then
			return
		end
		Builder.link()
	end)
end

function Builder.run()
	local opts = config.get()
	local base = vim.fn.expand("%:r")

	Builder.compile(function(ok)
		if not ok then
			return
		end
		Builder.link(function(ok2)
			if not ok2 then
				return
			end

			notify("Running emulator...")
			run({ opts.emulator, base .. ".nes" })
		end)
	end)
end

function Builder.clean()
	local base = vim.fn.expand("%:r")

	local removed = {
		safe_remove(base .. ".o"),
		safe_remove(base .. ".nes"),
	}

	vim.notify("Clean complete", vim.log.levels.INFO, { title = "NES" })
end

return Builder
