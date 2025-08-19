
local building_mapblock_pos = {x=0, y=0, z=0}
local building_name = "building_lib:dummy_timer"
local rotation = 0
local playername = "singleplayer"

local timer_mapblock_pos, timer_elapsed

building_lib.register_building(building_name, {
	placement = "dummy",
    on_timer = function(mapblock_pos, elapsed)
        timer_mapblock_pos = mapblock_pos
        timer_elapsed = elapsed
        return true
    end
})

mtt.register("building_lib.get_building_timer", function()
    -- clear store
    building_lib.store:clear()

    -- try to build
    local success, err = building_lib.can_build(building_mapblock_pos, playername, building_name, rotation)
    assert(not err)
    assert(success)

    -- build
    return building_lib.build(building_mapblock_pos, playername, building_name, rotation)
    :next(function()
        local timer = building_lib.get_building_timer(building_mapblock_pos)
        timer:start(10)

        local pos = { x=0, y=0, z=0 }
        building_lib.update_timers(pos, 5)
        assert(not timer_mapblock_pos)
        assert(not timer_elapsed)

        building_lib.update_timers(pos, 5)
        assert(vector.equals(timer_mapblock_pos, building_mapblock_pos))
        assert(timer_elapsed >= 10)
        timer_elapsed = nil

        building_lib.update_timers_in_area(vector.subtract(pos, 1), vector.add(pos, 1), 5)
        assert(not timer_elapsed)

        building_lib.update_timers_in_area(vector.subtract(pos, 1), vector.add(pos, 1), 5)
        -- TODO
        -- assert(timer_elapsed >= 10)
    end)
end)
