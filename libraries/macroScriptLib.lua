local lib = {}

local katt = require("libraries.KattEventsAPI")
local ms = {}

---@class macroScript
---@field TICK KattEvent
---@field FRAME KattEvent
---@field ENTER KattEvent
---@field EXIT KattEvent
---@field is_active boolean
local macroScript = {}
macroScript.__index = macroScript

function lib:newScript()
   ---@type macroScript
   local compose = {
      is_active = false,
      TICK = katt.newEvent(),
      FRAME = katt.newEvent(),
      ENTER = katt.newEvent(),
      EXIT = katt.newEvent(),
   }
   setmetatable(compose,macroScript)
   table.insert(ms,compose)
   return compose
end

events.WORLD_TICK:register(function ()
   for _, s in pairs(ms) do
      if s.is_active then
         s.TICK:invoke()
      end
   end
end)

events.WORLD_RENDER:register(function (dt)
   for _, s in pairs(ms) do
      if s.is_active then
         s.FRAME:invoke(dt)
      end
   end
end)


return lib