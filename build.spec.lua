
building_lib.register_condition("success", {
    can_build = function() return true end
})

building_lib.register_condition("failure", {
    can_build = function() return false, "no success" end
})

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
    local success, err = building_lib.do_build(
        mapblock_pos,
        "singleplayer",
        building_name,
        0,
        function() callback() end
    )
    assert(not err)
    assert(success)

    local info = building_lib.get_placed_building_info(mapblock_pos)
    assert(info.name == building_name)
    assert(info.rotation == 0)
    assert(info.owner == "singleplayer")
    assert(info.size.x == 1)
    assert(info.size.y == 1)
    assert(info.size.z == 1)
end)