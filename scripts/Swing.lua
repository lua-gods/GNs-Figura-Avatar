local mac = require("libraries.macroScriptLib"):newScript("gn:spoodir")
local linelib = require("libraries.GNLineLib")

local line
local was_active = false
local active = false
local hook = vectors.vec3()
local length = 0

local input = keybinds:fromVanilla("key.use")
input.press = function ()
   if mac.is_active then
      local eye = player:getPos():add(0,player:getEyeHeight())
      local data = world:linetraceBlock(true,eye,eye + player:getLookDir() * 200)
      if data then
         pings.hook(data.position,(player:getPos():add(0,1,0)-data.position):length())
      end
   end
end

input.release = function ()
   pings.hook()
end

function pings.hook(pos,len)
   if len then
      length = len - 2
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
   events.TICK:register(function (delta)
      if active then
         local pos = player:getPos(delta)
         local dir = (pos-hook)
         local correct = hook+dir:normalized()*math.min(length,dir:length())
         local vel = player:getVelocity()
         if dir:length() > length then
            host:setVelocity((correct - pos) * 0.1 + vel)
         end
      end
   end)
end

return mac