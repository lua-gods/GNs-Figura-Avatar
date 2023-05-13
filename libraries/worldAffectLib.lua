--[[______   __                _                 __
  / ____/ | / /___ _____ ___  (_)___ ___  ____ _/ /____  _____
 / / __/  |/ / __ `/ __ `__ \/ / __ `__ \/ __ `/ __/ _ \/ ___/
/ /_/ / /|  / /_/ / / / / / / / / / / / / /_/ / /_/  __(__  )
\____/_/ |_/\__,_/_/ /_/ /_/_/_/ /_/ /_/\__,_/\__/\___/____]]
local worldAffectLib = {}
local katt = require("libraries.KattEventsAPI")

local elements = {}
local lastStates = {}

---@class WorldButton
---@field pos Vector3
---@field BLOCK_UPDATED KattEvent
local BlockObserver = {}
BlockObserver.__index = BlockObserver


events.WORLD_TICK:register(function()
   for i, e in pairs(elements) do
      if e.pos then
         local state = world.getBlockState(e.pos)
         if state.properties then
            local stringState = ""
            for key, value in pairs(state.properties) do
               stringState = stringState..key..":"..value..";"
            end
            if not lastStates[e.stringPos] or lastStates[e.stringPos] ~= stringState then
               lastStates[e.stringPos] = stringState
               e.BLOCK_UPDATED:invoke(state)
            end
         end
      end
   end
end)

--- Creates a new observer
---@param pos any
---@return WorldButton
function worldAffectLib.newObserver(pos)
   ---@type WorldButton
   local package = {
      pos = pos:copy(),
      BLOCK_UPDATED = katt.newEvent()
   }
   setmetatable(package,BlockObserver)
   table.insert(elements,package)
   return package
end

---Sets the Position this object is watching
---@param x number
---@param y number
---@param z number
---@return WorldButton
function BlockObserver:setTargetPos(x,y,z)
   self.pos = vec(x,y,z)
   self.stringPos = "x"..x.."y"..y.."z"..z
   return self
end

return worldAffectLib