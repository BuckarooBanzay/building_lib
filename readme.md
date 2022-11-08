
# Building register and placement library

## Api

```lua
-- check if something can be built there
local success, message = building_lib.can_build(mapblock_pos, playername, building_name, rotation)

-- build it there
local success, message = building_lib.do_build(mapblock_pos, playername, building_name, rotation, callback)

-- registers a placeable building
building_lib.register_building("buildings:my_building", {
	placement = "default",
	conditions = {
		-- OR
		on_flat_surface = true,
		on_slope = true,
		-- alternatively: OR and AND combined
		{ on_slope = true, on_biome = "grass" },
		{ on_flat_surface = true, on_biome = "water" },
	},
	catalog = "my.zip",
	-- optional groups attribute
	groups = {
		building = true
	}
})

-- registers a placement type (connected, simple, etc)
building_lib.register_placement("simple", {
	-- place the building
	place = function(self, mapblock_pos, building_def, rotation, callback) end,
	-- return the size of the building if it would be placed there
	get_size = function(self, mapblock_pos, building_def, rotation)
		return { x=1, y=1, z=1 }
	end,
	-- validation function for startup-checks (optional)
	validate = function(self, building_def)
		return success, err_msg
	end
})

-- registers a condition that checks for certain world conditions
building_lib.register_condition("on_flat_surface", {
    can_build = function(mapblock_pos, building_def, flag_value)
		return false, msg
    end
})
```

## Chat commands

* `/building_info`

# License

* Code: `MIT`
* Textures: `CC-BY-SA-3.0`