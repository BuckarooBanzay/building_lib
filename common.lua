
-- returns the origin of the placed building
function building_lib.get_origin(mapblock_pos)
	local _, origin = mapblock_lib.resolve_data_link(building_lib.store, mapblock_pos)
	return origin
end

-- returns the building_info on the position
function building_lib.get_placed_building_info(mapblock_pos)
	local mapblock_data, origin = mapblock_lib.resolve_data_link(building_lib.store, mapblock_pos)
	if mapblock_data and mapblock_data.building then
		return mapblock_data.building, origin
	end
end

-- returns the building_def on the position
function building_lib.get_building_def_at(mapblock_pos)
	local info, origin = building_lib.get_placed_building_info(mapblock_pos)
	if not info then
		return false, "no building found"
	end

	local building_def = building_lib.get_building(info.name)
	if not building_def then
		return false, "building_def not found for '" .. info.name .. "'"
	end

	return building_def, origin, info.rotation
end

function building_lib.get_building_size(building_def, rotation)
	local placement = building_lib.get_placement(building_def.placement)
	return placement.get_size(placement, nil, building_def, rotation)
end

function building_lib.get_build_rotation(player)
	local yaw = player:get_look_horizontal()
	local degrees = yaw / math.pi * 180
	local rotation = 0
	if degrees > 45 and degrees < (90+45) then
		-- x-
		rotation = 180
	elseif degrees > (90+45) and degrees < (180+45) then
		-- z-
		rotation = 90
	elseif degrees < 45 or degrees > (360-45) then
		-- z+
		rotation = 270
	end
	return rotation
end

function building_lib.get_pointed_mapblock(player)
    return mapblock_lib.get_pointed_position(player, 2)
end

local min_range = 1
local max_range = 10

function building_lib.get_next_buildable_position(player, buildingname)
	local playername = player:get_player_name()

	for range=min_range,max_range do
		local pointed_mapblock_pos = mapblock_lib.get_pointed_position(player, range)
		local rotation = building_lib.get_build_rotation(player)

		local placed_building_info, placed_building_origin = building_lib.get_placed_building_info(pointed_mapblock_pos)
		if placed_building_info then
			-- use origin and rotation of existing pointed-at building
			pointed_mapblock_pos = placed_building_origin
			rotation = placed_building_info.rotation
		end

		local building_def = building_lib.get_building(buildingname)
		if building_def then
			local size = building_lib.get_building_size(building_def, rotation)
			local mapblock_pos2 = vector.add(pointed_mapblock_pos, vector.subtract(size, 1))

			local can_build = building_lib.can_build(pointed_mapblock_pos, playername, building_def.name, rotation)
			if can_build then
				return building_def, pointed_mapblock_pos, mapblock_pos2, rotation
			end
		end
	end

	return false
end

function building_lib.get_next_removable_position(player)
	for range=min_range,max_range do
		local pointed_mapblock_pos = mapblock_lib.get_pointed_position(player, range)

		local building_info, origin = building_lib.get_placed_building_info(pointed_mapblock_pos)
		if building_info then
			local building_def = building_lib.get_building(building_info.name)

			if building_def then
				local size = building_lib.get_building_size(building_def, building_info.rotation or 0)
				local mapblock_pos2 = vector.add(origin, vector.subtract(size, 1))

				local can_remove = building_lib.can_remove(origin)
				if can_remove then
					return building_def, origin, mapblock_pos2, building_info.rotation
				end
			end
		end
	end

	return false
end
