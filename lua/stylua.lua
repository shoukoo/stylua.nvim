local api = vim.api
local fn = vim.fn

-- Helpers
local win_default_opts = function(percentage)
	local width = math.floor(vim.o.columns * percentage)
	local height = math.floor(vim.o.lines * percentage)
	local top = math.floor(((vim.o.lines - height) / 2) - 1)
	local left = math.floor((vim.o.columns - width) / 2)

	local opts = {
		relative = "editor",
		row = top,
		col = left,
		width = width,
		height = height,
		style = "minimal",
	}

	opts.border = {
		{ " ", "NormalFloat" },
		{ " ", "NormalFloat" },
		{ " ", "NormalFloat" },
		{ " ", "NormalFloat" },
		{ " ", "NormalFloat" },
		{ " ", "NormalFloat" },
		{ " ", "NormalFloat" },
		{ " ", "NormalFloat" },
	}

	return opts
end

local function remove_newline(str)
	str = vim.split(str, "\n")
	str = table.concat(str, " ")
	return str
end

local function log_file_path()
	local path_sep = vim.loop.os_uname().version:match("Windows") and "\\" or "/"
	return table.concat(vim.tbl_flatten({ vim.fn.stdpath("cache"), "stylus.log" }), path_sep)
end

local function buf_get_full_text(bufnr)
	local text = table.concat(api.nvim_buf_get_lines(bufnr, 0, -1, true), "\n")
	if api.nvim_buf_get_option(bufnr, "eol") then
		text = text .. "\n"
	end
	return text
end

-- Stylua
local stylua = {}

stylua.format_file = function()
	local flags
	-- Only search in current . director, and not other sub folders
	local stylua_conf = fn.findfile(".stylua.tomls", ".;")
	local error_file = log_file_path()

	if fn.empty(stylua_conf) == 0 then
		flags = "--config-path " .. stylua_conf
	else
		flags = ""
	end

	local stylua_command = string.format("stylua %s - 2> %s", flags, error_file)

	local input = buf_get_full_text(0)
	local output = fn.system(stylua_command, input)

	if fn.empty(output) == 0 then
		if input ~= output then
			local new_lines = vim.fn.split(output, "\n")
			api.nvim_buf_set_lines(0, 0, -1, false, new_lines)
		end

		-- Clean up the old list
		vim.fn.setloclist(0, {})
		vim.cmd("lclose")
	else
		local errors = table.concat(vim.fn.readfile(error_file), " ")

		-- A little hacky, but we know that the error messsages are always shaped
		-- in a similiar way containing:
		--(starting from line 32, character 2 and ending on line 32, character 5)
		-- So we know that:
		--	- locations[1] = start line
		--	- locations[2] = start col
		--	- locations[3] = end line
		--	- locations[4] = end col
		local locations = {}
		for num in errors:gmatch("%d+") do
			table.insert(locations, num)
		end

		-- Ensure that we have the full range
		if #locations == 4 then
			fn.setloclist(0, { { bufnr = 0, lnum = locations[1], col = locations[2], text = errors } })
			vim.cmd("lopen")
		end
	end

  fn.delete(error_file)
end

stylua.setup= function()
	vim.cmd([[command! StyluaFormat lua require('stylua').format_file()]])
	vim.cmd([[command! StyluaInfo lua require('stylua').info()]])
end

stylua.info = function()
	local win_opts = win_default_opts(0.3)
	local bufnr = vim.api.nvim_create_buf(false, true)
	local win_id = vim.api.nvim_open_win(bufnr, true, win_opts)

	-- Generate Information
	-- check if Stylua exists and runnable
	local cmd = "stylua"
	local is_cmd = vim.fn.executable(cmd)
	local cmd_path, version

	if is_cmd == 1 then
		cmd_path = vim.fn.exepath(cmd)
		version = remove_newline(vim.fn.system(cmd .. " --version"))
	else
		cmd_path = "stylua command not found"
		version = "null"
	end

	local buf_lines = {}
	local content = {

		"cmd: " .. cmd,
		"version: " .. version,
		"cmd_path: " .. cmd_path,
	}
	vim.list_extend(buf_lines, content)

	vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, buf_lines)
	vim.api.nvim_win_set_buf(win_id, bufnr)
	vim.cmd("setlocal nocursorcolumn")
	vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
	-- esc key exectes background delete (bd) command
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<esc>", "<cmd>bd<CR>", { noremap = true })
end

return stylua
