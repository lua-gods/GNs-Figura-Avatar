--[[--=======================================================]=]
|   _______   __                _                 __           |
|  / ____/ | / /___ _____ ___  (_)___ ___  ____ _/ /____  _____|
| / / __/  |/ / __ `/ __ `__ \/ / __ `__ \/ __ `/ __/ _ \/ ___/|
|/ /_/ / /|  / /_/ / / / / / / / / / / / / /_/ / /_/  __(__  ) |
|\____/_/ |_/\__,_/_/ /_/ /_/_/_/ /_/ /_/\__,_/\__/\___/____/  |
[-[===========================================================]]
-->====================[ CONFIG ]====================<--
local CONFIG = {
   remote_view = true
}

local GN = {}
-->====================[ DEPENDENCIES ]====================<--
local T = require("libraries.TimerAPI")
if not T then
   print("Missing Dependency: TimerAPI")
end
-->====================[ Animation Indexing ]====================<--
--do
--   local c = 0
--   for m, value in pairs(animations:getAnimations()) do
--      for a, v in pairs(value) do
--         c = c + 1
--         local data = getmetatable(v)
--         data.id = c
--      end
--   end
--end

function GN.getAnimID(animation)
   return getmetatable(animation).id
end
-->====================[ Animation Group ]====================<--
---@alias AnimationGroupType
---| "RANDOM"
---| "ROUND_ROBBIN"
---| "ALL"

---@class AnimationGroup
---@field animations table
---@field type AnimationGroupType
---@field currentPlaying integer
local AnimationGroup = {}
AnimationGroup.__index = AnimationGroup

function AnimationGroup:addAnimations(...)
   for _, a in pairs {...} do
      table.insert(self.animations, a)
   end
   return self
end

function AnimationGroup:play()
   if #self.animations > 0 then
      if self.type == "RANDOM" then
         self.currentPlaying = math.random(1, #self.animations)
      end
      if self.type == "ROUND_ROBBIN" then
         self.currentPlaying = self.currentPlaying % #self.animations + 1
      end
      if self.animations[self.currentPlaying] then
         self.animations[self.currentPlaying]:stop()
      end
      if self.type ~= "ALL" then
         self.animations[self.currentPlaying]:play()
      else
         for key, value in pairs(self.animations) do
            value:play()
         end
      end
   end
   return self
end

function AnimationGroup:stop()
   if #self.animations > 0 then
      if self.type ~= "ALL" then
         self.animations[self.currentPlaying]:stop()
      else
         for key, value in pairs(self.animations) do
            value:stop()
         end
      end
   end
end

function AnimationGroup:speed(multiplier)
   if #self.animations > 0 then
      if self.type ~= "ALL" then
         self.animations[self.currentPlaying]:speed(multiplier)
      else
         for key, value in pairs(self.animations) do
            value:speed(multiplier)
         end
      end
   end
end

function AnimationGroup:getLoop()
   if self.animations[self.currentPlaying] then
      self.animations[self.currentPlaying]:getLoop()
   end
end

function AnimationGroup:blend(weight)
   if self.type ~= "ALL" then
      self.animations[self.currentPlaying]:blend(weight)
   else
      for key, value in pairs(self.animations) do
        value:blend(weight)
      end
   end
   return self
end

function AnimationGroup:getPlayState(weight)
   if self.animations[self.currentPlaying] then
      self.animations[self.currentPlaying]:getPlayState(weight)
   end
   return self
end

---@param type AnimationGroupType
---@return AnimationGroup
function AnimationGroup:setGroupType(type)
   self.type = type
   return self
end

---@return AnimationGroup
function GN.newAnimationGroup()
   ---@type AnimationGroup
   local package = {
      animations = {},
      type="ROUND_ROBBIN",currentPlaying=1}
   setmetatable(package,AnimationGroup)
   return package
end

-->====================[ State Machine ]====================<--
local stateMachines = {}

---@class StateMachine
---@field state Animation|AnimationGroup|nil
---@field blendTime number
---@field lastState Animation|AnimationGroup|nil
---@field override boolean
---@field timer Timer
---@field onChange function
local StateMachine = {}
StateMachine.__index = StateMachine

---Sets the current state of the State Machine.
---@param animaiton Animation|AnimationGroup|nil
---@param forced boolean|nil
function StateMachine:setState(animaiton, forced)
   if self.state ~= animaiton or forced then
      --self.state:override(self.override)
      if animaiton then
         --animaiton:override(self.override)
         --if animaiton:getLoop() == "ONCE" then
         --   local slotID = #watching+1
         --   watching[slotID] = self
         --   self.watchingSlotID = slotID
         --end
      end
      if not self.timer.paused then
         if self.lastState then
            self.lastState:stop()
         end
         if self.state then
            self.state:stop()
         end
      end
      self.lastState = self.state
      self.state = animaiton
      if self.onChange then
         self.onChange(self.state, self.lastState)
      end
      if self.state and self.state.blendTime then
         self.timer.duration = self.state.blendTime
      else
         self.timer.duration = self.blendTime
      end

      if self.blendTime ~= 0 and self.lastState ~= self.state then
         if self.state then
            self.state:stop()
            self.state:play()
         end
         self.timer:play()
      else
         if self.lastState then
            self.lastState:stop()
         end
         if self.state then
            self.state:play()
         end
      end
   end
end

---Creates a State Machine
---@return StateMachine
function GN.newStateMachine()
   ---@type StateMachine
   local package = {
      state = nil,
      lastState = nil,
      override = false,
      blendTime = 0.05,
      overallOpacity = 1,
   }
   package.timer = T:new("RENDER", package.blendTime, false, false, function()
      if package.state then
         package.state:blend(1)
      end
      if package.lastState then
         package.lastState:blend(0)
         package.lastState:stop()
      end
   end, function(progress, delta)
      if package.state then
         package.state:blend(progress)
      end
      if package.lastState then
         package.lastState:blend(1 - progress)
      end
   end)
   setmetatable(package, StateMachine)
   table.insert(stateMachines, package)
   return package
end

return GN
