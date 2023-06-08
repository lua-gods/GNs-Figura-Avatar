-- grid --
local grid_start ,grid_stateID = nil, {}
events.WORLD_TICK:register(function()
    for key, grid in pairs(world.avatarVars()) do
        if grid and grid.grid_api and grid_stateID[key] ~= grid.grid_number then
            	grid_stateID[key] = grid.grid_number
            	pcall(grid.grid_api, grid_start)
            end
    end
end)

-- avatar:store("force_grid_mode", "auria:autumn2")

-- grid
local lerp = math.lerp

function grid_start(grid)
    local grid_textures = {}
    local fall_id = 0

    local size

    local max_layers

    local mode_autumn = grid.newMode("auria:autumn")
    mode_autumn.INIT:register(function()
        max_layers = mode_autumn:getMaxLayers()
        
        mode_autumn:setLayerCount(max_layers)
        
        size = mode_autumn:getGridSize()

        for i = 1, max_layers do
            grid_textures[i] = textures:newTexture("grid_texutre_"..i, size, size)
            local j = (i - 1) / max_layers
            mode_autumn:setLayerColor(1 - vec(j, j, j), i)
            mode_autumn:setLayerDepth(j * 3, i)

            grid_textures[i]:fill(0, 0, size, size, vec(0, 0, 0, 1))
            grid_textures[i]:update()
        end

        mode_autumn:setLayerTexture(grid_textures[max_layers], max_layers)
    end)

    mode_autumn.TICK:register(function()
        fall_id = fall_id - 1

        grid_textures[fall_id % (max_layers - 1) + 1]:fill(0, 0, size, size, vec(0, 0, 0, 0))

        local grid_pos = mode_autumn:getPos()
        local grid_size = vec(size - 1, size -1)
        for _, v in pairs(world.getPlayers()) do
            local pos = (v:getPos() - grid_pos).xz
            if v:isOnGround() and pos.x >= 0 and pos.y >= 0 and pos.x < size and pos.y < size then
                local colors = {}
                local custom_colors = v:getVariable("colors")
                if custom_colors and type(custom_colors) == "table" then
                    colors = custom_colors
                else
                    local custom_color = v:getVariable("color")
                    if custom_color and type(custom_color) == "Vector3" then
                        colors[1] = custom_color
                    else
                        local uuid = v:getUUID()
                        colors[1] = vectors.hsvToRGB(tonumber("0x"..uuid:sub(16, 17))/255, tonumber("0x"..uuid:sub(6, 7))/510 + 0.5, 1)
                    end
                end

                local z = pos:floor() / grid_size
                z = (z.x + z.y ) / 2
                z = z * (#colors - 1) + 1
                grid_textures[fall_id % (max_layers - 1) + 1]:setPixel(pos.x, pos.y, lerp(colors[math.floor(z)], colors[math.ceil(z)], z % 1))
            end
        end


        grid_textures[fall_id % (max_layers - 1) + 1]:update()

        for i = 1, max_layers - 1 do
            mode_autumn:setLayerTexture(grid_textures[(fall_id + i - 1) % (max_layers - 1) + 1], i)
        end
    end)

    mode_autumn.RENDER:register(function(delta)
        -- print(...)
        -- local t = ((client:getSystemTime() / 1000) * 20) % 1
        local t = delta
        local settings = mode_autumn:getParameters()
        settings = settings and settings[1] or ""
        if settings == "old" or settings == "tick" then
            t = 0
        end
        for i = 1, max_layers do
            local j = (i - 1 + t - 1) / max_layers
            mode_autumn:setLayerDepth(math.max(j * 3, 0), i)
        end
    end)
end
