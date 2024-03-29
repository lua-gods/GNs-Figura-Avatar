local mac = require("libraries.macroScriptLib"):newScript("gn:double_jump")

local t = 0

local jump_key = keybinds:fromVanilla("key.jump")
local jumps = 0
jump_key.press = function ()
   if jumps > 0 and not player:isOnGround() and not player:isFlying() and mac.is_active then
      pings.DOUBLE_JUMP()
      jumps = jumps - 0
   end
end

events.TICK:register(function ()
   if player:isOnGround() then
      jumps = 1
   end
end)

function pings.DOUBLE_JUMP()
   if player:isLoaded() then
      local pos = player:getPos()
      sounds:playSound("minecraft:block.sand.break",pos)
      local vel = player:getVelocity()
      for i = 1, 20, 1 do
         particles:newParticle("minecraft:cloud",pos + vectors.vec3(math.random()-0.5,0,math.random()-0.5):normalize() * math.random())
      end
      if IS_HOST then
         host:setVelocity((vel.x_z * 1.25):add(0,0.5,0))
      end
      
   end
end

return mac