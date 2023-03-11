
function building_lib.can_replace(mapblock_pos, _, building_name)
    local new_building_def = building_lib.get_building(building_name)
	if not new_building_def then
		return false, "New building not found: '" .. building_name .. "'"
	end

    local info = building_lib.get_placed_building_info(mapblock_pos)
	if not info then
		return false, "no building found"
	end

    local old_building_def = building_lib.get_building(info.name)
	if not old_building_def then
		return false, "Old building not found: '" .. info.name .. "'"
	end

    local success, message = building_lib.can_remove(mapblock_pos)
	if not success then
		return false, message
	end

    local new_placement = building_lib.get_placement(new_building_def.placement)
	if not info then
		return false, "placement not found"
	end

    local old_size = info.size
    local new_size = new_placement.get_size(new_placement, mapblock_pos, new_building_def, info.rotation)

    if not vector.equals(old_size, new_size) then
        return false, "replacement size does not match"
    end

    return true
end

function building_lib.replace(mapblock_pos, playername, new_building_name, callback)
    callback = callback or function() end

	local success, message = building_lib.can_replace(mapblock_pos, playername, new_building_name)
	if not success then
		return false, message
	end

    local info = building_lib.get_placed_building_info(mapblock_pos)
    local rotation = info.rotation or 0

    -- remove old building
    success, message = building_lib.remove(mapblock_pos, playername)
	if not success then
		return false, message
	end

    -- place new building
    return building_lib.build(mapblock_pos, playername, new_building_name, rotation, callback)
end