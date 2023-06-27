--[[______   __                _                 __
  / ____/ | / /___ _____ ___  (_)___ ___  ____ _/ /____  _____
 / / __/  |/ / __ `/ __ `__ \/ / __ `__ \/ __ `/ __/ _ \/ ___/
/ /_/ / /|  / /_/ / / / / / / / / / / / / /_/ / /_/  __(__  )
\____/_/ |_/\__,_/_/ /_/ /_/_/_/ /_/ /_/\__,_/\__/\___/____]]

local lib = {}

local state_machines = {}

---@class AnimationStateMachine
---@field last_animation Animation
---@field animation Animation
---@field transition_time number
---@field transition_duration number
local AnimationStateMachine = {}
AnimationStateMachine.__index = AnimationStateMachine

function lib:newStateMachine()
   ---@type AnimationStateMachine
   local compose = {
      last_animation = nil,
      animation = nil,
      transition_time = 0,
      transition_duration = 0.2,
   }
   setmetatable(compose,AnimationStateMachine)
   table.insert(state_machines,compose)
   return compose
end

---Sets the state of the Animation State Machine.
---@param animation Animation?
---@param forced boolean?
function AnimationStateMachine:setState(animation,forced)
   if animation ~= self.animation or forced then
      if self.last_animation ~= self.animation or not self.last_animation or not self.animation then
         self.transition_time = 0
      end
      self.last_animation = self.animation
      if animation then
         animation:stop():play()
      end
      self.animation = animation
   end
end

local last_system_time = 0
events.WORLD_RENDER:register(function ()
   local system_time = client:getSystemTime()
   local delta = (system_time - last_system_time) * 0.001
   for key, sm in pairs(state_machines) do
      if sm.transition_time ~= sm.transition_duration then
         sm.transition_time = math.min(sm.transition_time + delta,sm.transition_duration)
         local ratio = sm.transition_time/sm.transition_duration
         if sm.last_animation then
            sm.last_animation:setBlend(1-ratio)
         end
         if sm.animation then
            sm.animation:setBlend(ratio)
         end
      else
         if sm.last_animation and sm.last_animation ~= sm.animation then
            sm.last_animation:stop()
         end
      end
   end
   last_system_time = system_time
end)

return lib