local Config = require("nes.config")
local Builder = {}

-- Resolve the plugin root directory.
local source = debug.getinfo(1, "S").source:sub(2)
local plugin_dir = vim.fn.fnamemodify(source, ":p:h:h:h")

-- Display a notification with the NES plugin title.
local function notify(msg, level)
	vim.notify(msg, level or vim.log.levels.INFO, { title = "NES" })
end

-- Remove empty lines from command output.
local function filter_empty_line(t)
	return vim.tbl_filter(function(line)
		return line ~= ""
	end, t)
end

-- Remove a build artifact if it exists.
local function safe_remove(path)
	if vim.fn.filereadable(path) == 1 then
		os.remove(path)
		return true
	end
	return false
end

-- Save all modified ca65 buffers before building.
local function save_buffers()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(buf)
			and vim.api.nvim_buf_is_loaded(buf)
		then
			local name = vim.api.nvim_buf_get_name(buf)
			local modified = vim.bo[buf].modified
			local ft = vim.bo[buf].filetype

			if modified and ft == "asm_ca65" and name ~= "" then
				local ok, err = pcall(function()
					vim.api.nvim_buf_call(buf, function()
						vim.cmd("write")
					end)
				end)

				if not ok then
					notify("Save failed: " .. err, vim.log.levels.ERROR)
					return false
				end
			end
		end
	end

	return true
end

-- Get the current source file and its base path.
local function get_project()
	local file = vim.api.nvim_buf_get_name(0)

	if file == "" then
		notify("Current buffer has no filename", vim.log.levels.ERROR)
		return nil
	end

	file = vim.fn.fnamemodify(file, ":p")

	return {
		file = file,
		base = vim.fn.fnamemodify(file, ":r"),
	}
end

-- Convert ca65 diagnostic messages into Quickfix items.
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

-- Update the Quickfix list with build diagnostics.
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

