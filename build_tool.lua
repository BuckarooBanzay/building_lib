local formname = "building_lib_placer_configure"

local function get_sorted_building_list()
    local buildings = building_lib.get_buildings()
    local building_list = {}
    for name in pairs(buildings) do
        table.insert(building_list, name)
    end
    table.sort(building_list)
    return building_list
end

local function get_formspec(itemstack)
    local meta = itemstack:get_meta()

    local building_list = get_sorted_building_list()

    -- selected building name or first in list
    local selected_buildingname = meta:get_string("buildingname")
    if not selected_buildingname or selected_buildingname == "" then
        selected_buildingname = building_list[1]
    end

    local selected_building = 1
    local textlist = ""

    for i, name in pairs(building_list) do
        if selected_buildingname == name then
            selected_building = i
        end

        textlist = textlist .. name
        if i < #building_list then
            textlist = textlist .. ","
        end
    end

    return "size[10,10;]" ..
        "real_coordinates[true]" ..
        "textlist[0.5,0.5;9,8.5;buildingname;" .. textlist .. ";" .. selected_building .. "]" ..
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

            local selected = tonumber(parts[2])
            local building_list = get_sorted_building_list()
            local building_name = building_list[selected]
            if not building_name then
                return
            end

            meta:set_string("buildingname", building_name)
            meta:set_string("description", "Selected building: '" .. building_name .. "'")
            player:set_wielded_item(itemstack)
        end
    end
end)

minetest.register_tool("building_lib:place", {
    description = "building_lib placer",
    inventory_image = "building_lib_place.png^[colorize:#00ff00",
    stack_max = 1,
    range = 0,
    on_secondary_use = function(itemstack, player)
        local fs = get_formspec(itemstack)
        if fs then
            minetest.show_formspec(player:get_player_name(), formname, fs)
        else
            minetest.chat_send_player(player, "no buildings available")
        end
    end,
    on_use = function(itemstack, player)
        local playername = player:get_player_name()
        local meta = itemstack:get_meta()
        local buildingname = meta:get_string("buildingname")

        local building_def, mb_pos1, _, rotation = building_lib.get_next_buildable_position(player, buildingname)

        if building_def then
            building_lib.build(mb_pos1, playername, buildingname, rotation)
            :catch(function(err)
                minetest.chat_send_player(playername, err)
            end)
        end
    end,
    on_step = function(itemstack, player)
        local playername = player:get_player_name()
        local meta = itemstack:get_meta()
        local buildingname = meta:get_string("buildingname")

        local building_def, mb_pos1, mb_pos2, rotation = building_lib.get_next_buildable_position(player, buildingname)
        if building_def then
            building_lib.show_display(
                playername,
                "building_lib_place.png",
                "#00ff00",
                building_def,
                mb_pos1,
                mb_pos2,
                rotation
            )
        else
            building_lib.clear_display(playername)
        end
    end,
    on_deselect = function(_, player)
        local playername = player:get_player_name()
        building_lib.clear_display(playername)
    end
})
