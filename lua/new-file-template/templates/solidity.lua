local utils = require("new-file-template.utils")

local function base_template(_, filename)
	local contract_name = vim.split(filename, "%.")[1]
	local solidity_version = vim.g.solc_version or "0.8.14"

	return [[
// SPDX-License-Identifier: UNLICENSED

pragma solidity ]] .. solidity_version .. [[;

contract ]] .. contract_name .. [[ {
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
		{ pattern = ".*", content = base_template },
	}

	return utils.find_entry(template, opts)
end
