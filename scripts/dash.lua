local mac = require("libraries.macroScriptLib"):newScript("gn:figura++")

local t = 0

local jump_key = keybinds:fromVanilla("key.sneak")
local control = keybinds:newKeybind("Control","key.keyboard.left.control")
jump_key.press = function ()
   if control:isPressed() and mac.is_active then
      local lol = player:getPos()
      pings.DASH(lol.x,lol.y,lol.z)
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
function pings.DASH(x,y,z)
   if player:isLoaded() then
      local pos = vectors.vec3(x,y,z)
      sounds["minecraft:entity.illusioner.mirror_move"]:setSubtitle("Player Dashes"):pitch(0.9):pos(x,y,z):play()
      particles:newParticle("minecraft:flash",pos):setColor(0.5,1,0.4)
      local dir = player:getLookDir()
      local vel = player:getVelocity()
      for i = 1, 200, 1 do
         local v = vectors.vec3(math.random()-0.5,math.random()-0.5,math.random()-0.5):normalize()*math.random()*0.2 + (dir * 3) * math.random()
         particles:newParticle("minecraft:end_rod",pos):setVelocity(v):color(colors[math.random(1,#colors)])
      end
      if host:isHost() then
         host:setVelocity(dir * 3)
      end
      
   end
end

return mac