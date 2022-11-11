
local function check_free(mapblock_pos)
	if building_lib.get_placed_building_info(mapblock_pos) then
		return false
	else
		return true
	end
end

local function apply_rotation_offset(building_def, rotation)
	if building_def.rotation_offset then
		rotation = rotation + building_def.rotation_offset
		while rotation >= 360 do
			rotation = rotation - 360
		end
	end

	return rotation
end

function building_lib.can_build(mapblock_pos, _, building_name, rotation)
	local building_def = building_lib.get_building(building_name)
	if not building_def then
		return false, "Building not found: '" .. building_name .. "'"
	end

	-- check placement definition
	local placement = building_lib.get_placement(building_def.placement)

	rotation = apply_rotation_offset(building_def, rotation)

	-- check the conditions on every mapblock the building would occupy
	local size, message = placement.get_size(placement, mapblock_pos, building_def, rotation)
	if not size then
		return false, message or "size check '" .. building_def.placement .. "' failed"
	end

	-- true if the existing building can be built over
	local build_over_mode = false

	-- check if we can build over other buildings
	if building_def.build_over then
		local other_building_info, origin = building_lib.get_placed_building_info(mapblock_pos)
		if other_building_info then
			-- other building exists, check if it matches
			if not vector.equals(origin, mapblock_pos) then
				return false, "Placement-origin mismatch"
			end

			local other_building_def = building_lib.get_building(other_building_info.name)
			if not other_building_def then
				return false, "Unknown building"
			end

			local matches = false
			if building_def.build_over.groups and other_building_def.groups then
				for _, group in ipairs(building_def.build_over.groups) do
					if other_building_def.groups[group] then
						matches = true
						break
					end
				end
			end

			if not matches and building_def.build_over.names then
				for _, name in ipairs(building_def.build_over.names) do
					if name == other_building_def.name then
						matches = true
						break
					end
				end
			end

			if matches then
				build_over_mode = true
			end
		end
	end

	local it = mapblock_lib.pos_iterator(mapblock_pos, vector.add(mapblock_pos, vector.subtract(size, 1)))
	while true do
		local offset_mapblock_pos = it()
		if not offset_mapblock_pos then
			break
		end

		if not build_over_mode then
			-- check if the area is free
			local is_free = check_free(offset_mapblock_pos)
			if not is_free then
				return false, "Space already occupied at " .. minetest.pos_to_string(offset_mapblock_pos)
			end
		end

		local success
		if offset_mapblock_pos.y == mapblock_pos.y then
			-- check ground conditions
			success, message = building_lib.check_conditions(offset_mapblock_pos, building_def.ground_conditions, building_def)
			if not success then
				return false, message
			end
		end

		success, message = building_lib.check_conditions(offset_mapblock_pos, building_def.conditions, building_def)
		if not success then
			return false, message
		end
	end

	-- all checks ok
	return true
end

function building_lib.build(mapblock_pos, playername, building_name, rotation, callback)
	callback = callback or function() end
	rotation = rotation or 0

	local success, message = building_lib.can_build(mapblock_pos, playername, building_name, rotation)
	if not success then
		return false, message
	end

	local building_def = building_lib.get_building(building_name)
	assert(building_def)

	rotation = apply_rotation_offset(building_def, rotation)

	-- place into world
	local placement = building_lib.get_placement(building_def.placement)
	local size = placement.get_size(placement, mapblock_pos, building_def, rotation)

	-- write new data
	mapblock_lib.for_each(mapblock_pos, vector.add(mapblock_pos, vector.subtract(size, 1)), function(offset_mapblock_pos)
		if vector.equals(offset_mapblock_pos, mapblock_pos) then
			-- origin
			building_lib.store:merge(offset_mapblock_pos, {
				building = {
					name = building_def.name,
					size = size,
					rotation = rotation,
					owner = playername
				}
			})
		else
			-- link to origin
			building_lib.store:merge(offset_mapblock_pos, mapblock_lib.create_data_link(mapblock_pos))
		end
	end)

	placement.place(placement, mapblock_pos, building_def, rotation, callback)
	building_lib.fire_event("placed", mapblock_pos, playername, building_def, rotation, size)
	return true
end

-- mapgen build shortcut, only for 1x1x1 sized buildings
function building_lib.build_mapgen(mapblock_pos, building_name, rotation)
	local building_def = building_lib.get_building(building_name)
	local placement = building_lib.get_placement(building_def.placement)

	building_lib.store:merge(mapblock_pos, {
		building = {
			name = building_def.name,
			rotation = rotation,
			owner = building_lib.mapgen_owned
		}
	})

	placement.place(placement, mapblock_pos, building_def, rotation)
	building_lib.fire_event("placed_mapgen", mapblock_pos, building_def, rotation)
end