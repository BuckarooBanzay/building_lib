
function building_lib.get_origin(mapblock_pos)
	local _, origin = mapblock_lib.resolve_data_link(building_lib.store, mapblock_pos)
	return origin
end

function building_lib.get_building_at_pos(mapblock_pos)
	local mapblock_data, origin = mapblock_lib.resolve_data_link(building_lib.store, mapblock_pos)
	if mapblock_data and mapblock_data.building then
		return building_lib.get_building(mapblock_data.building.name), origin
	end
end

function building_lib.get_building_size(building_def)
	local placement = building_lib.get_placement(building_def.placement)
	return placement.get_size(placement, nil, building_def)
end
