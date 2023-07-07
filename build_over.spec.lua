
building_lib.register_building("building_lib:dummy_base", {
	placement = "dummy",
    size = { x=3, y=1, z=1 }
})

-- building can only be placed over "dummy"
building_lib.register_building("building_lib:dummy_extension", {
	placement = "dummy",
    size = { x=3, y=1, z=1 },
    conditions = {
        {
            ["*"] = { name = "building_lib:dummy_base" }
        }
    }
})

local mapblock_pos = {x=0, y=0, z=0}
local playername = "singleplayer"

mtt.register("build-over (success)", function(callback)
    -- clear store
    building_lib.store:clear()

    -- build
    building_lib.build(mapblock_pos, playername, "building_lib:dummy_base", 0)
    :next(callback)
    :catch(callback)
end)

mtt.register("build-over (wrong angle)", function(callback)
    -- build
    building_lib.build(mapblock_pos, playername, "building_lib:dummy_extension", 90)
    :catch(function()
        callback()
    end)
end)

mtt.register("build-over (wrong angle 2)", function(callback)
    -- build
    building_lib.build(mapblock_pos, playername, "building_lib:dummy_extension", 270)
    :catch(function()
        callback()
    end)
end)

mtt.register("build-over (180°)", function(callback)
    -- build
    building_lib.build(mapblock_pos, playername, "building_lib:dummy_extension", 180)
    :next(callback)
    :catch(callback)
end)