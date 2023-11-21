local state = {
	disable_insert = false,
	disable_autocmd = {},
	disable_specific = {},
	disable_filetype = {},
}

local function setState(newState)
	state = newState
end

local function getState()
	return state
end

return {
	setState = setState,
	getState = getState,
}
