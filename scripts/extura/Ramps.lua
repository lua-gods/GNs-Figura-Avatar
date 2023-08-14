local mac = require("libraries.macroScriptLib"):newScript("gn:ramp")

local t = 0

local jump_key = keybinds:fromVanilla("key.jump")
local was_on_ground
local multiply = 1

mac.FRAME:register(function ()
   local cornerHeight = {}
   local pos = player:getPos()
   local subPos = vectors.vec3(pos.x % 1,pos.y % 1,pos.z % 1)
   for bx = -1, 0, 1 do
      for by = -1, 0, 1 do
         local highest = 0
         for x = 0, 1, 1 do
            for y = 0, 1, 1 do
               local p = pos - subPos + vectors.vec3(bx+x,0,by+y)
               local block = world.getBlockState(p)
               for key, value in pairs(block:getCollisionShape()) do
                  highest = math.max(value[2].y,highest)
               end
            end
         end
         table.insert(cornerHeight,highest + pos.y - (pos.y % 1))
      end
   end
   local height = math.lerp(
         math.lerp(cornerHeight[1],cornerHeight[2],subPos.z),
         math.lerp(cornerHeight[3],cornerHeight[4],subPos.z),
         subPos.x)
   local vel = player:getVelocity()
   local fall = vel.y
   vel.y = 0
   vel:add((cornerHeight[1] - cornerHeight[3]) * 0.04,
   (cornerHeight[1] - cornerHeight[3]) * -vel.x + (cornerHeight[3] - cornerHeight[4]) * -vel.z,
   (cornerHeight[3] - cornerHeight[4]) * 0.04)
   if height > pos.y then
      host:setPos(pos.x,height,pos.z)
      host:setVelocity(vel.x,vel.y,vel.z)
   end
end)

return mac