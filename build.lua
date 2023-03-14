
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

	local mapblock_pos2 = vector.add(mapblock_pos, vector.subtract(size, 1))

	local success
	success, message = building_lib.check_condition_groups(mapblock_pos, mapblock_pos2, building_def.conditions)
	if not success then
		return false, message
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

	-- fetch current building-def, if any
	local old_building_def = building_lib.get_building_def_at(mapblock_pos)

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

	placement.place(placement, mapblock_pos, building_def, rotation, function()
		callback()
		if old_building_def then
			-- replacement
			building_lib.fire_event("placed_over", mapblock_pos, playername, old_building_def, building_def, rotation, size)
		else
			-- new build
			building_lib.fire_event("placed", mapblock_pos, playername, building_def, rotation, size)
		end
	end)
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