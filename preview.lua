local cube_len = 8

-- name -> { png, width, height, timestamp }
local previews = {}

function building_lib.generate_building_preview(building_def)
    local catalog
    local offset = {x=0, y=0, z=0}
    local size

    if type(building_def.catalog) == "table" then
        catalog = mapblock_lib.get_catalog(building_def.catalog.filename)
        offset = building_def.catalog.offset or {x=0, y=0, z=0}
        size = building_def.catalog.size or {x=1, y=1, z=1}
    else
        catalog = mapblock_lib.get_catalog(building_def.catalog)
        size = catalog:get_size()
    end

    local mb_pos2 = vector.add(offset, vector.subtract(size, 1))

    local min = mapblock_lib.get_mapblock_bounds_from_mapblock(offset)
    local _, max = mapblock_lib.get_mapblock_bounds_from_mapblock(mb_pos2)

    local png = isogen.draw(min, max, {
        cube_len = cube_len,
        get_node = function(pos)
            return catalog:get_node(pos)
        end
    })

    local node_size = vector.add(vector.subtract(max, min), 1)
    local width, height = isogen.calculate_image_size(node_size, cube_len)

    return {
        png = minetest.encode_base64(png),
        width = width,
        height = height,
        timestamp = os.time()
    }
end

-- preview file in the world folder
local preview_filename = minetest.get_worldpath() .. "/building_preview.json"

local function load_previews()
    local f = io.open(preview_filename, "rb")
    if f then
        -- read previous previews
        local json = f:read("*all")
        f:close()
        previews = minetest.parse_json(json)
    end
end

local function save_previews()
    minetest.safe_file_write(preview_filename, minetest.write_json(previews))
end

load_previews()

minetest.register_chatcommand("building_previewgen", {
    params = "[modname]",
    privs = {
        mapblock_lib = true
    },
    func = function(name, modname)
        local buildings = building_lib.get_buildings()
        local list = {}
        for _, building in pairs(buildings) do
            if building.modname == modname and building.placement == "mapblock_lib" then
                table.insert(list, building)
            end
        end

        if #list == 0 then
            return false, "no buildings found with given modname"
        end

        local count = 0
        local worker
        worker = function()
            local building = table.remove(list)
            if not building then
                minetest.chat_send_player(name, "Done generating " .. count .. " previews")
                save_previews()
                return
            end

            minetest.chat_send_player(name, "Generating preview for '" .. building.name .. "'")
            count = count + 1
            local data, err = building_lib.generate_building_preview(building)
            if not data then
                minetest.chat_send_player(
                    name,
                    "Preview generation failed for building: '" .. building.name .. "', error: " .. err
                )
            else
                previews[building.name] = data
                minetest.after(0, worker)
            end
        end

        minetest.after(0, worker)
        return true, "Scheduled " .. #list .. " buildings for preview-generation"
    end
})

-- returns a cached or ad-hoc generated preview table
function building_lib.get_building_preview(building_name)
    if previews[building_name] then
        return previews[building_name]
    end

    local building_def = building_lib.get_building(building_name)
    if not building_def then
        return false, "building not found: '" .. building_name .. "'"
    end

    local preview, err = building_lib.generate_building_preview(building_def)
    if err then
        return false, "generate preview error: " .. err
    end

    previews[building_name] = preview
    save_previews()
    return preview
end

-- TODO: generate all missing previews on startup