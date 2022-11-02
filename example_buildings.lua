local MP = minetest.get_modpath("building_lib")

building_lib.register_building("building_lib:street_straight", {
	catalog = MP .. "/schematics/street_straight.zip"
})

building_lib.register_building("building_lib:block1", {
	catalog = MP .. "/schematics/block.zip"
})