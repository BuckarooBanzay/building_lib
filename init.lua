local storage = minetest.get_mod_storage()

building_lib = {
	-- name -> def
	buildings = {},

	-- name -> def
	placements = {},

	-- name -> def
	conditions = {},

	-- data storage
	store = mapblock_lib.create_data_storage(storage)
}

local MP = minetest.get_modpath("building_lib")
dofile(MP .. "/register.lua")
dofile(MP .. "/get_groups.lua")
dofile(MP .. "/get_building.lua")
dofile(MP .. "/inventory.lua")
dofile(MP .. "/placements/default.lua")
dofile(MP .. "/can_build.lua")
dofile(MP .. "/do_build.lua")
dofile(MP .. "/chat.lua")

if minetest.get_modpath("mtt") and mtt.enabled then
	dofile(MP .. "/can_build.spec.lua")
end

if minetest.settings:get_bool("building_lib.enable_example_buildings") then
	dofile(MP .. "/example_buildings.lua")
end