-- Run an external command asynchronously and collect its output.
local function run(cmd, opts)
	opts = opts or {}

	local stdout = {}
	local stderr = {}

	local job_id = vim.fn.jobstart(cmd, {
		stdout_buffered = false,
		stderr_buffered = false,

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

	if job_id <= 0 then
		notify("Failed to start: " .. table.concat(cmd, " "),
			vim.log.levels.ERROR)

		if opts.on_exit then
			opts.on_exit(job_id, stdout, stderr)
		end

		return nil
	end

	return job_id
end

-- Execute a Makefile target and report its output and exit status.
local function run_make_cmd(args, cb, debug)
	local cmd = { "make" }

	if debug then
		table.insert(cmd, "DEBUG=1")
	end

	vim.list_extend(cmd, args or {})

	run(cmd, {
		on_exit = function(code, stdout, stderr)
			vim.schedule(function()
				local output = vim.list_extend(stdout, stderr)
				output = filter_empty_line(output)

				if #output > 0 then
					notify(
						table.concat(output, "\n"),
						code == 0 and vim.log.levels.INFO
						or vim.log.levels.ERROR
					)
				end

				if code ~= 0 then
					notify(
						"Make failed (exit code " .. code .. ")",
						vim.log.levels.ERROR
					)
				end

				if cb then
					cb(code == 0)
				end
			end)
		end,
	})
end


-- Launch the configured emulator as a detached process.
local function run_emulator(path)
	local job = vim.fn.jobstart({
		Config.get().emulator,
		path,
	}, {
		detach = true,
		stdin = "null",
		stdout = "null",
		stderr = "null",
	})

	if job <= 0 then
		notify("Failed to start emulator", vim.log.levels.ERROR)
		return false
	end

	notify("Running emulator...")
	return true
end

-- Copy file helper
local function copy_file(source, destination)
	local src = io.open(source, "r")
	if not src then
		error("Could not open source file: " .. source)
	end

	-- Read the content of the source file
	local content = src:read("*all")
	src:close()

	-- Open the destination file in write mode
	local dest = io.open(destination, "w")
	if not dest then
		error("Could not open destination file: " .. destination)
	end

	-- Write the content to the destination file
	dest:write(content)
	dest:close()
end

-- Compile the current source file into an object file.
function Builder.compile(cb, project)
	local opts = Config.get()
	project = project or get_project()

	if not project then
		if cb then cb(false) end
		return
	end

	if vim.fn.executable(opts.compiler) == 0 then
		notify("Compiler not found: " .. opts.compiler, vim.log.levels.ERROR)
		if cb then cb(false) end
		return
	end

	run({
		opts.compiler,
		project.file,
		"-o",
		project.base .. ".o",
	}, {
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

-- Link the compiled object file into an NES ROM.
function Builder.link(cb, project)
	local opts = Config.get()
	project = project or get_project()

	if not project then
		if cb then cb(false) end
		return
	end

	if vim.fn.executable(opts.linker) == 0 then
		notify("Linker not found: " .. opts.linker, vim.log.levels.ERROR)
		if cb then cb(false) end
		return
	end

	local cmd = {
		opts.linker,
		"-t",
		opts.target,
		project.base .. ".o",
		"-o",
		project.base .. ".nes",
	}

	run(cmd, {
		on_exit = function(code, stdout, stderr)
			local items = parse_ca65(stderr)
			set_qf(items)

			if code == 0 then
				notify("Build done", vim.log.levels.INFO)
				if cb then cb(true) end
				return
			end

			local output = vim.list_extend(stdout, stderr)
			output = filter_empty_line(output)

			notify(
				"Link failed (exit code " .. code .. ")\n"
				.. table.concat(output, "\n"),
				vim.log.levels.ERROR
			)

			if cb then cb(false) end
		end,
	})
end

-- Save buffers and build the current project.
function Builder.build()
	local opts = Config.get()

	if opts.save_before_compile then
		if not save_buffers() then
			return
		end
	end

	if opts.use_make then
		Builder.make()
		return
	end

	local project = get_project()

	if not project then
		return
	end

	Builder.compile(function(ok)
		if not ok then
			return
		end

		Builder.link(nil, project)
	end, project)
end

-- Save buffers, build the project and launch the emulator.

-- Save buffers, build the project and launch the emulator.
function Builder.run(debug)
	debug = debug or false
	local opts = Config.get()

	if opts.save_before_compile then
		if not save_buffers() then
			return
		end
	end

	if opts.use_make then
		Builder.make_run(nil, debug)
		return
	end

	local project = get_project()

	if not project then
		return
	end

	Builder.compile(function(ok)
		if not ok then
			return
		end

		Builder.link(function(ok2)
			if not ok2 then
				return
			end

			run_emulator(project.base .. ".nes")
		end, project)
	end, project)
end

-- Remove generated object and ROM files.
function Builder.clean()
	local opts = Config.get()
	local project = get_project()

	if not project then
		return
	end

	safe_remove(project.base .. ".o")
	safe_remove(project.base .. ".nes")

	if opts.use_make then
		Builder.make_clean(function()
			notify("Clean complete")
		end)
	else
		notify("Clean complete")
	end
end

-- Build the project using the Makefile.
function Builder.make(cb, debug)
	run_make_cmd({}, cb, debug)
end

-- Build the project and launch the configured emulator.
function Builder.make_run(cb, debug)
	Builder.make(function(ok)
		if not ok then
			if cb then cb(false) end
			return
		end

		local opts = Config.get()

		-- Resolve the ROM path produced by the Makefile.
		local rom = vim.fn.fnamemodify(
			opts.build_dir .. "/" .. opts.target_name .. ".nes",
			":p"
		)

		if vim.fn.filereadable(rom) == 0 then
			notify("ROM not found: " .. rom, vim.log.levels.ERROR)
			if cb then cb(false) end
			return
		end

		local success = run_emulator(rom)

		if cb then cb(success) end
	end, debug)
end

-- Remove all generated files using the Makefile clean target.
function Builder.make_clean(cb)
	run_make_cmd({ "clean" }, cb)
end

-- Create a Makefile from the plugin template.
function Builder.create_makefile()
	local template = plugin_dir .. "/templates/Makefile.template"
	copy_file(template, "Makefile")
end

function Builder.simulate(cb)
	local buf = vim.api.nvim_get_current_buf()
	local buf_filename = vim.api.nvim_buf_get_name(buf)

	run_make_cmd({
		"SIM_SRC=" .. buf_filename,
		"simulate",
	}, cb)
end

return Builder
