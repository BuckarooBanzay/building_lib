
building_lib = {
	-- data storage
	store = mapblock_lib.create_data_storage(minetest.get_mod_storage())
}

local MP = minetest.get_modpath("building_lib")
dofile(MP .. "/display.lua")
dofile(MP .. "/api.lua")
dofile(MP .. "/wield_events.lua")
dofile(MP .. "/common.lua")
dofile(MP .. "/inventory.lua")
dofile(MP .. "/placements/default.lua")
dofile(MP .. "/build.lua")
dofile(MP .. "/remove.lua")
dofile(MP .. "/chat.lua")

local enable_example_buildings = minetest.settings:get_bool("building_lib.enable_example_buildings")
local enable_tests = minetest.get_modpath("mtt") and mtt.enabled

if enable_tests then
	dofile(MP .. "/build.spec.lua")
end

if enable_tests or enable_example_buildings then
	dofile(MP .. "/example_buildings.lua")
end

if minetest.settings:get_bool("building_lib.enable_tools") then
	dofile(MP .. "/tools.lua")
end