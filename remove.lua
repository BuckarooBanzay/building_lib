
function building_lib.can_remove(mapblock_pos)
    local mapblock_data = mapblock_lib.resolve_data_link(building_lib.store, mapblock_pos)
    if not mapblock_data or not mapblock_data.building then
        return false, "no building found"
    end

    local building_def = building_lib.get_building(mapblock_data.building.name)
    if not building_def then
        return false, "unknown building"
    end

    return true
end

function building_lib.remove(mapblock_pos)
    local success, err = building_lib.can_remove(mapblock_pos)
    if not success then
        return success ,err
    end

    local building_info, origin = building_lib.get_placed_building_info(mapblock_pos)
    local size = building_info.size or {x=1, y=1, z=1}

    for x=origin.x,origin.x+size.x-1 do
        for y=origin.y,origin.y+size.y-1 do
            for z=origin.z,origin.z+size.z-1 do
                local offset_mapblock_pos = {x=x, y=y, z=z}
                -- clear building data
                building_lib.store:set(offset_mapblock_pos, nil)
                -- remove mapblock
                mapblock_lib.clear_mapblock(offset_mapblock_pos)
            end
        end
    end

    return true
end