local formname = "building_lib_placer_configure"

local function get_formspec(itemstack)
    local meta = itemstack:get_meta()
    local selected_category = meta:get_string("category") or "_uncategorized"
    local building_list = building_lib.get_buildings_by_category(selected_category)

    local selected_buildingname = meta:get_string("buildingname")
    if not selected_buildingname or selected_buildingname == "" then
        selected_buildingname = building_list[1]
    end

    local selected_building = 1
    local textlist = ""

    for i, building_def in ipairs(building_list) do
        if selected_buildingname == building_def.name then
            selected_building = i
        end

        textlist = textlist .. building_def.name
        if i < #building_list then
            textlist = textlist .. ","
        end
    end

    local categories = building_lib.get_building_categories()
    local selected_category_index = 1
    local cat_list = ""

    for i, category in ipairs(categories) do
        if category == selected_category then
            selected_category_index = i
        end

        cat_list = cat_list .. category
        if i < #categories then
            cat_list = cat_list .. ","
        end
    end

    return "size[10,10;]" ..
        "real_coordinates[true]" ..
        "dropdown[0.5,0.5;9,0.8;category;" .. cat_list .. ";" .. selected_category_index .. "]" ..
        "textlist[0.5,1.5;9,7.5;buildingname;" .. textlist .. ";" .. selected_building .. "]" ..
        "button_exit[0.5,9;9,0.8;back;Back]"
end

minetest.register_on_player_receive_fields(function(player, f, fields)
    if not minetest.check_player_privs(player, { mapblock_lib = true }) then
        return
    end
    if formname ~= f then
        return
    end
    if fields.quit then
        return
    end

    if fields.buildingname then
        local parts = fields.buildingname:split(":")
        if parts[1] == "CHG" then
            local itemstack = player:get_wielded_item()
            local meta = itemstack:get_meta()
            local selected_category = meta:get_string("category") or "_uncategorized"

            local selected = tonumber(parts[2])
            local building_list = building_lib.get_buildings_by_category(selected_category)

            local building = building_list[selected]
            if not building then
                return
            end

            meta:set_string("buildingname", building.name)
            meta:set_string("description", "Selected building: '" .. building.name .. "'")
            player:set_wielded_item(itemstack)
        end
    elseif fields.category then
        local itemstack = player:get_wielded_item()
        local meta = itemstack:get_meta()
        meta:set_string("category", fields.category)
        player:set_wielded_item(itemstack)
        minetest.show_formspec(player:get_player_name(), formname, get_formspec(itemstack))
    end
end)

minetest.register_tool("building_lib:place", {
    description = "building_lib placer",
    inventory_image = "building_lib_place.png^[colorize:#00ff00",
    stack_max = 1,
    range = 0,
    on_secondary_use = function(itemstack, player)
        minetest.show_formspec(player:get_player_name(), formname, get_formspec(itemstack))
    end,
    on_use = function(itemstack, player)
        local playername = player:get_player_name()
        local pointed_mapblock_pos = building_lib.get_pointed_mapblock(player)
        local rotation = building_lib.get_build_rotation(player)

        local placed_building_info, placed_building_origin = building_lib.get_placed_building_info(pointed_mapblock_pos)
        if placed_building_info then
            -- use origin and rotation of existing pointed-at building
            pointed_mapblock_pos = placed_building_origin
            rotation = placed_building_info.rotation
        end

        local meta = itemstack:get_meta()
        local buildingname = meta:get_string("buildingname")
        local success, err = building_lib.build(pointed_mapblock_pos, playername, buildingname, rotation)
        if not success then
            minetest.chat_send_player(playername, err)
        end
    end,
    on_step = function(itemstack, player)
        local playername = player:get_player_name()
        local pointed_mapblock_pos = building_lib.get_pointed_mapblock(player)
        local rotation = building_lib.get_build_rotation(player)

        local placed_building_info, placed_building_origin = building_lib.get_placed_building_info(pointed_mapblock_pos)
        if placed_building_info then
            -- use origin and rotation of existing pointed-at building
            pointed_mapblock_pos = placed_building_origin
            rotation = placed_building_info.rotation
        end

        local meta = itemstack:get_meta()
        local buildingname = meta:get_string("buildingname")
        local building_def = building_lib.get_building(buildingname)
        if not building_def then
            building_lib.clear_preview(playername)
            return
        end

        local size = building_lib.get_building_size(building_def, rotation)
        local mapblock_pos2 = vector.add(pointed_mapblock_pos, vector.subtract(size, 1))

        local color = "#00ff00"
        local can_build = building_lib.can_build(pointed_mapblock_pos, playername, building_def.name, rotation)
        if not can_build then
            color = "#ffff00"
        end

        building_lib.show_preview(
            playername,
            "building_lib_place.png",
            color,
            building_def,
            pointed_mapblock_pos,
            mapblock_pos2,
            rotation
        )
    end,
    on_blur = function(player)
        local playername = player:get_player_name()
        building_lib.clear_preview(playername)
    end
})
