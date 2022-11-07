
local function select_biome(biomes, temperature, humidity)
    local selected_score = -1
    local selected_biome

    for _, biome in ipairs(biomes) do
        local score = math.abs(temperature - biome.temperature) + math.abs(humidity - biome.humidity)
        if not selected_biome or score > selected_score then
            selected_biome = biome
        end
    end

    return selected_biome
end

function building_lib.create_mapgen(opts)
    assert(#opts.biomes > 0)

    local map_lengths_xyz = {x=1, y=1, z=1}
    opts.water_level = opts.water_level or 0

    opts.height_params = opts.height_params or {
        offset = 0,
        scale = 1,
        spread = {x=64, y=64, z=64},
        seed = 5477835,
        octaves = 2,
        persist = 0.5
    }

    opts.temperature_params = opts.temperature_params or {
        offset = 0,
        scale = 1,
        spread = {x=64, y=64, z=64},
        seed = 952995,
        octaves = 2,
        persist = 0.5
    }

    opts.humidity_params = opts.humidity_params or {
        offset = 0,
        scale = 1,
        spread = {x=128, y=128, z=128},
        seed = 2946271,
        octaves = 2,
        persist = 0.5
    }

    local height_perlin, temperature_perlin, humidity_perlin

    -- [x .. "/" .. z] = @number
    local height_cache = {}
    local function get_height(mapblock_pos)
        local key = mapblock_pos.x .. "/" .. mapblock_pos.z
        if not height_cache[key] then
            height_perlin = height_perlin or minetest.get_perlin_map(opts.height_params, map_lengths_xyz)
            local height_perlin_map = {}
            height_perlin:get_2d_map_flat({x=mapblock_pos.x, y=mapblock_pos.z}, height_perlin_map)
            local height = math.floor(math.abs(height_perlin_map[1]) * 6) -1
            height_cache[key] = height
        end
        return height_cache[key]
    end

    -- [x .. "/" .. z] = @number
    local temperature_cache = {}
    local humidity_cache = {}
    local function get_temperature_humidity(mapblock_pos)
        local key = mapblock_pos.x .. "/" .. mapblock_pos.z
        if not temperature_cache[key] then
            temperature_perlin = temperature_perlin or minetest.get_perlin_map(opts.temperature_params, map_lengths_xyz)
            humidity_perlin = humidity_perlin or minetest.get_perlin_map(opts.humidity_params, map_lengths_xyz)

            local temperature_perlin_map = {}
            local humidity_perlin_map = {}

            temperature_perlin:get_2d_map_flat({x=mapblock_pos.x, y=mapblock_pos.z}, temperature_perlin_map)
            humidity_perlin:get_2d_map_flat({x=mapblock_pos.x, y=mapblock_pos.z}, humidity_perlin_map)

            local temperature = math.floor(math.abs(temperature_perlin_map[1]) * 100)
            local humidity = math.floor(math.abs(humidity_perlin_map[1]) * 100)

            temperature_cache[key] = temperature
            humidity_cache[key] = humidity
        end
        return temperature_cache[key], humidity_cache[key]
    end

    return function(minp, maxp)
        local min_mapblock = mapblock_lib.get_mapblock(minp)
        local max_mapblock = mapblock_lib.get_mapblock(maxp)

        if max_mapblock.y < opts.from_y or min_mapblock.y > opts.to_y then
            -- check broad y-range
            return
        end


        for x=min_mapblock.x,max_mapblock.x do
        for y=min_mapblock.y,max_mapblock.y do
        for z=min_mapblock.z,max_mapblock.z do
            if y < opts.from_y or y > opts.to_y then
                -- check exact y-range
                break
            end

            local mapblock_pos = { x=x, y=y, z=z }
            local temperature, humidity = get_temperature_humidity(mapblock_pos)
            local height = get_height(mapblock_pos)

            local biome = select_biome(opts.biomes, temperature, humidity)

            if mapblock_pos.y == opts.water_level and height <= mapblock_pos.y then
                -- nothing above, place water building
                building_lib.do_build_mapgen(mapblock_pos, biome.buildings.water, 0)
            elseif mapblock_pos.y <= height then
                -- regular "occupied" space
                building_lib.do_build_mapgen(mapblock_pos, biome.buildings.full, 0)
            end
        end --z
        end --y
        end --x
    end
end