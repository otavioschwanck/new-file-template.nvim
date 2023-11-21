local M = {}

function M.included_in_array(item, array)
	for _, v in ipairs(array) do
		if v == item then
			return true
		end
	end

	return false
end

function M.normalize_path(text)
	local s = text

	-- Only target literal parts of the path (i.e exclude lua patterns)
	-- This assumes that in the literal part of the path the `-` will be preceeded
	-- by only alphanumeric characters. It also assumes that lua patters will only
	-- ever have an alpha-numeric char preceeding the `-` special character.
	--
	s = string.gsub(s, "([%w])%-", "%1%%-")

	return s
end

-- M.find_entry_with_disabled = function(template, full_path, relative_path, filename, disable_specific)
M.find_entry = function(template, opts)
	local disabled = opts.disable_specific or {}

	for _, entry in ipairs(template) do
		if not (M.included_in_array(entry.pattern, disabled)) and M.compare_regexp(opts.full_path, entry.pattern) then
			return entry.content(opts.relative_path, opts.filename)
		end
	end

	return false
end

M.compare_regexp = function(path, pattern)
	return string.match(path, M.normalize_path(pattern))
end

-- function get on rgroli/other.nvim
M.camel_to_kebap = function(inputString)
	local pathParts = {}

	inputString:gsub("%w+[^/]", function(str)
		table.insert(pathParts, str)
	end)

	for i, part in pairs(pathParts) do
		local camelParts = {}
		part:gsub("%u%l+", function(str)
			table.insert(camelParts, str:lower())
		end)
		pathParts[i] = table.concat(camelParts, "-")
	end

	return table.concat(pathParts, "/")
end

-- function get on rgroli/other.nvim
M.kebap_to_camel = function(inputString)
	local pathParts = {}

	inputString:gsub("[%w-_]+[^/]", function(str)
		table.insert(pathParts, str)
	end)

	for i, part in pairs(pathParts) do
		local tmp = ""
		for key in part:gmatch("[^-]+") do
			tmp = tmp .. key:sub(1, 1):upper() .. key:sub(2)
		end
		pathParts[i] = tmp
	end

	return table.concat(pathParts, "/")
end

M.pluralize = function(inputString)
	local lastCharacter = inputString:sub(-1, -1)

	if lastCharacter == "y" then
		local stringWithoutY = inputString:sub(1, -2)

		return stringWithoutY .. "ies"
	elseif lastCharacter == "s" then
		return inputString
	else
		return inputString .. "s"
	end
end

M.singularize = function(inputString)
	local lastCharacter = inputString:sub(-1, -1)

	local lastThreeCharacters = ""

	if #inputString >= 3 then
		lastThreeCharacters = inputString:sub(-3, -1)
	end

	if lastThreeCharacters == "ies" then
		local stringWithoutIes = inputString:sub(1, -4)

		return stringWithoutIes .. "y"
	elseif lastCharacter == "s" then
		return inputString:sub(1, -2)
	else
		return inputString
	end
end

return M
