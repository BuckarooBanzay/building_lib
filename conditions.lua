
-- checks a single condition
local function check_condition(key, value, mapblock_pos, building_def)
	local condition = building_lib.get_condition(key)
	if condition and type(condition.can_build) == "function" then
		return condition.can_build(mapblock_pos, building_def, value)
	end
	return true
end

-- checks a table of conditions with the given mapblock_pos
-- all entries have to match
local function check_table(map, mapblock_pos, building_def)
	for key, value in pairs(map) do
		local success, msg = check_condition(key, value, mapblock_pos, building_def)
		if not success then
			-- failure and in AND mode, return immediately
			return false, msg or "condition failed: '" .. key .. "'"
		end
	end
	return true
end

local default_conditions = {
	{["*"] = { empty = true }}
}

function building_lib.check_conditions(mapblock_pos1, mapblock_pos2, building_def)
	for _, condition_group in ipairs(building_def.conditions or default_conditions) do
		local group_match = true

		for selector, conditions in pairs(condition_group) do
			local it
			if selector == "*" then
				-- match all
				it = mapblock_lib.pos_iterator(mapblock_pos1, mapblock_pos2)
			elseif selector == "base" then
				-- match only base positions
				it = mapblock_lib.pos_iterator(mapblock_pos1, {x=mapblock_pos2.x, y=mapblock_pos1.y, z=mapblock_pos2.z})
			elseif selector == "underground" then
				-- match only underground positions
				it = mapblock_lib.pos_iterator({
					x=mapblock_pos1.x, y=mapblock_pos1.y-1, z=mapblock_pos1.z
				},{
					x=mapblock_pos2.x, y=mapblock_pos1.y-1, z=mapblock_pos2.z
				})
			else
				-- try to parse a manual position
				local pos = minetest.string_to_pos(selector)
				if pos then
					-- single position
					it = mapblock_lib.pos_iterator(pos, pos)
				else
					return false, "unknown selector: " .. selector
				end
			end

			while true do
				local mapblock_pos = it()
				if not mapblock_pos then
					break
				end

				local success = check_table(conditions, mapblock_pos, building_def)
				if not success then
					group_match = false
					break
				end
			end

			if not group_match then
				break
			end
		end

		if group_match then
			return true
		end
	end

	return false, "no matching condition found"
end

-- checks if a building with specified group is placed there already
building_lib.register_condition("group", {
    can_build = function(mapblock_pos, _, value)
		local building_info = building_lib.get_placed_building_info(mapblock_pos)
		if building_info then
			local building_def = building_lib.get_building(building_info.name)
			if building_def and building_def.groups and building_def.groups[value] then
				return true
			end
		end
		return false
	end
})

-- checks if the mapblock position is empty
building_lib.register_condition("empty", {
    can_build = function(mapblock_pos)
		local building_info = building_lib.get_placed_building_info(mapblock_pos)
		return building_info == nil
	end
})