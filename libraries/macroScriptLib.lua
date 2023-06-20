local lib = {}

local katt = require("libraries.KattEventsAPI")
local ms = {}

---@class macroScript
---@field TICK KattEvent
---@field FRAME KattEvent
---@field ENTER KattEvent
---@field EXIT KattEvent
---@field is_active boolean
---@field namespace string
local macroScript = {}
macroScript.__index = macroScript

function lib:newScript(namespace)
   config:setName("GN Macros States")
   local state = config:load(namespace)
   if not state then state = false end
   ---@type macroScript
   local compose = {
      namespace = namespace,
      is_active = state,
      TICK = katt.newEvent(),
      FRAME = katt.newEvent(),
      ENTER = katt.newEvent(),
      EXIT = katt.newEvent(),
   }
   setmetatable(compose,macroScript)
   table.insert(ms,compose)
   return compose
end

function macroScript:setActive(is_active)
   if self.is_active ~= is_active then
      self.is_active = is_active
      config:setName("GN Macros States")
      config:save(self.namespace,is_active)
      if is_active then
         self.ENTER:invoke()
      else
         self.EXIT:invoke()
      end
   end
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