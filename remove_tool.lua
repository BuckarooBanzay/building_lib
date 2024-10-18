
minetest.register_tool("building_lib:remove", {
    description = "building_lib remover",
    inventory_image = "building_lib_remove.png^[colorize:#ff0000",
    stack_max = 1,
    range = 0,
    on_use = function(_, player)
        local playername = player:get_player_name()

        local _, mb_pos1 = building_lib.get_next_removable_position(player)
        if not mb_pos1 then
            minetest.chat_send_player(playername, "nothing to remove found")
            return
        end

        local success, err = building_lib.remove(mb_pos1)
        if not success then
            minetest.chat_send_player(playername, err)
        end
    end,
    on_step = function(_, player)
        local playername = player:get_player_name()
        local building_def, mb_pos1, mb_pos2, rotation = building_lib.get_next_removable_position(player)
        if building_def then
            building_lib.show_display(
                playername,
                "building_lib_remove.png",
                "#ff0000",
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

