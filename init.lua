
local granularity = 10

building_lib = {
	-- data storage
	store = mapblock_lib.create_data_storage(minetest.get_mod_storage(), {
		granularity = granularity
	}),

	-- mapblock granularity
	granularity = granularity,

	-- active timer range (in granularity steps, 1 means +/-1 * granularity)
	active_timer_range = 1,

	-- special mapgen owner constant
	mapgen_owned = "$$mapgen"
}

local MP = minetest.get_modpath("building_lib")
dofile(MP .. "/memoize.lua")
dofile(MP .. "/entity.lua")
dofile(MP .. "/display.lua")
dofile(MP .. "/api.lua")
dofile(MP .. "/common.lua")
dofile(MP .. "/markers.lua")
dofile(MP .. "/placements/mapblock_lib.lua")
dofile(MP .. "/placements/dummy.lua")
dofile(MP .. "/preview.lua")
dofile(MP .. "/conditions.lua")
dofile(MP .. "/build.lua")
dofile(MP .. "/build_tool.lua")
dofile(MP .. "/autoplace.lua")
dofile(MP .. "/autoplace_tool.lua")
dofile(MP .. "/remove.lua")
dofile(MP .. "/remove_tool.lua")
dofile(MP .. "/timer.lua")
dofile(MP .. "/chat.lua")
dofile(MP .. "/events.lua")
dofile(MP .. "/hacks.lua")
dofile(MP .. "/mapgen.lua")

if minetest.get_modpath("mtt") and mtt.enabled then
	dofile(MP .. "/events.spec.lua")
	dofile(MP .. "/conditions.spec.lua")
	dofile(MP .. "/build.spec.lua")
	dofile(MP .. "/build_over.spec.lua")
	dofile(MP .. "/timer.spec.lua")
end
