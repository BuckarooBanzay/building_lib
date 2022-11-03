local formname = "building_lib_placer_configure"

local function get_building_list()
    local building_list = {}
    for name in pairs(building_lib.get_buildings()) do
        table.insert(building_list, name)
    end
    return building_list
end

local function get_formspec(itemstack)
    local meta = itemstack:get_meta()
    local building_list = get_building_list()

    local selected_buildingname = meta:get_string("buildingname")
    if not selected_buildingname or selected_buildingname == "" then
        selected_buildingname = building_list[1]
    end

    local selected_building = 1
    local textlist = ""

    for i, buildingname in ipairs(building_list) do
        if selected_buildingname == buildingname then
            selected_building = i
        end

        textlist = textlist .. buildingname
        if i < #building_list then
            textlist = textlist .. ","
        end
    end

    return "size[8,7;]" ..
        "textlist[0,0.1;8,6;buildingname;" .. textlist .. ";" .. selected_building .. "]" ..
        "button_exit[0.1,6.5;8,1;back;Back]"
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

            local selected = tonumber(parts[2])
            local building_list = get_building_list()

            local buildingname = building_list[selected]
            if not buildingname then
                return
            end

            meta:set_string("buildingname", buildingname)
            meta:set_string("description", "Selected building: '" .. buildingname .. "'")
            player:set_wielded_item(itemstack)
        end
    end
end)

local function get_pointed_mapblock(player)
    return mapblock_lib.get_pointed_position(player, 2)
end

minetest.register_tool("building_lib:place", {
    description = "building_lib placer",
    inventory_image = "building_lib_place.png",
    stack_max = 1,
    range = 0,
    on_secondary_use = function(itemstack, player)
        minetest.show_formspec(player:get_player_name(), formname, get_formspec(itemstack))
    end,
    on_use = function(itemstack, player)
        local meta = itemstack:get_meta()
        local buildingname = meta:get_string("buildingname")
        local pointed_mapblock_pos = get_pointed_mapblock(player)
        local success, err = building_lib.do_build(pointed_mapblock_pos, buildingname)
        if not success then
            minetest.chat_send_player(player:get_player_name(), err)
        end
    end,
    on_step = function(itemstack, player)
        local playername = player:get_player_name()
        local pointed_mapblock_pos = get_pointed_mapblock(player)

        local meta = itemstack:get_meta()
        local buildingname = meta:get_string("buildingname")
        local building_def = building_lib.get_building(buildingname)
        if not building_def then
            building_lib.clear_preview(playername)
            return
        end

        local size = building_lib.get_building_size(building_def)
        local mapblock_pos2 = vector.add(pointed_mapblock_pos, vector.subtract(size, 1))

        local can_build = building_lib.can_build(pointed_mapblock_pos, building_def)
        local texture = "building_lib_place.png"
        if can_build then
            texture = texture .. "^[colorize:#00ff00"
        else
            texture = texture .. "^[colorize:#ffff00"
        end

        building_lib.show_preview(texture, playername, pointed_mapblock_pos, mapblock_pos2)
    end,
    on_blur = function(player)
        local playername = player:get_player_name()
        building_lib.clear_preview(playername)
    end
})

minetest.register_tool("building_lib:remove", {
    description = "building_lib remover",
    inventory_image = "building_lib_remove.png",
    stack_max = 1,
    range = 0,
    on_use = function(_, player)
        local mapblock_pos = get_pointed_mapblock(player)
        local success, err = building_lib.do_remove(mapblock_pos)
        if not success then
            minetest.chat_send_player(player:get_player_name(), err)
        end
    end,
    on_step = function(_, player)
        local playername = player:get_player_name()
        local pointed_mapblock_pos = get_pointed_mapblock(player)

        local building_def, origin = building_lib.get_building_at_pos(pointed_mapblock_pos)
        if not building_def then
            building_lib.clear_preview(playername)
            return
        end

        local size = building_lib.get_building_size(building_def)
        local mapblock_pos2 = vector.add(origin, vector.subtract(size, 1))

        local can_remove = building_lib.can_remove(origin)
        local texture = "building_lib_remove.png"
        if can_remove then
            texture = texture .. "^[colorize:#ff0000"
        else
            texture = texture .. "^[colorize:#ffff00"
        end

        building_lib.show_preview(texture, playername, origin, mapblock_pos2)
    end,
    on_blur = function(player)
        local playername = player:get_player_name()
        building_lib.clear_preview(playername)
    end
})

