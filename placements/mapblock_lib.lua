
-- cache-key -> fn
local cache = {}

local function get_cache_key(building_def, rotation)
	return building_def.name .. "/" .. (rotation or 0)
end

-- mapblock_lib schematic catalog
building_lib.register_placement("mapblock_lib", {
	place = function(self, mapblock_pos, building_def, replacements, rotation)
		local catalog
		local offset = {x=0, y=0, z=0}
		local enable_cache = false
		local cache_key = get_cache_key(building_def, rotation)

		if type(building_def.catalog) == "table" then
			catalog = mapblock_lib.get_catalog(building_def.catalog.filename)
			offset = building_def.catalog.offset or {x=0, y=0, z=0}
			enable_cache = building_def.catalog.cache
		else
			catalog = mapblock_lib.get_catalog(building_def.catalog)
		end

		if enable_cache and cache[cache_key] then
			-- rotated building already cached
			cache[cache_key](mapblock_pos)
			return Promise.resolve()
		end

		local size = self.get_size(self, mapblock_pos, building_def, 0)

		local catalog_pos1 = vector.add({x=0, y=0, z=0}, offset)
		local catalog_pos2 = vector.add(catalog_pos1, vector.add(size, -1))

		return Promise.async(function(await)
			for catalog_pos in mapblock_lib.pos_iterator(catalog_pos1, catalog_pos2) do
				-- transform catalog position relative to offset
				local rel_pos = vector.subtract(catalog_pos, offset)
				local max_pos = vector.subtract(catalog_pos2, offset)
				local rotated_rel_catalog_pos = mapblock_lib.rotate_pos(rel_pos, max_pos, rotation)

				-- translate to world-coords
				local world_pos = vector.add(mapblock_pos, rotated_rel_catalog_pos)

				local place_fn = catalog:prepare(catalog_pos, {
					on_metadata = building_def.on_metadata,
					transform = {
						rotate = {
							axis = "y",
							angle = rotation,
							disable_orientation = building_def.disable_orientation
						},
						replace = replacements
					}
				})

				-- cache prepared mapblock if enabled
				if enable_cache then
					-- verify size constraints for caching
					assert(vector.equals(size, {x=1, y=1, z=1}))
					cache[cache_key] = place_fn
				end

				if place_fn then
					-- only place if possible (mapblock found in catalog)
					place_fn(world_pos)
				end

				await(Promise.after(0))
			end
		end)
	end,

	get_size = function(_, _, building_def, rotation)
		local size
		if type(building_def.catalog) == "table" then
			size = building_def.catalog.size or {x=1, y=1, z=1}
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
