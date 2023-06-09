-- grid loader --
local grid_start, grid_stateID = nil, {}
events.WORLD_TICK:register(function()
    for key, grid in pairs(world.avatarVars()) do
        if grid and grid.grid_api and grid_stateID[key] ~= grid.grid_number then
            grid_stateID[key] = grid.grid_number
            pcall(grid.grid_api, grid_start)
        end
    end
end)

-- avatar:store("force_grid_mode", "demo:sierpinski_triangle")
-- config
local config = {
    size = 2 ^ 11,
    scale = 0.95,
    limit = 4,
    speed = 25,
    -- color1 = vec(0, 0, 0, 1),
    color1 = vec(66, 23, 87, 255) / 255,
    -- color2 = vec(1, 1, 1, 1),
    color2 = vec(255, 140, 170, 255) / 255
}
-- functions
local sqrt3 = math.sqrt(3)
local getH = sqrt3 * 0.5
local getH2 = sqrt3 * 0.25
local function draw_triangle(texture, color, x, y, s)
    local h = s * getH
    local h2 = h * 0.5
    local s2 = s * 0.5
    local h3 = h - 1
    for i = 0, h3 do
        local k = i / h3
        texture:fill(x - s2 * k, y - h2 + i, s * k, 1, color)
    end
end
local function draw_triangle2(texture, color, x, y, s)
    local h = s * getH
    local h2 = h * 0.5
    local s2 = s * 0.5
    local h3 = h - 1
    for i = 0, h3 do
        local k = 1 - i / h3
        texture:fill(x - s2 * k, y - h2 + i, s * k, 1, color)
    end
end
-- grid mode
function grid_start(grid)
    local triangle_texture = nil
    local triangles = {}

    local triangle = grid.newMode("demo:sierpinski_triangle")
    triangle.INIT:register(function()
        triangle_texture = textures:newTexture("sierpinski_triangle", config.size, config.size)
        triangle:setLayerCount(1)
        triangle:setLayerTexture(triangle_texture)
        triangle:setLayerDepth(0)

        triangles = {vec(config.size * 0.5, config.size * 0.5, config.size * 0.5 * config.scale)}

        triangle_texture:fill(0, 0, config.size, config.size, config.color1)
        draw_triangle(triangle_texture, config.color2, 1024, 1024, 2048 * config.scale)
        triangle_texture:update()
    end)

    triangle.TICK:register(function()
        if #triangles == 0 then
            return
        end
        local limit = config.limit
        for _ = 1, config.speed do
            if #triangles == 0 then
                triangle_texture:update()
                return
            end
            local t = triangles[1]
            table.remove(triangles, 1)
            local a = t.z * getH2
            draw_triangle2(triangle_texture, config.color1, t.x, t.y + a, t.z)
            if t.z > limit then
                table.insert(triangles, vec(t.x + t.z * 0.5, t.y + a, t.z * 0.5))
                table.insert(triangles, vec(t.x - t.z * 0.5, t.y + a, t.z * 0.5))
                table.insert(triangles, vec(t.x, t.y - a, t.z * 0.5))
            end
        end
        triangle_texture:update()
    end)
end
