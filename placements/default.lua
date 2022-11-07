
building_lib.register_placement("default", {
	place = function(self, mapblock_pos, building_def, rotation, callback)
		local catalog
		local offset = {x=0, y=0, z=0}
		if type(building_def.catalog) == "table" then
			catalog = mapblock_lib.get_catalog(building_def.catalog.filename)
			offset = building_def.catalog.offset
		else
			catalog = mapblock_lib.get_catalog(building_def.catalog)
		end
		local size = self.get_size(self, mapblock_pos, building_def, 0)

		local catalog_pos1 = vector.add({x=0, y=0, z=0}, offset)
		local catalog_pos2 = vector.add(catalog_pos1, vector.add(size, -1))

		local iterator = mapblock_lib.pos_iterator(catalog_pos1, catalog_pos2)

		local worker
		worker = function()
			local catalog_pos = iterator()
			if not catalog_pos then
				return callback()
			end

			-- transform catalog position relative to offset
			local rel_pos = vector.subtract(catalog_pos, offset)
			local max_pos = vector.subtract(catalog_pos2, offset)
			local rotated_rel_catalog_pos = mapblock_lib.rotate_pos(rel_pos, max_pos, rotation)

			-- translate to world-coords
			local world_pos = vector.add(mapblock_pos, rotated_rel_catalog_pos)

			catalog:deserialize(catalog_pos, world_pos, {
				transform = {
					rotate = {
						axis = "y",
						angle = rotation,
						disable_orientation = building_def.disable_orientation
					}
				}
			})

			minetest.after(0, worker)
		end

		worker()
	end,
	get_size = function(_, _, building_def, rotation)
		local size
		if type(building_def.catalog) == "table" then
			size = building_def.catalog.size
		else
			local catalog = mapblock_lib.get_catalog(building_def.catalog)
			size = catalog:get_size()
		end
		return mapblock_lib.rotate_size(size, rotation)
	end,
	validate = function(_, building_def)
		local catalogfilename = building_def.catalog
		if type(building_def.catalog) == "table" then
			catalogfilename = building_def.catalog.filename
		end

		local catalog, err = mapblock_lib.get_catalog(catalogfilename)
		if catalog then
			return true
		else
			return false, err
		end
	end
})
