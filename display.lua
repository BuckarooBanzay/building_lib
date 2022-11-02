
-- playername => minetest.pos_to_string(pos1) .. "/" .. minetest.pos_to_string(pos2)
local active_entities = {}

local function get_entity_key(pos1, pos2)
	return minetest.pos_to_string(pos1) .. "/" .. minetest.pos_to_string(pos2)
end

minetest.register_entity("building_lib:display", {
	initial_properties = {
		physical = false,
        static_save = false,
		collisionbox = {0, 0, 0, 0, 0, 0},
		visual = "upright_sprite",
		visual_size = {x=10, y=10},
		textures = {"building_lib_place.png"},
		glow = 10
	},
	on_step = function(self)
		local entry = active_entities[self.playername]
		if not entry or entry ~= self.key then
			-- not valid anymore
			self.object:remove()
		end
	end
})

minetest.register_chatcommand("test", {
	func = function(name)
		local player = minetest.get_player_by_name(name)
		local pos = player:get_pos()
		local mapblock_pos = mapblock_lib.get_mapblock(pos)
		building_lib.show_preview(name, mapblock_pos, vector.add(mapblock_pos, {x=1, y=1, z=0}))
	end
})

local function add_preview_entity(playername, key, visual_size, pos, rotation)
	local ent = minetest.add_entity(pos, "building_lib:display")
	local luaent = ent:get_luaentity()
	luaent.playername = playername
	luaent.key = key
	ent:set_properties({
		visual_size = visual_size,
	})
	ent:set_rotation(rotation)
end

function building_lib.has_preview(playername)
	return active_entities[playername]
end

function building_lib.show_preview(playername, mapblock_pos1, mapblock_pos2)
	mapblock_pos2 = mapblock_pos2 or mapblock_pos1
	local key = get_entity_key(mapblock_pos1, mapblock_pos2)
	if active_entities[playername] == key then
		-- already active on the same region
		return
	end
	active_entities[playername] = key

	local min, _ = mapblock_lib.get_mapblock_bounds_from_mapblock(mapblock_pos1)

	local size_mapblocks = vector.subtract(vector.add(mapblock_pos2, 1), mapblock_pos1) -- 1 .. n
	local size = vector.multiply(size_mapblocks, 16) -- 16 .. n
	local half_size = vector.divide(size, 2) -- 8 .. n

	-- z-
	add_preview_entity(playername, key,
		{x=size.x, y=size.y},
		vector.add(min, {x=half_size.x-0.5, y=half_size.y-0.5, z=-0.5}),
		{x=0, y=0, z=0}
	)

	-- z+
	add_preview_entity(playername, key,
		{x=size.x, y=size.y},
		vector.add(min, {x=half_size.x-0.5, y=half_size.y-0.5, z=size.z-0.5}),
		{x=0, y=0, z=0}
	)

	-- x-
	add_preview_entity(playername, key,
		{x=size.z, y=size.y},
		vector.add(min, {x=-0.5, y=half_size.y-0.5, z=half_size.z-0.5}),
		{x=0, y=math.pi/2, z=0}
	)

	-- x+
	add_preview_entity(playername, key,
		{x=size.z, y=size.y},
		vector.add(min, {x=size.x-0.5, y=half_size.y-0.5, z=half_size.z-0.5}),
		{x=0, y=math.pi/2, z=0}
	)

	-- y-
	add_preview_entity(playername, key,
		{x=size.x, y=size.z},
		vector.add(min, {x=half_size.x-0.5, y=-0.5, z=half_size.z-0.5}),
		{x=math.pi/2, y=0, z=0}
	)

	-- y+
	add_preview_entity(playername, key,
		{x=size.x, y=size.z},
		vector.add(min, {x=half_size.x-0.5, y=size.y-0.5, z=half_size.z-0.5}),
		{x=math.pi/2, y=0, z=0}
	)
end

function building_lib.clear_preview(playername)
	active_entities[playername] = nil
end