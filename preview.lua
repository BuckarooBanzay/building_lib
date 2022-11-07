
-- playername => key
local active_preview = {}


local function add_preview_entity(texture, key, visual_size, pos, rotation)
	local ent = building_lib.add_entity(pos, key)
	ent:set_properties({
		visual_size = visual_size,
		textures = {texture}
	})
	ent:set_rotation(rotation)
end

function building_lib.show_preview(texture, playername, mapblock_pos1, mapblock_pos2)
	mapblock_pos2 = mapblock_pos2 or mapblock_pos1
	local key = minetest.pos_to_string(mapblock_pos1) .. "/" .. minetest.pos_to_string(mapblock_pos2) .. "/" .. texture

	if active_preview[playername] == key then
		-- already active on the same region
		return
	end
	-- clear previous entities
	building_lib.clear_preview(playername)
	active_preview[playername] = key

	local min, _ = mapblock_lib.get_mapblock_bounds_from_mapblock(mapblock_pos1)

	local size_mapblocks = vector.subtract(vector.add(mapblock_pos2, 1), mapblock_pos1) -- 1 .. n
	local size = vector.multiply(size_mapblocks, 16) -- 16 .. n
	local half_size = vector.divide(size, 2) -- 8 .. n

	-- z-
	add_preview_entity(texture, key,
		{x=size.x, y=size.y},
		vector.add(min, {x=half_size.x-0.5, y=half_size.y-0.5, z=-0.5}),
		{x=0, y=0, z=0}
	)

	-- z+
	add_preview_entity(texture, key,
		{x=size.x, y=size.y},
		vector.add(min, {x=half_size.x-0.5, y=half_size.y-0.5, z=size.z-0.5}),
		{x=0, y=0, z=0}
	)

	-- x-
	add_preview_entity(texture, key,
		{x=size.z, y=size.y},
		vector.add(min, {x=-0.5, y=half_size.y-0.5, z=half_size.z-0.5}),
		{x=0, y=math.pi/2, z=0}
	)

	-- x+
	add_preview_entity(texture, key,
		{x=size.z, y=size.y},
		vector.add(min, {x=size.x-0.5, y=half_size.y-0.5, z=half_size.z-0.5}),
		{x=0, y=math.pi/2, z=0}
	)

	-- y-
	add_preview_entity(texture, key,
		{x=size.x, y=size.z},
		vector.add(min, {x=half_size.x-0.5, y=-0.5, z=half_size.z-0.5}),
		{x=math.pi/2, y=0, z=0}
	)

	-- y+
	add_preview_entity(texture, key,
		{x=size.x, y=size.z},
		vector.add(min, {x=half_size.x-0.5, y=size.y-0.5, z=half_size.z-0.5}),
		{x=math.pi/2, y=0, z=0}
	)
end

function building_lib.clear_preview(playername)
	if active_preview[playername] then
		building_lib.remove_entities(active_preview[playername])
		active_preview[playername] = nil
	end
end

minetest.register_on_leaveplayer(function(player)
	building_lib.clear_preview(player:get_player_name())
end)