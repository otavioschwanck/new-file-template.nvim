local utils = require("new-file-template.utils")

-- for this plugin new files
local function new_file_template(_, _)
	return [=[
local utils = require("new-file-template.utils")

local function base_template(relative_path, filename)
  return [[
|cursor|
  ]]
end

--- @param opts table
---   A table containing the following fields:
---   - `full_path` (string): The full path of the new file, e.g., "lua/new-file-template/templates/init.lua".
---   - `relative_path` (string): The relative path of the new file, e.g., "lua/new-file-template/templates/init.lua".
---   - `filename` (string): The filename of the new file, e.g., "init.lua".
---   - `disable_specific` (table): An array of patterns that should be disabled, e.g., { "lua/templates/.*" }.
return function(opts)
  local template = {
    { pattern = ".*", content = base_template },
  }

  return utils.find_entry_with_disabled(
    template,
    opts.full_path,
    opts.relative_path,
    opts.filename,
    opts.disable_specific
  )
end]=]
end

-- For the users
local function new_file_template_for_user(_, _)
	return [=[
local utils = require("new-file-template.utils")

local function base_template(relative_path, filename)
  return [[
|cursor|
  ]]
end

--- @param opts table
---   A table containing the following fields:
---   - `full_path` (string): The full path of the new file, e.g., "lua/new-file-template/templates/init.lua".
---   - `relative_path` (string): The relative path of the new file, e.g., "lua/new-file-template/templates/init.lua".
---   - `filename` (string): The filename of the new file, e.g., "init.lua".
return function(opts)
  local template = {
    { pattern = ".*", content = base_template },
  }

	return utils.find_entry(template, opts)
end]=]
end

local function base_template(_, _)
	return [[
local M = {}

function M.|cursor|()

end

return M]]
end

-- For Lazy Users
local function new_plugin(_, _)
	return [[
return {
  |cursor|
}]]
end

--- @param opts table
---   A table containing the following fields:
---   - `full_path` (string): The full path of the new file, e.g., "lua/new-file-template/templates/init.lua".
---   - `relative_path` (string): The relative path of the new file, e.g., "lua/new-file-template/templates/init.lua".
---   - `filename` (string): The filename of the new file, e.g., "init.lua".
---   - `disable_specific` (table): An array of patterns that should be disabled, e.g., { "lua/templates/.*" }.
return function(opts)
	local template = {
		{ pattern = "lua/new-file-template/templates/.*", content = new_file_template },
		{ pattern = "lua/templates/.*", content = new_file_template_for_user },
		{ pattern = "lua/plugins/.*", content = new_plugin },
		{ pattern = ".*", content = base_template },
	}

	return utils.find_entry(template, opts)
end
