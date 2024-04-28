
-- type -> texture-name
local textures = {
    arrow = "building_lib_arrow.png"
}

-- name -> vector
-- assuming texture points upwards originally
local rotations = {
    ["z-"] = { x=math.pi/2, y=0, z=0 },
    ["z+"] = { x=math.pi/2, y=0, z=math.pi },
    ["x+"] = { x=math.pi/2, y=0, z=math.pi/2 },
    ["x-"] = { x=math.pi/2, y=0, z=-math.pi/2 }
}

function building_lib.create_marker(type, opts)
    -- apply sane defaults
    if not textures[type] then
        type = "arrow"
    end
    opts = opts or {}
    opts.pos = opts.pos or {}
    opts.pos.x = opts.pos.x or 0
    opts.pos.y = opts.pos.y or 0
    opts.pos.z = opts.pos.z or 0
    opts.size = opts.size or 10

    if not rotations[opts.rotation] then
        opts.rotation = "z-"
    end

    return {
        texture = textures[type],
        position = opts.pos,
        rotation = rotations[opts.rotation],
        size = {x=opts.size, y=opts.size}
    }
end