
# Building register and placement library

## Api

```lua
-- check if something can be built there
local success, message = building_lib.can_build(mapblock_pos, playername, building_name, rotation)

-- build it there
local success, message = building_lib.build(mapblock_pos, playername, building_name, rotation, callback)

-- check if it can be removed
local success, message = building_lib.can_remove(mapblock_pos)

-- remove it
local success, message = building_lib.remove(mapblock_pos)

-- registers a placeable building
building_lib.register_building("buildings:my_building", {
	placement = "mapblock_lib",
	conditions = {
		{["*"] = { empty = true }}
	},
	-- simple catalog
	catalog = "my.zip",
	-- more catalog options
	catalog = {
		filename = "my.zip",
		-- offset in the catalog
		offset = {x=0, y=2, z=0},
		-- size
		size = {x=1, y=1, z=1},
		-- enable cache (only for 1x1x1 sized buildings, for mapgens)
		cache = true
	},
	-- optional groups attribute
	groups = {
		building = true
	},
	-- replacements
	replace = {
		["old_mod:node"] = "new_mod:node"
	},
	-- replacements as a function, can be used for biome-replacements
	replace = function(mapblock_pos, building_def)
		return {
			["old_mod:node"] = "new_mod:node"
		}
	end,
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
    can_build = function(mapblock_pos, flag_value)
		return false, msg
    end
})
```

## Conditions

Built-in conditions:
* `group=<groupname>` checks if there is already a building with the specified groupname
* `on_group=<groupname>` checks if there is a building with the specified groupname below

## Events

```lua
building_lib.register_on("placed", function(mapblock_pos, playername, building_def, rotation, size) end)
building_lib.register_on("placed_mapgen", function(mapblock_pos, building_def, rotation) end)
building_lib.register_on("removed", function(mapblock_pos, playername, building_info) end)
```

## Chat commands

* `/building_info`

# License

* Code: `MIT`
* Textures: `CC-BY-SA-3.0`