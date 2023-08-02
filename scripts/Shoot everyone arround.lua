local mac = require("libraries.macroScriptLib"):newScript("gn:arrow_star")
local gravity = 1.01

mac.TICK:register(function ()
   local entity = world.getNearbyEntities(20,player:getPos())
   if entity.Chicken then
      local pos = (entity.Chicken:getPos() + entity.Chicken:getVelocity() - player:getPos()):sub(0,player:getEyeHeight()):normalize()
      local stringVel = {}
      local vel = pos * 10
      vel.x = math.floor(vel.x * 1000) / 1000
      if vel.x == math.floor(vel.x) then
         stringVel[1] = tostring(vel.x) .. ".0"
      else
         stringVel[1] = tostring(vel.x)
      end
      vel.y = math.floor(vel.y * 1000) / 1000
      if vel.y == math.floor(vel.y) then
         stringVel[2] = tostring(vel.y) .. ".0"
      else
         stringVel[2] = tostring(vel.y)
      end
      vel.z = math.floor(vel.z * 1000) / 1000
      if vel.z == math.floor(vel.z) then
         stringVel[3] = tostring(vel.z) .. ".0"
      else
         stringVel[3] = tostring(vel.z)
      end
      if player:getPermissionLevel() > 0 then
         for i = 1, 1, 1 do
            host:sendChatCommand("/summon arrow ~ ~" .. (player:getEyeHeight()) ..
                                 ' ~ {life:1180,pickup:2,Motion:[' .. stringVel[1] .. "," ..
                                 stringVel[2] .. "," .. stringVel[3] .. "]}")
         end
      end
   end
end)
return mac