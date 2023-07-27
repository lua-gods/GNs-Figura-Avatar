
local colors = {
   vectors.hexToRGB("#d3fc7e"),
   vectors.hexToRGB("#99e65f"),
   vectors.hexToRGB("#5ac54f"),
   vectors.hexToRGB("#33984b"),
   vectors.hexToRGB("#1e6f50"),
   vectors.hexToRGB("#134c4c"),
   vectors.hexToRGB("#0c2e44"),
}

function pings.GNPOOF(x,y,z)
   local pos = vectors.vec3(x,y,z)
   particles:newParticle("minecraft:flash",pos):setColor(0.5,1,0.4)
   for i = 1, 200, 1 do
      local v = vectors.vec3(math.random()-0.5,math.random()-0.5,math.random()-0.5):normalize()*math.random()*0.5
      particles:newParticle("minecraft:end_rod",pos):setVelocity(v):color(colors[math.random(1,#colors)])
   end
   sounds:playSound("minecraft:entity.illusioner.cast_spell",pos)
end

if not host:isHost() then return end

local last_gamemode = nil

events.TICK:register(function ()
   local gamemode = player:getGamemode()
   if last_gamemode and last_gamemode ~= gamemode and (gamemode == "SPECTATOR" or last_gamemode == "SPECTATOR") then
      local pos = player:getPos():add(0,1,0)
      pings.GNPOOF(pos.x,pos.y,pos.z)
   end
   last_gamemode = gamemode
end)