
local function check_condition(key, value, mapblock_pos, building_def)
	local condition = building_lib.get_condition(key)
	if condition and type(condition.can_build) == "function" then
		return condition.can_build(mapblock_pos, building_def, value)
	end
	return true
end

local function check_map(mode, map, mapblock_pos, building_def)
	local placement_allowed = false
	local error_msg

	for key, value in pairs(map) do
		local success, msg = check_condition(key, value, mapblock_pos, building_def)
		if success then
			-- success
			placement_allowed = true
		elseif mode == "and" then
			-- failure and in AND mode, return immediately
			return false, msg or "condition failed: '" .. key .. "'"
		else
			error_msg = msg or "condition failed: '" .. key .. "'"
		end
	end

	return placement_allowed, error_msg
end

function building_lib.check_conditions(mapblock_pos, conditions, building_def)
	-- go through conditions
	if conditions then
		-- array-like AND/OR def support
		if conditions[1] then
			-- OR'ed array
			local placement_allowed = false
			local error_msg

			for _, entry in ipairs(conditions) do
				local success, msg = check_map("and", entry, mapblock_pos, building_def)
				if success then
					placement_allowed = true
					break
				else
					error_msg = msg
				end
			end

			if not placement_allowed then
				return false, error_msg or "<unknown>"
			end
		else
			-- map
			local success, error_msg = check_map("or", conditions, mapblock_pos, building_def)
			if not success then
				return false, error_msg or "<unknown>"
			end
		end
	end

	return true
end

-- checks if a building with specified group is placed there already
building_lib.register_condition("group", {
    can_build = function(mapblock_pos, _, value)
		local building_info = building_lib.get_placed_building_info(mapblock_pos)
		if building_info then
			local building_def = building_lib.get_building(building_info.name)
			if building_def and building_def.groups[value] then
				return true
			end
		end
		return false
	end
})

-- checks if a building with specified group is placed there below
building_lib.register_condition("on_group", {
    can_build = function(mapblock_pos, _, value)
		local below_mapblock_pos = vector.subtract(mapblock_pos, {x=0, y=1, =1})
		local building_info = building_lib.get_placed_building_info(below_mapblock_pos)
		if building_info then
			local building_def = building_lib.get_building(building_info.name)
			if building_def and building_def.groups[value] then
				return true
			end
		end
		return false
	end
})