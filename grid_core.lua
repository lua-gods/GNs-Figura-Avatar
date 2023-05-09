local config = {
    model = models.grid.Skull,
    match_block = "minecraft:iron_block",
    match_offset = vec(0, 0, 0),
    grid_render_offset = vec(0, 2, 0),
    special_signs_pos = {
        vec(1, 0, 0),
        vec(-1, 0, 0),
        vec(0, 0, 1),
        vec(0, 0, -1),
        vec(0, -1, 0),
    },
    default_texture = textures["grid.grid"],

    fallback_mode = "grid:modelist",
    margin = 0.001,
}

local grid_modes, grid_modes_sorted, layers, grid_api_and_core_functions = require "grid_api"
local mode_parameters, mode_parameters_list = "", {}

config.model:setLight(15, 15)

-- grid basic info
local grid_head_update_time = 0
local grid_pos = vec(0, 0, 0)
local grid_size = 1

local grid_mode_sign_pos = vec(0, 0, 0)

-- grid mode
local grid_current_mode_id = nil
local grid_last_mode = false
local grid_mode_state = 0 -- 0 = finding, 1 = found, 2 = error

-- grid layers
for i, v in pairs(config.model.grid:getChildren()) do
    layers[i] = {model = v}
end

local function reset_grid()
    for i = 1, #layers do
        layers[i].depth = 2
        layers[i].texture_size = 1
        layers[i].model:setPrimaryTexture("Custom", config.default_texture)
        layers[i].model:setColor(1, 1, 1)
        layers[i].model:setVisible(false)
    end
    layers[1].model:setVisible()
end

local function read_mode(str)
    str = tostring(str)
    local name, parameters = str:match("^(.*);([^;]+)$")

    return name or str, parameters or ""
end

-- call function
local function call_func(event,...)
    local current_mode = grid_modes[grid_current_mode_id]
    if current_mode and event then
        grid_api_and_core_functions.can_edit(true)
        local working, err = pcall(event.invoke,event,...,current_mode.api)
        if not working and err then
            err = '{"color":"red","text":"'..("grid_mode_error: "..grid_current_mode_id.."\n"..err)..'"}'
            printJson(err)
            grid_mode_state = 2
        end
        grid_api_and_core_functions.can_edit(false)
    end
end

-- find grid
local grid_found = false
function events.skull_render(delta, block)
    local isGrid = false

    if not grid_found and block and block.id == "minecraft:player_head" and block.properties and block.properties.rotation then
    local pos = block:getPos()

        local grid_start = 0
        for _ = 1, 32 do
            grid_start = grid_start - 1
            if world.getBlockState(pos + vec(grid_start, 0, grid_start) + config.match_offset).id ~= config.match_block then
                grid_start = grid_start + 1
                break
            end
        end
        
        local grid_end = 0
        for _ = 1, 32 do
            grid_end = grid_end + 1
            if world.getBlockState(pos + vec(grid_end, 0, grid_end) + config.match_offset).id ~= config.match_block then
                grid_end = grid_end - 1
                break
            end
        end

        if grid_start < 0 and grid_end > 0 then
            -- grid found
            grid_found = true
            
            grid_pos = pos + vec(grid_start, 0, grid_start) + config.grid_render_offset 
            config.margin = math.max(vectors.toCameraSpace(pos).z,0.01)
            grid_pos.y = grid_pos.y 
            local new_grid_size = grid_end - grid_start + 1
            if grid_size ~= new_grid_size then
                grid_size = new_grid_size
                grid_last_mode = false
            end

            grid_head_update_time = 600

            -- set model
            isGrid = true

            config.model.grid:setPos((grid_pos - pos) * 16)
            config.model.grid:setScale(grid_size, 1, grid_size)
            config.model:setRot(0, block.properties.rotation * 22.5, 0)
            --find signs
            for _, v in ipairs(config.special_signs_pos) do
                local bl = world.getBlockState(pos + v + config.match_offset)
                if bl.id:match("sign") then
                    local data = bl:getEntityData()
                    if data then
                        if data.Text1:match("grid_mode") then
                            local x, y, z = tonumber(data.Text2:match("[%d-.]+")) or 0, tonumber(data.Text3:match("[%d-.]+")) or 0, tonumber(data.Text4:match("[%d-.]+")) or 0
                            if x and y and z then
                                if data.Text2:match("~") then x = x + pos.x end
                                if data.Text3:match("~") then y = y + pos.y end
                                if data.Text4:match("~") then z = z + pos.z end
                                grid_mode_sign_pos = vec(x, y, z)
                            end
                        end
                    end
                end
            end
        end
    end

    config.model:setVisible(isGrid)
