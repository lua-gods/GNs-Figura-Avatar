-- grid api --
local grid_api = {}
local text_to_texture = require("libraries.text2texture")
local katt_event_api = require("libraries.KattEventsAPI")

local grid_api_metatable = {
    __index = grid_api,
    __metatable = false,
}

-- layers
local layers = {}

-- grid core functions
local grid_api_and_core_functions = {}

-- grid modes
local grid_modes = {}
local grid_modes_sorted = {}

local modes_to_add = nil
local function newMode(name)
	if modes_to_add then
        local package = {
            name=name,
            INIT = katt_event_api.newEvent(),
            TICK = katt_event_api.newEvent(),
            RENDER = katt_event_api.newEvent(),
        }
		modes_to_add[#modes_to_add+1] = package
        setmetatable(package,grid_api_metatable)
        return package
	end
end

-->====================[  ]====================<--

local function sort_number(str)
    return (string.byte(str:sub(1, 1)) or 0) * 65536 + (string.byte(str:sub(2, 2)) or 0) * 256 + (string.byte(str:sub(3, 3)) or 0) + (string.byte(str:sub(4, 4)) or 0) / 256 + (string.byte(str:sub(5, 5)) or 0) / 65536
end

local function sort_grid_mode(str)
    table.insert(grid_modes_sorted,"")
	local x = sort_number(str)
    local min, max = 1, math.max(#grid_modes_sorted, 1)
    local limit = 0
    while min ~= max and limit < 128 do
		limit = limit + 1
        local half = math.floor((min + max) / 2)
        if x >= sort_number(grid_modes_sorted[half]) then
            min = half + 1
        else
            max = half
        end
    end
    table.insert(grid_modes_sorted, min, str)
    table.remove(grid_modes_sorted,#grid_modes_sorted)
end

-- create grid
local function grid_init(func)
    if type(func) == "function" then
        local current_grid_mode = grid_api_and_core_functions.current()

		local tbl = {newMode = newMode, name = "unknown"}
		modes_to_add = {}
		
    	func(tbl)
    	--local safe_api = setmetatable({}, grid_api_metatable)
    	for _, v in ipairs(modes_to_add) do
             local mode_name = tostring(v.name)
             
			if not grid_modes[mode_name] then
				sort_grid_mode(mode_name)
			end
            
			grid_modes[mode_name] = {
                INIT=v.INIT,
                TICK=v.TICK,
                RENDER=v.RENDER}

            if mode_name == current_grid_mode then
                grid_api_and_core_functions.reload_grid()
            end
		end

		mode_to_add = nil
    end
end

-->====================[  ]====================<--

avatar:store("grid_api", grid_init)

-- random number for grid
avatar:store("grid_number", math.random())

-- can edit --
local can_edit = false
function grid_api_and_core_functions.can_edit(x)
    can_edit = x
end

-- grid api functions --

-- basic info
do
    local list
    
    function grid_api:getApi()
        if not list then
            list = ""
            for i in pairs(grid_api) do
                list = list..i..", "
            end
            list = list:sub(1, -3)
        end
        return list
    end
end

function grid_api:getPos()
    return grid_api_and_core_functions.pos()
end

function grid_api:getParameters(raw)
    local str, list = grid_api_and_core_functions.parameters()
    if raw then
        return str
    else
        return list
    end
end

function grid_api:getGridSize()
    return grid_api_and_core_functions.size()
end

function grid_api:getMaxLayers()
    return #layers
end

---Sets the Texture of the layer selected.
---@param texture Texture
---@param layer integer
function grid_api:setLayerTexture(texture, layer)
    if not can_edit then return end

    local selected_layer = layers[layer or 1]
    if selected_layer then
        selected_layer.model:setPrimaryTexture("Custom", texture)
    end
end

---Sets the depth of the selected layer, if not given, default is 1.
---@param depth number
---@param layer integer
function grid_api:setLayerDepth(depth, layer)
    if not can_edit then return end

    local selected_layer = layers[layer or 1]
    if selected_layer then
        selected_layer.depth = tonumber(depth) or 1
    end
end

---Sets the Texture Dimensions.  
---GNs note: no clue what this is for
---Aurias note: its just texture zoom
---@param texture_size integer
---@param layer integer
function grid_api:setTextureSize(texture_size, layer)
    if not can_edit then return end

    local selected_layer = layers[layer or 1]
    if selected_layer then
        selected_layer.texture_size = tonumber(texture_size) or 1
    end
end

---Sets the color of the layer, the same effect as modelPart:setColor().
---@param color Vector3
---@param layer integer
function grid_api:setLayerColor(color, layer)
    if not can_edit then return end

    local selected_layer = layers[layer or 1]
    if selected_layer then
        if type(color) == "Vector3" then
            selected_layer.model:setColor(color)
        end
    end
end

---Sets the amount of layers the grid can use
---@param count integer
function grid_api:setLayerCount(count)
    if not can_edit then return end
    count = tonumber(count) or 1
    for i = 1, #layers do
        if count >= i then
            layers[i].model:setVisible()
        else
            layers[i].model:setVisible(false)
        end
    end
end

function grid_api:textToPixels(text)
    return text_to_texture:text2pixels(text)
end

-- return variables --
return grid_modes, grid_modes_sorted, layers, grid_api_and_core_functions, grid_api