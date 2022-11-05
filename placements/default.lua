
building_lib.register_placement("default", {
	place = function(self, mapblock_pos, building_def, rotation, callback)
		local catalog = mapblock_lib.get_catalog(building_def.catalog)
		local size = self.get_size(self, mapblock_pos, building_def, 0)
		local catalog_pos1 = {x=0, y=0, z=0}
		local catalog_pos2 = vector.add(catalog_pos1, vector.add(size, -1))
		local iterator = mapblock_lib.pos_iterator(catalog_pos1, catalog_pos2)

		local worker
		worker = function()
			local catalog_pos = iterator()
			if not catalog_pos then
				return callback()
			end

			-- transform catalog position
			local rotated_catalog_pos = mapblock_lib.rotate_pos(catalog_pos, catalog_pos2, rotation)
			-- translate to world-coords
			local world_pos = vector.add(mapblock_pos, rotated_catalog_pos)

			catalog:deserialize(catalog_pos, world_pos, {
				transform = {
					rotate = {
						axis = "y",
						angle = rotation
					}
				}
			})

			minetest.after(0, worker)
		end

		worker()
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
