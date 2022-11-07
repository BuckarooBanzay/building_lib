
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

    return function(minp, maxp)
        local min_mapblock = mapblock_lib.get_mapblock(minp)
        local max_mapblock = mapblock_lib.get_mapblock(maxp)

        height_perlin = height_perlin or minetest.get_perlin_map(opts.height_params, map_lengths_xyz)
        temperature_perlin = temperature_perlin or minetest.get_perlin_map(opts.temperature_params, map_lengths_xyz)
        humidity_perlin = humidity_perlin or minetest.get_perlin_map(opts.humidity_params, map_lengths_xyz)

        for z=min_mapblock.z,max_mapblock.z do
        for x=min_mapblock.x,max_mapblock.x do
        for y=min_mapblock.y,max_mapblock.y do
            local mapblock_pos = { x=x, y=y, z=z }
            local height_perlin_map = {}
            local temperature_perlin_map = {}
            local humidity_perlin_map = {}

            height_perlin:get_2d_map_flat({x=mapblock_pos.x, y=mapblock_pos.z}, height_perlin_map)
            temperature_perlin:get_2d_map_flat({x=mapblock_pos.x, y=mapblock_pos.z}, temperature_perlin_map)
            humidity_perlin:get_2d_map_flat({x=mapblock_pos.x, y=mapblock_pos.z}, humidity_perlin_map)

            local height = math.floor(math.abs(height_perlin_map[1]) * 6) -1
            local temperature = math.floor(math.abs(temperature_perlin_map[1]) * 100)
            local humidity = math.floor(math.abs(humidity_perlin_map[1]) * 100)

            local biome = select_biome(opts.biomes, temperature, humidity)

            if mapblock_pos.y <= height then
                building_lib.do_build_mapgen(mapblock_pos, biome.buildings.full, 0)
            end
        end --y
        end --x
        end --z
    end
end