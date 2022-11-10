
building_lib.register_placement("dummy", {
    check = function() return true end,
    get_size = function() return {x=1,y=1,z=1} end,
    place = function(_, _, _, _, callback) callback() end
})

building_lib.register_building("building_lib:dummy", {
	placement = "dummy"
})

mtt.register("build", function(callback)
    local mapblock_pos = {x=0, y=0, z=0}
    local building_name = "building_lib:dummy"
    local rotation = 0
    local playername = "singleplayer"

    -- try to build
    local success, err = building_lib.can_build(mapblock_pos, playername, building_name, rotation)
    assert(not err)
    assert(success)

    -- build
    local callback_called = false
    success, err = building_lib.build(mapblock_pos, playername, building_name, rotation,
        function() callback_called = true end
    )
    assert(not err)
    assert(success)
    assert(callback_called)

    -- try to build again
    success, err = building_lib.can_build(mapblock_pos, playername, building_name, rotation)
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

    -- try to remove
    success, err = building_lib.can_remove(mapblock_pos)
    assert(not err)
    assert(success)

    -- remove
    success, err = building_lib.remove(mapblock_pos)
    assert(not err)
    assert(success)

    -- check
    info = building_lib.get_placed_building_info(mapblock_pos)
    assert(info == nil)

    callback()
end)