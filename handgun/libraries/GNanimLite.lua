--[[______   __                _                 __
  / ____/ | / /___ _____ ___  (_)___ ___  ____ _/ /____  _____
 / / __/  |/ / __ `/ __ `__ \/ / __ `__ \/ __ `/ __/ _ \/ ___/
/ /_/ / /|  / /_/ / / / / / / / / / / / / /_/ / /_/  __(__  )
\____/_/ |_/\__,_/_/ /_/ /_/_/_/ /_/ /_/\__,_/\__/\___/____]]
local gnanim = {}

--- DO NOT USE THIS LIBRARY OUTSIDE THIS AVATAR AAAAAAAAAAAAAAAAAAAAAAAAAAA
--- IT DOES NOT ENHANCE ANIMATION

local delta = 0
do
   local last_system_time = client:getSystemTime()
   events.WORLD_RENDER:register(function (_)
      local system_time = client:getSystemTime()
      delta = (system_time-last_system_time)/1000
      last_system_time = system_time
   end)
end


---@class GNStateMachine
---@field last_animation Animation?
---@field current_animation Animation?
---@field default_animation Animation?
---@field transition integer
---@field transition_duration integer
local GNStateMachine = {}
GNStateMachine.__index = GNStateMachine


---Sets the current animation being played, this will smoothly transition from the last playing animation to the current based on given time
---@param animation Animation?
---@param forced boolean?
---@return GNStateMachine
function GNStateMachine:setState(animation,forced)
   self.last_animation = self.current_animation
   self.current_animation = animation
   local last = self.last_animation
   local cury = self.current_animation
   local def = self.default_animation
   if last then
      last:stop()
   else
      def:stop()
   end
   if cury then
      cury:play()
   else
      def:play()
   end
   
   return self
end

function GNStateMachine:setDefaultState(animation)
   self.default_animation = animation
   return self
end

function gnanim.newStateMachine()
   ---@type GNStateMachine
   local compose = {
      transition = 0,
      transition_duration = 1,
   }
   setmetatable(compose,GNStateMachine)
   return compose
end

return gnanim