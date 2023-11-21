# Introduction

A simple, but, powerful plugin that allows you to easily create multiple templates for new files using lua for your projects (using regexp to decide which template should be used).  It also come with some pre-configured templates that you can use.

![image 1](https://i.imgur.com/9v36F5n.gif)

# Setup

## Lazy

```lua
{ "otavioschwanck/new-file-template.nvim", opts = {} }
```

## Packer

```lua
use {
  'otavioschwanck/new-file-template.nvim', 
  config = function() 
    require('new-file-template').setup() 
  end
}

```

# Setup Options

```lua
{ 
 disable_insert = false, -- Enter in insert mode after inserting the template?,
 disable_autocmd = false, -- Disable the autocmd that creates the template.  You can use manually by calling :InsertTemplateFile,
 disable_filetype = {}, -- Disable templates for a filetype (disable only default templates.  User templates will work).
 disable_specific = {}, -- Disable specific regexp for the default templates.  Example: { ruby = { ".*" } }.  To see the regexps, just look into lua/templates/{filetype}.lua for the regexp being used.
}
```
# Creating new templates

## Intro

- The templates are separated by filetype.
- The user templates are in lua/templates/{filetype}.lua inside your neovim configuration.
- To create a new template, just run `:NewFileTemplate filetype` (if you don't pass any args, it will create a template for the current file filetype)

An example of a basic template for solidity:

```lua
local utils = require("new-file-template.utils")

local function base_template(path, filename)
	local contract_name = vim.split(filename, "%.")[1]
	local solidity_version = vim.g.solc_version or "0.8.14"

	return [[
// SPDX-License-Identifier: UNLICENSED

pragma solidity ]] .. solidity_version .. [[;

contract ]] .. contract_name .. [[ {
  |cursor|
}]]
end

local function helper_template(path, filename) -- just an example
  return "Created a file in " .. path .. " called " .. filename
end

return function(opts)
	local template = {
		{ pattern = "helper/.*", content = helper_template },
		{ pattern = ".*", content = base_template },
	}

	return utils.find_entry(template, opts)
end
```

## How it works?

The template file always should return a function that:
  - Return the template string if it found it
  - Return false is don't find nothing

The `utils.find_entry` function receives an table with:
  - pattern: the pattern that triggers the template
  - content: a function that return the template string

The content function will always receive the path to the file and the filename as parameters. It should ALWAYS return a string.

If the content return `|cursor|` inside the string, it will position the cursor there.

## What we can do with it?

The content function can do anything.  Can ask the user for some input, can call an API to get the content.  The sky is the limit.

## Quickly creating a new template

Here is an example of me creating a JavaScript template.

![image 2](https://i.imgur.com/H1pUkXw.gif)

## Utils to help you creating your own templates

The `utils` module contains some useful functions to help you creating your own templates.

snake_to_camel
  - Convert snake_case to camelCase

camel_to_snake
  - Convert camelCase to snake_case

snake_to_class_camel
  - Convert snake_case to ClassCamelCase

class_camel_to_snake
  - Convert ClassCamelCase to snake_case

camel_to_kebab
  - Convert camelCase to kebab-case

kebab_to_camel
  - Convert kebab-case to camelCase

pluralize
  - Pluralize a word

singularize
  - Singularize a word

split(string, delimiter)
  - Split a string into an array


## Contributing

This plugin is in its early stages, and we welcome your help! If you use some framework that is not in the defaults, please open a PR to contribute to the project. Any help is welcome.

If you use some framework that is not on the defaults, please, open an PR to help the project! Any help is welcome.
