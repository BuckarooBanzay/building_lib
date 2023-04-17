
building_lib.register_building("building_lib:dummy", {
	placement = "dummy"
})

-- building can only be placed over "dummy"
building_lib.register_building("building_lib:dummy_v2", {
	placement = "dummy",
    conditions = {
        {
            ["*"] = { name = "building_lib:dummy" }
        }
    }
})

local mapblock_pos = {x=0, y=0, z=0}
local building_name = "building_lib:dummy"
local rotation = 0
local playername = "singleplayer"


mtt.register("build", function(callback)
    -- clear store
    building_lib.store:clear()

    -- try to build
    local success, err = building_lib.can_build(mapblock_pos, playername, building_name, rotation)
    assert(not err)
    assert(success)

    -- build
    building_lib.build(mapblock_pos, playername, building_name, rotation)
    :next(callback)
end)

mtt.register("try build again", function(callback)
    -- try to build again
    local success, err = building_lib.can_build(mapblock_pos, playername, building_name, rotation)
    assert(err)
    assert(not success)

    -- check
    local info = building_lib.get_placed_building_info(mapblock_pos)
    assert(info.name == building_name)
    assert(info.rotation == rotation)
    assert(info.owner == playername)
    assert(info.size.x == 1)
    assert(info.size.y == 1)
    assert(info.size.z == 1)

    -- try to build over
    success, err = building_lib.can_build(mapblock_pos, playername, "building_lib:dummy_v2", rotation)
    assert(not err)
    assert(success)

    -- build over
    building_lib.build(mapblock_pos, playername, "building_lib:dummy_v2", rotation)
    :next(callback)
end)

mtt.register("remove and verify", function(callback)
    -- try to remove
    local success, err = building_lib.can_remove(mapblock_pos)
    assert(not err)
    assert(success)

    -- remove
    success, err = building_lib.remove(mapblock_pos)
    assert(not err)
    assert(success)

    -- check
    local info = building_lib.get_placed_building_info(mapblock_pos)
    assert(info == nil)

    callback()
end)

mtt.benchmark("build", function(callback, iterations)
    -- clear store
    building_lib.store:clear()

    for _=1,iterations do
        -- build
        building_lib.build(mapblock_pos, playername, building_name, rotation)

        -- remove
        local success, err = building_lib.remove(mapblock_pos)
        assert(not err)
        assert(success)
    end

    callback()
end)