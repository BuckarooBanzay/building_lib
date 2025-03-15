std = "minetest+min"
max_line_length = 200

globals = {
	"building_lib"
}

read_globals = {
	"unpack",
	minetest = {
		fields = {
			"get_perlin_map"
		}
	},

	-- mods
	"mapblock_lib", "mtt", "Promise", "isogen"
}
