
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

function building_lib.update_timers(pos)
    local mapblock_pos = mapblock_lib.get_mapblock(pos)
    local data = building_lib.store:get_group_data(mapblock_pos)
    if not data.timers then
        -- no timers found in the mapblock
        return
    end

    for mapblock_pos_str, entry in pairs(data.timers) do
        -- TODO: decrement active timers and call `on_timer` on buildings
        print(dump({
            fn = "processing mapblock timer",
            mapblock_pos_str = mapblock_pos_str,
            entry = entry
        }))
    end
end

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
                        building_lib.update_timers(pos)
                        visited[key] = true
                    end
                end
            end
        end
    end

    minetest.after(2, timer_update_loop)
end

minetest.after(1, timer_update_loop)
