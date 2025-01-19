local M = {}

local state = require("new-file-template.state")
local utils = require("new-file-template.utils")

function M.setup(opts)
	local opts = opts or {}

	state.setState({
		disable_insert = opts.disable_insert or false,
		disable_autocmd = opts.disable_autocmd or {},
		disable_specific = opts.disable_specific or {},
		disable_filetype = opts.disable_filetype or {},
        suffix_as_filetype = opts.suffix_as_filetype or false,
	})

	if not opts.disable_autocmd then
		vim.cmd([[
      augroup NewFileTemplate
        autocmd!
        autocmd BufEnter * :lua require'new-file-template'.on_buf_enter()
      augroup END
    ]])
	end

	vim.cmd([[
    command! -nargs=? -complete=filetype NewFileTemplate lua require'new-file-template'.open_user_config(<f-args>)
  ]])

	vim.cmd([[
    command! InsertTemplateFile lua require'new-file-template'.insert_template()
  ]])
end

function M.on_buf_enter()
	if vim.b.template_verified == 1 then
		return
	end

	vim.b.template_verified = 1

	local bufnr = vim.fn.bufnr("%")

	if vim.fn.buflisted(bufnr) == 0 or vim.fn.bufname(bufnr) == "" then
		return
	end

	local lines = vim.fn["getline"](1, "$")
	if not (lines[1] == "" and #lines == 1) then
		return
	end

	M.insert_template()
end

function M.open_user_config(filetype)
	if not filetype or filetype == "" then
		filetype = vim.bo.filetype

        if state.getState().suffix_as_filetype then
            local ft = vim.api.nvim_buf_get_name(0):match("^.+%.(.+)$")
            if ft ~= nil then
                filetype = ft
            end
        end
	end

	local config_path = vim.fn.stdpath("config")
	local templates_path = string.format("%s/lua/templates", config_path)
	local template_path = string.format("%s/%s.lua", templates_path, filetype)

	if vim.fn.isdirectory(templates_path) == 0 then
		vim.fn.mkdir(templates_path, "p")
	end

	vim.cmd("edit " .. template_path)
end

function M.insert_text(template)
	local current_buffer = vim.api.nvim_get_current_buf()
	template = template:gsub("\\\\n", "ESCAPED_NEWLINE_CHAR") -- Replace escaped newline chars with a place holder
	template = template:gsub("\\n", "\n") -- Replace real newline chars with the actual escape code
	template = template:gsub("ESCAPED_NEWLINE_CHAR", "\\n") -- Replace place holders with not-escaped newline chars

	local lines = vim.split(template, "\n")

	local cursor_line, cursor_col
	for i, line in ipairs(lines) do
		local start, _ = line:find("|cursor|")
		if start then
			cursor_line = i - 1
			cursor_col = start - 1
			lines[i] = line:gsub("|cursor|", "")
			break
		end
	end

	local current_cursor = vim.api.nvim_win_get_cursor(0)

	vim.api.nvim_buf_set_lines(current_buffer, 0, -1, false, lines)

	if cursor_line and cursor_col then
		vim.api.nvim_win_set_cursor(0, { cursor_line + 1, cursor_col })
	else
		vim.api.nvim_win_set_cursor(0, current_cursor)
	end

	local local_state = state.getState()

	if not local_state.disable_insert and cursor_line and cursor_col then
		if cursor_col == vim.fn.strlen(lines[cursor_line + 1]) then
			vim.api.nvim_feedkeys("a", "n", true)
		else
			vim.api.nvim_feedkeys("i", "n", true)
		end
	end
end

function M.insert_template()
	local new_file_relative_path = vim.fn.fnamemodify(vim.fn.expand("%"), ":~:.")
	local filename = vim.fn.fnamemodify(new_file_relative_path, ":t")
	local path = vim.fn.fnamemodify(new_file_relative_path, ":h")
	local new_file_filetype = vim.bo.filetype

    if state.getState().suffix_as_filetype then
        local ft = filename:match("^.+%.(.+)$")
        if ft ~= nil then
            new_file_filetype = ft
        end
    end

	local opts_for_template = {
		full_path = new_file_relative_path,
		relative_path = path,
		filename = filename,
		disable_specific = state.getState().disable_specific[new_file_filetype] or {},
	}

	local user_template_loaded, template_for_filetype_user = pcall(require, "templates." .. new_file_filetype)

	if user_template_loaded then
		local template = template_for_filetype_user(opts_for_template)

		if template then
			M.insert_text(template)

			return
		end
	end

	if utils.included_in_array(new_file_filetype, state.getState().disable_filetype) then
		return
	end

	local loaded, template_for_filetype = pcall(require, "new-file-template.templates." .. new_file_filetype)

	if loaded then
		local template = template_for_filetype(opts_for_template)

		if template then
			M.insert_text(template)
		end
	end
end

return M

