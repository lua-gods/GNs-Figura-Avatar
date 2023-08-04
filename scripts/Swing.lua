local mac = require("libraries.macroScriptLib"):newScript("gn:spoodir")
local linelib = require("libraries.GNLineLib")
local lableLib = require("libraries.GNLabelLib")

local line
local was_active = false
local active = false
local hook = vectors.vec3()
local length = 0

local cursor

local ray_count = 200
local search_dirs = {vectors.vec3(0,0,1)}

for i = 2, ray_count, 1 do
   local t = i / ray_count / 8
   local inclination = math.acos(1 - 2 * t)
   local azimuth = 2 * math.pi * 0.618033 * i
  table.insert(search_dirs,vectors.vec3(
   math.sin(inclination) * math.sin(azimuth),
   -math.cos(inclination),
   math.sin(inclination) * math.cos(azimuth)
))
end

local input = keybinds:fromVanilla("key.use")
input.press = function ()
   if mac.is_active then
      pings.hook(cursor,(player:getPos():add(0,1,0)-cursor):length())
   end
end

mac.TICK:register(function ()
   if mac.is_active and not input:isPressed() then
      local eye = player:getPos():add(0,player:getEyeHeight())
      local rot = player:getRot()
      local mat = matrices.mat4():rotate(rot.x-90,-rot.y,0)
      cursor = nil;
      for i = 1, #search_dirs, 1 do
         local dir = (mat * search_dirs[i]:augmented()).xyz
         local data = world:linetraceBlock(true,eye,eye + dir * 50)
         --linelib:newLine():from(player:getPos()):to(player:getPos()+dir):color(i/#search_dirs*8,0,0)
         if data then
            cursor = data.position
            return
         end
      end
   end
end)

input.release = function ()
   pings.hook()
end

function pings.hook(pos,len)
   if len then
      length = len - 4
   else
      length = nil
   end
   if pos then
      hook = pos
      active = true
   else
      hook = nil
      active = false
   end
   if was_active ~= active then
      if active then
         line = linelib:newLine()
      else
         line:delete()
      end
      was_active = active
   end
end

events.WORLD_RENDER:register(function (delta)
   if player:isLoaded() and active then
      line:from(player:getPos(delta):add(0,1,0)):to(hook)
   end
end)

if host:isHost() then
   events.TICK:register(function ()
      if cursor then
         renderer:crosshairOffset(vectors.worldToScreenSpace(cursor).xy * client:getScaledWindowSize() / 2)
      else
         renderer:crosshairOffset()
      end
      if active then
         local pos = player:getPos()
         local dir = (pos-hook)
         local correct = (hook+dir:normalized()*math.min(length,dir:length())):sub(0,0.1,0)
         local vel = player:getVelocity()
         if dir:length() > length then
            host:setVelocity((correct - pos) * 0.1 + vel)
         end
      end
   end)
end

mac.EXIT:register(function ()
   renderer:crosshairOffset()
end)

return mac