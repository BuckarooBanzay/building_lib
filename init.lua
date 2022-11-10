
building_lib = {
	-- data storage
	store = mapblock_lib.create_data_storage(minetest.get_mod_storage()),

	-- special mapgen owner constant
	mapgen_owned = "$$mapgen"
}

local MP = minetest.get_modpath("building_lib")
dofile(MP .. "/entity.lua")
dofile(MP .. "/preview.lua")
dofile(MP .. "/api.lua")
dofile(MP .. "/wield_events.lua")
dofile(MP .. "/common.lua")
dofile(MP .. "/placements/mapblock_lib.lua")
dofile(MP .. "/conditions.lua")
dofile(MP .. "/build.lua")
dofile(MP .. "/remove.lua")
dofile(MP .. "/chat.lua")
dofile(MP .. "/tools.lua")
dofile(MP .. "/events.lua")
dofile(MP .. "/mapgen.lua")

if minetest.get_modpath("mtt") and mtt.enabled then
	dofile(MP .. "/events.spec.lua")
	dofile(MP .. "/conditions.spec.lua")
	dofile(MP .. "/build.spec.lua")
end
