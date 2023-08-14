if not IS_HOST then return end
local active = false

local inputs = {
   "A",
   "W",
   "S",
   "E",
   "D",
   "F",
   "T",
   "G",
   "Y",
   "H",
   "U",
   "J",
   "K",
}
local trailMaker = require("libraries.GNtrailLib")
local aura = {}

local sound = nil
local pitch = 1
local goal_pitch = 1
local volume = 0
local request_stack_count = 0
local request_stack = {}
local goal_volume = 0

local wait = 0
local perc_time = 0

function pings.GNZAPSTATUS(toggle)
   perc_time = 0
   active = toggle
   if active then
      if sound then
         sound:stop()
      end
      sound = sounds:playSound("saw",vectors.vec3(0,0,0),0,1,true)
      for i = 1, 10, 1 do
         table.insert(aura,trailMaker:newTwoLeadTrail():setDuration(5):setDivergeness(0))
      end
   else
      for key, value in pairs(aura) do
         value:delete()
      end
      if sound then
         sound:stop()
      end
      aura = {}
      request_stack = {}
      request_stack_count = 0
      goal_volume = 0
   end
end

function pings.GNZAPINPUT(key)
   local p = 2^(key/12) * 0.5
   goal_pitch = p
   goal_volume = 1
   request_stack[key] = goal_pitch
   request_stack_count = request_stack_count + 1
end

function pings.GNZAPINPUTOUT(key)
   request_stack[key] = nil
   request_stack_count = request_stack_count - 1
   if request_stack_count == 0 then
      goal_volume = 0
   end
end

events.WORLD_RENDER:register(function ()
   if not player:isLoaded() then return end
   volume = math.lerp(volume,goal_volume,0.8)
   if volume < 0.05 then
      pitch = goal_pitch
   else
      pitch = math.lerp(pitch,goal_pitch,0.3)
   end
   if active then
      sound:pos(player:getPos()):pitch(pitch):volume(volume)
   end
   if request_stack_count ~= 0 then
      goal_pitch = 0
      for key, value in pairs(request_stack) do
         goal_pitch = math.max(goal_pitch,value)
      end
   end
   local compose = ""
   for key, value in pairs(request_stack) do
      compose = compose .. key .. ":" .. value .. "\\n" .. " || "
   end

   if aura then
      local ppos = player:getPos():add(0,1,0)
      for key, value in pairs(aura) do
         local a = vectors.vec3(math.random()-0.5,(math.random()-0.5)*2,math.random()-0.5)
         local b = vectors.vec3(math.random()-0.5,math.random()-0.5,math.random()-0.5):normalize()*(pitch - 0.5) * 3 * volume
         value:setLeads(ppos+a+b,ppos+a-b)
      end
   end
end)

local keys = {}
for key, value in pairs(inputs) do
   keys[key] = {keybinds:newKeybind("sex "..value,"key.keyboard."..string.lower(value)):onPress(function ()
      if active and player:isLoaded() then
         pings.GNZAPINPUT(key)
         return true
      end
   end):onRelease(function ()
      if active and player:isLoaded()  then
         pings.GNZAPINPUTOUT(key)
      end
   end)}
   
end
if not IS_HOST then return end
return function (page)
   page:newElement("toggleButton"):setText("Tesla Coil").ON_TOGGLE:register(function (toggle)
      pings.GNZAPSTATUS(toggle)
   end)
end