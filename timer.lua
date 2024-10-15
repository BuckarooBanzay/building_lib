
local BuildingTimer = {}
local BuildingTimer_mt = { __index = BuildingTimer }


function building_lib.get_building_timer(mapblock_pos)
    local self = {
        mapblock_pos = mapblock_pos
    }

    return setmetatable(self, BuildingTimer_mt)
end

function BuildingTimer:get_entry()
    local data = building_lib.store:get_group_data(self.mapblock_pos)
    if not data.timers then
        -- create timers table
        data.timers = {}
        building_lib.store:set_group_data(self.mapblock_pos, data)
    end

    local key = minetest.pos_to_string(self.mapblock_pos)
    return data.timers[key] or {}
end

function BuildingTimer:set_entry(entry)
    local data = building_lib.store:get_group_data(self.mapblock_pos)
    if not data.timers then
        -- create timers table
        data.timers = {}
    end

    local key = minetest.pos_to_string(self.mapblock_pos)
    data.timers[key] = entry
    building_lib.store:set_group_data(self.mapblock_pos, data)
end

function BuildingTimer:set(timeout, elapsed)
    if timeout > 0 then
        self:set_entry({
            timeout = timeout,
            elapsed = elapsed
        })
    else
        -- stopped, remove entry
        self:set_entry(nil)
    end
end

function BuildingTimer:start(timeout)
    self:set(timeout, 0)
end

function BuildingTimer:stop()
    self:set(0, 0)
end

function BuildingTimer:get_timeout()
    local entry = self:get_entry()
    return entry.timeout or 0
end

function BuildingTimer:get_elapsed()
    local entry = self:get_entry()
    return entry.elapsed or 0
end

function BuildingTimer:is_started()
    local entry = self:get_entry()
    return entry.timeout and entry.timeout > entry.elapsed
end

function building_lib.update_timers(pos, interval)
    local rpos = mapblock_lib.get_mapblock(pos)
    local data = building_lib.store:get_group_data(rpos)

    print(dump({
        fn = "update_timers data",
        pos = pos,
        interval = interval,
        rpos = rpos,
        data = data
    }))

    if not data.timers then
        -- no timers found in the mapblock
        return
    end

    for mapblock_pos_str, entry in pairs(data.timers) do
        print(dump({
            fn = "update_timers iter",
            mapblock_pos_str = mapblock_pos_str,
            pos = pos,
            interval = interval,
            entry = entry
        }))
        -- increment active timers and call `on_timer` on buildings
        local mapblock_pos = minetest.pos_to_string(mapblock_pos_str)
        entry.elapsed = entry.elapsed + interval

        local remove_timer = false

        if entry.elapsed >= entry.timeout then
            -- timer event
            local def = building_lib.get_building_def_at(mapblock_pos)
            if type(def.on_timer) == "function" then
                local result = def.on_timer(mapblock_pos, entry.elapsed)
                if result then
                    -- reschedule
                    entry.elapsed = 0
                else
                    -- remove
                    remove_timer = true
                end
            else
                -- invalid field type
                remove_timer = true
            end
        end

        if remove_timer then
            data.timers[mapblock_pos_str] = nil
        end
    end

    print(dump({
        fn = "post update_timers data",
        pos = pos,
        interval = interval,
        rpos = rpos,
        data = data
    }))

    -- store timer data
    building_lib.store:set_group_data(rpos, data)
end

local TIMER_INTERVAL = 2

-- iterate over active areas and operate on `DataStorage:get_group_data(pos)`
local function timer_update_loop()
    local visited = {}

    for _, player in ipairs(minetest.get_connected_players()) do
        local ppos = player:get_pos()

        local range = building_lib.granularity * building_lib.active_timer_range
        local min = vector.subtract(ppos, range)
        local max = vector.add(ppos, range)

        for x = min.x, max.x, range do
            for y = min.y, max.y, range do
                for z = min.z, max.z, range do
                    local pos = vector.new(x,y,z)

                    -- rounded down position with granularity
                    local rpos = vector.floor(vector.divide(ppos, building_lib.granularity))
                    local key = minetest.pos_to_string(rpos)

                    -- check if already processed
                    if not visited[key] then
                        building_lib.update_timers(pos, TIMER_INTERVAL)
                        visited[key] = true
                    end
                end
            end
        end
    end

    minetest.after(TIMER_INTERVAL, timer_update_loop)
end

minetest.after(1, timer_update_loop)
