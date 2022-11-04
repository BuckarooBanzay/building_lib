
building_lib.register_placement("default", {
	place = function(_, mapblock_pos, building_def, rotation, callback)
		local catalog = mapblock_lib.get_catalog(building_def.catalog)
		catalog:deserialize_all(mapblock_pos, {
			callback = callback,
			rotate_y = rotation
		})
	end,
	get_size = function(_, _, building_def, rotation)
		local catalog = mapblock_lib.get_catalog(building_def.catalog)
		return mapblock_lib.rotate_size(catalog:get_size(), rotation)
	end,
	validate = function(_, building_def)
		local catalog, err = mapblock_lib.get_catalog(building_def.catalog)
		if catalog then
			return true
		else
			return false, err
		end
	end
})
