-- this part finds a grid and calls grid_start function when its found
-- you dont need to think about it
local grid_start ,grid_stateID = nil, {}
events.WORLD_TICK:register(function()
    for key, grid in pairs(world.avatarVars()) do
        if grid and grid.grid_api and grid_stateID[key] ~= grid.grid_number then
            	grid_stateID[key] = grid.grid_number
            	grid.grid_api(grid_start)
            end
    end
end,"grid finder")

-- function called when grid found
-- here you can make your own modes
function grid_start(grid)
	
	-- here you create a mode
	-- you call a grid:newMode function
	-- it takes 4 arguments: name of mode, init function, tick function, render function
	-- name of mode will have prefix that will be name you used and will have : in middle
	-- for example if your name is "my_name" and your mode is "my_amazing_mode" it will be turned into: "my_name:my_amazing_mode"
	-- you can replace functions with nil if you dont use them
	local myMode = grid.newMode("example:my_mode")
    myMode.INIT:register(function() -- init will be executed once when loading grid mode
        local size = myMode:getGridSize()
        local texture = textures:newTexture("simple_texture", size, size)
        texture:fill(0,0, size, size, vec(0, 0, 0, 0))

        myMode:setLayerCount(2)
        myMode:setLayerColor(vec(0.15, 0.15, 0.18), 2)
        myMode:setLayerTexture(texture, 1)

        myMode:setLayerDepth(0, 1) -- 0 is depth in blocks, 1 is layer
        myMode:setLayerDepth(16, 2) -- 16 is depth in blocks, 2 is layer
    end)
    
    myMode.TICK:register(function(gapirid) -- tick will be executed every tick
        local texture = textures["simple_texture"]
        local dimensions = texture:getDimensions()

        local pos = myMode:getPos()

        for i, v in pairs(world.getPlayers()) do
            local offset = (v:getPos() - pos).xz
            if offset.x >= 0 and offset.y >= 0 and offset.x < dimensions.x and offset.y < dimensions.y then
                texture:setPixel(offset.x, offset.y, vec(1, 1, 1, 1))
            end
        end

        texture:update()
    end)

    myMode.RENDER:register(function(delta, api) -- render will be executed every render
        myMode:setLayerColor(vectors.hsvToRGB(world.getTime(delta) * 0.005, 0.5, 1), 1)
    end)
end

-- you can also override grid mode like this (only you will see it):
-- avatar:store("force_grid_mode", "my_name:my_amazing_mode")

-- oh and also in init, tick or render you can get all apis using:
-- grid:getApi()