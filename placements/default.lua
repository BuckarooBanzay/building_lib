
building_lib.register_placement("default", {
	place = function(self, mapblock_pos, building_def, rotation, callback)
		local catalog = mapblock_lib.get_catalog(building_def.catalog)
		local size = self.get_size(self, mapblock_pos, building_def, rotation)
		local catalog_pos1 = {x=0, y=0, z=0}
		local catalog_pos2 = vector.add(catalog_pos1, vector.add(size, -1))
		local iterator = mapblock_lib.pos_iterator(catalog_pos1, catalog_pos2)

		local worker
		worker = function()
			local catalog_pos = iterator()
			if not catalog_pos then
				return callback()
			end

			-- TODO: rotate position
			-- rel_pos = mapblock_lib.rotate_pos(rel_pos, self.manifest.range, options.rotate_y)

			local world_pos = vector.add(mapblock_pos, catalog_pos)
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
