local ie = ...

local function generate_preview(building_def)
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
        cube_len = 8,
        get_node = function(pos)
            return catalog:get_node(pos)
        end
    })

    local filename = minetest.get_modpath(building_def.modname) ..
        "/textures/" .. string.gsub(building_def.name, ":", "_") .. "_preview.png"

    local f = ie.io.open(filename, "wb")
    if not f then
        return false, "could not open file: '" .. filename .. "'"
    end

    f:write(png)
    f:close()

    return true
end

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

        local worker
        worker = function()
            local building = table.remove(list)
            if not building then
                minetest.chat_send_player(name, "Done generating previews")
                return
            end

            minetest.chat_send_player(name, "Generating preview for '" .. building.name .. "'")
            local success, err = generate_preview(building)
            if not success then
                minetest.chat_send_player(
                    name,
                    "Preview generation failed for building: '" .. building.name .. "', error: " .. err
                )
            else
                minetest.after(0, worker)
            end
        end

        minetest.after(0, worker)
        return true, "Scheduled " .. #list .. " buildings for preview-generation"
    end
})