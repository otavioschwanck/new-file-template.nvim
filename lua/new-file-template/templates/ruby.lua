local utils = require("new-file-template.utils")

local function generate_module_structure(yield, qtd_dirs_to_hide, path)
	local directories = {}
	for dir in path:gmatch("[^/]+") do
		table.insert(directories, dir)
	end

	if qtd_dirs_to_hide >= #directories then
		return "# frozen_string_literal: true\n\n" .. yield
	end

	for _ = 1, qtd_dirs_to_hide do
		table.remove(directories, 1)
	end

	local moduleStructure = ""
	local indentation = ""
	for _, dir in ipairs(directories) do
		moduleStructure = moduleStructure .. indentation .. "module " .. utils.snake_to_class_camel(dir) .. "\n"
		indentation = indentation .. "  "
	end

	local classLines = {}
	local classIndentation = indentation:sub(1, -3) .. "  "
	for line in yield:gmatch("[^\n]+") do
		table.insert(classLines, classIndentation .. line)
	end
	yield = table.concat(classLines, "\n")

	moduleStructure = moduleStructure .. yield .. "\n"

	for _ = #directories, 1, -1 do
		indentation = indentation:sub(1, -3)
		moduleStructure = moduleStructure .. indentation .. "end\n"
	end

	return "# frozen_string_literal: true\n\n" .. moduleStructure:sub(1, -2)
end

local function get_class_name(filename)
	return utils.snake_to_class_camel(vim.split(filename, "%.")[1])
end

local function inheritance_class(filename, class)
	return [[
class ]] .. get_class_name(filename) .. " < " .. class .. [[

  |cursor|
end]]
end

local function base_template(_, _)
	return [[
# frozen_string_literal: true

|cursor|]]
end

local function model_template(path, filename)
	local class_text = inheritance_class(filename, "ApplicationRecord")

	return generate_module_structure(class_text, 2, path)
end

local function business_template(path, filename)
	local class_text = inheritance_class(filename, "ApplicationBusiness")

	return generate_module_structure(class_text, 2, path)
end

local function controller_template(path, filename)
	local class_text = inheritance_class(filename, "ApplicationController")

	return generate_module_structure(class_text, 2, path)
end

local function mailer_template(path, filename)
	local class_text = inheritance_class(filename, "ApplicationMailer")

	return generate_module_structure(class_text, 2, path)
end

local function generic_app_class(path, filename)
	local text = [[
class ]] .. get_class_name(filename) .. [[|cursor|

end]]

	return generate_module_structure(text, 2, path)
end

local function lib_template(path, filename)
	local text = [[
class ]] .. get_class_name(filename) .. [[

  |cursor|
end]]

	return generate_module_structure(text, 1, path)
end

local function jobs_template(path, filename)
	local class_text = [[
class ]] .. get_class_name(filename) .. " < ApplicationJob" .. [[

  queue_as :default

  |cursor|
end]]

	return generate_module_structure(class_text, 2, path)
end

local function task_template(_, filename)
	local file = vim.split(filename, "%.")[1]

	return [[
# frozen_string_literal: true

namespace :]] .. file .. [[ do
  desc "My Task Description"
  task |cursor|: :environment do
  end
end
  ]]
end

local function factory_template(_, filename)
	local file = vim.split(filename, "%.")[1]

	return [[
# frozen_string_literal: true

FactoryBot.define do
  factory :]] .. file .. [[ do
    |cursor|
  end
end]]
end

local function spec_template(relative_path, filename)
	local splitted_path = utils.split(relative_path .. "/" .. filename, "/")
	local class_name = ""

	for i = 3, #splitted_path do
		class_name = class_name .. utils.snake_to_class_camel(utils.split(splitted_path[i], "_spec.rb")[1])

		if i < #splitted_path then
			class_name = class_name .. "::"
		end
	end

	local type = utils.singularize(splitted_path[2])

	return [[
# frozen_string_literal: true

require "rails_helper"

RSpec.describe ]] .. class_name .. [[, type: :]] .. type .. [[ do
  |cursor|
end]]
end

local function avo_action_template(path, filename)
	local class_text = [[
class ]] .. get_class_name(filename) .. " < Avo::BaseAction" .. [[

  self.name = "|cursor|"
end]]

	return generate_module_structure(class_text, 3, path)
end

local function avo_card_template(path, filename)
	local class_text = [[
class ]] .. get_class_name(filename) .. " < Avo::Dashboard::|cursor|" .. [[

  self.id = ""
end]]

	return generate_module_structure(class_text, 3, path)
end

local function avo_resource_tool_template(path, filename)
	local class_text = [[
class ]] .. get_class_name(filename) .. " < Avo::BaseResourceTool" .. [[

  self.name = "|cursor|"
end]]

	return generate_module_structure(class_text, 3, path)
end

--- @param opts table
---   A table containing the following fields:
---   - `full_path` (string): The full path of the new file, e.g., "lua/new-file-template/templates/init.lua".
---   - `relative_path` (string): The relative path of the new file, e.g., "lua/new-file-template/templates/init.lua".
---   - `filename` (string): The filename of the new file, e.g., "init.lua".
---   - `disable_specific` (table): An array of patterns that should be disabled, e.g., { "lua/templates/.*" }.
return function(opts)
	local template = {
		-- normal
		{ pattern = "app/models/.*", content = model_template },
		{ pattern = "app/business/.*", content = business_template },
		{ pattern = "app/controllers/.*", content = controller_template },
		{ pattern = "app/jobs/.*", content = jobs_template },
		{ pattern = "app/mailers/.*", content = mailer_template },

		-- avo
		{ pattern = "app/avo/actions/.*", content = avo_action_template },
		{ pattern = "app/avo/cards/.*", content = avo_card_template },
		{ pattern = "app/avo/resource_tools/.*", content = avo_resource_tool_template },

		{ pattern = "app/.*", content = generic_app_class },
		{ pattern = "lib/tasks/.*", content = task_template },
		{ pattern = "lib/.*", content = lib_template },

		-- spec
		{ pattern = "spec/factories/.*", content = factory_template },
		{ pattern = "spec/.*_spec", content = spec_template },

		-- base
		{ pattern = ".*", content = base_template },
	}

	return utils.find_entry(template, opts)
end
