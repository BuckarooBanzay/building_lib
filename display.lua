
minetest.register_entity("building_lib:display", {
	initial_properties = {
		physical = false,
        static_save = false,
		collisionbox = {0, 0, 0, 0, 0, 0},
		visual = "upright_sprite",
		visual_size = {x=10, y=10},
		textures = {"building_lib_place.png"},
		glow = 10
	}
})

minetest.register_chatcommand("test", {
	func = function(name)
		local player = minetest.get_player_by_name(name)
		local pos = player:get_pos()
        local mapblock_center = mapblock_lib.get_mapblock_center(pos)

        local ent = minetest.add_entity(mapblock_center, "building_lib:display")
        ent:set_properties({
            visual_size = {x=5, y=5},
            nametag = "test"
        })
	end
})