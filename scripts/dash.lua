local mac = require("libraries.macroScriptLib"):newScript("gn:figura++")

local t = 0

local jump_key = keybinds:fromVanilla("key.sneak")
local control = keybinds:newKeybind("Control","key.keyboard.left.control")
jump_key.press = function ()
   if control:isPressed() and mac.is_active then

      pings.DOUBLE_JUMP()
   end
end

local colors = {
   vectors.hexToRGB("#d3fc7e"),
   vectors.hexToRGB("#99e65f"),
   vectors.hexToRGB("#5ac54f"),
   vectors.hexToRGB("#33984b"),
   vectors.hexToRGB("#1e6f50"),
   vectors.hexToRGB("#134c4c"),
   vectors.hexToRGB("#0c2e44"),
}
function pings.DOUBLE_JUMP()
   if player:isLoaded() then
      local pos = player:getPos()
      sounds:playSound("minecraft:entity.illusioner.mirror_move",pos)
      particles:newParticle("minecraft:flash",pos):setColor(0.5,1,0.4)
      local dir = player:getLookDir()
      local vel = player:getVelocity()
      for i = 1, 200, 1 do
         local v = vectors.vec3(math.random()-0.5,math.random()-0.5,math.random()-0.5):normalize()*math.random()*0.2 + (dir) * math.random()
         particles:newParticle("minecraft:end_rod",pos):setVelocity(v):color(colors[math.random(1,#colors)])
      end
      if host:isHost() then
         host:setVelocity(dir)
      end
      
   end
end

return mac