end

-- update grid
function events.world_tick()
    if grid_head_update_time == 0 then
        return
    end
    grid_head_update_time = grid_head_update_time - 1

    -- get grid mode
    local override = tostring(client:getViewer():getVariable("force_grid_mode") or "")
    local bl = world.getBlockState(grid_mode_sign_pos)
    local new_mode_to_set = ""
    local parameters_to_set = ""
    if override ~= "" then
        new_mode_to_set, parameters_to_set = read_mode(override)
    elseif bl.id:match("sign") then
        local data = bl:getEntityData()
        if data then
            new_mode_to_set, parameters_to_set = read_mode(
                (tostring(data.Text1):match('{"text":"(.*)"}') or "")..
                (tostring(data.Text2):match('{"text":"(.*)"}') or "")..
                (tostring(data.Text3):match('{"text":"(.*)"}') or "")..
                (tostring(data.Text4):match('{"text":"(.*)"}') or "")
            )
        end
    else
        new_mode_to_set = nil
    end

    if not grid_modes[new_mode_to_set] and config.fallback_mode ~= "" then
        new_mode_to_set, parameters_to_set = read_mode(config.fallback_mode)
    end 

    grid_current_mode_id = new_mode_to_set
    mode_parameters = parameters_to_set
    mode_parameters_list = {}
    for v in mode_parameters:gmatch("(.+),* *") do
        mode_parameters_list[#mode_parameters_list+1] = v
    end
    
    -- update grid when grid mode changed
    if grid_current_mode_id ~= grid_last_mode then
        grid_last_mode = grid_current_mode_id
        grid_mode_state = 0
        reset_grid()
        
    end

    local current_mode = grid_modes[grid_current_mode_id]

    -- tick function
    if grid_mode_state == 1 and current_mode then
        call_func(current_mode.TICK)
    end

    -- init function
    if grid_mode_state == 0 and current_mode then
        grid_mode_state = 1
        call_func(current_mode.INIT)
    end
end

events.WORLD_RENDER:register(function()
    grid_found = false -- reset check, triggers first before skull render
    -- render function
    if grid_modes[grid_current_mode_id] and grid_mode_state == 1 then
        call_func(grid_modes[grid_current_mode_id].RENDER)
    end
end)

-- set uv
local function setGridUV(offset, layer, i, layer_space)
    local matrix = matrices.mat3()

    local size = (1 / offset.y) * math.max(layer.depth or 0, 0) + 1

    local translate = offset.xz / -grid_size

    matrix:translate(translate)
    matrix:scale(size, size)
    matrix:translate(-translate)
    
    matrix:translate(-0.5, -0.5)
    matrix:scale(layer.texture_size or 1, layer.texture_size or 1)
    matrix:translate(0.5, 0.5)

    layer.model:setUVMatrix(matrix)

    layer.model:setPos(0, math.max(-(layer.depth or 0), 0) * 16 + (#layers - i + 1) * layer_space * ((config.margin*0.1)+1), 0)
end

-- render grid
events.WORLD_RENDER:register(function()
    if grid_head_update_time == 0 then
        return
    end

    --render grid
    local offset = client:getCameraPos() - grid_pos

    local distance = math.max(
        offset:length(),
        offset:copy():add(-grid_size, 0, 0):length(),
        offset:copy():add(0, 0, -grid_size):length(),
        offset:copy():add(-grid_size, 0, -grid_size):length()
    )

    
    local layer_space = math.clamp(distance * 0.0001, 0.001, 0.02)

    for i = 1, #layers do
        setGridUV(offset, layers[i], i, layer_space)
    end
end)

-- grid core functions for grid api
function grid_api_and_core_functions.pos()
    return grid_pos
end

function grid_api_and_core_functions.size()
    return grid_size
end

function grid_api_and_core_functions.exist()
    return grid_head_update_time >= 1
end

function grid_api_and_core_functions.current()
    return grid_current_mode_id
end

function grid_api_and_core_functions.reload_grid()
    grid_last_mode = false
end

function grid_api_and_core_functions.parameters()
    return mode_parameters, mode_parameters_list
end