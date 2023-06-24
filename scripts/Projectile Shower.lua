local mac = require("libraries.macroScriptLib"):newScript("template:projectile_shower")

local config = {
   presicion = 10000,
   power = 2,
   scatter = 0.5,
   amount = 20,
   proxy = {
       "minecraft:bow","minecraft:arrow",
       "minecraft:snowball","minecraft:snowball",
       "minecraft:trident","minecraft:trident",
       "minecraft:tnt","minecraft:tnt",
       "minecraft:sheep_spawn_egg","minecraft:sheep",
       "minecraft:villager_spawn_egg","minecraft:villager",
       "minecraft:fire_charge","minecraft:fireball",
       "minecraft:sand","minecraft:falling_block",
       "minecraft:oak_boat","minecraft:boat",
   }
}

keybinds:newKeybind("GNERRS",keybinds:getVanillaKey("key.use")).press = function ()
   if mac.is_active then
      local UUID = player:getUUID()
      local proxyID = -1
      for i = 1, #config.proxy, 2 do
          if player:getHeldItem().id == config.proxy[i] then
              proxyID = i
          end
      end
      if proxyID ~= -1 then
         --sounds:playSound("entity.arrow.shoot",player:getPos())
         for i = 1, config.amount, 1 do
             local vel = player:getLookDir()*config.power + vec(math.random()-0.5,math.random()-0.5,math.random()-0.5)*config.scatter*config.power
         local stringVel = {}
         vel.x = math.floor(vel.x*config.presicion)/config.presicion
         if vel.x == math.floor(vel.x) then stringVel[1] = tostring(vel.x)..".0" else stringVel[1] = tostring(vel.x) end
         vel.y = math.floor(vel.y*config.presicion)/config.presicion
         if vel.y == math.floor(vel.y) then stringVel[2] = tostring(vel.y)..".0" else stringVel[2] = tostring(vel.y) end
         vel.z = math.floor(vel.z*config.presicion)/config.presicion
         if vel.z == math.floor(vel.z) then stringVel[3] = tostring(vel.z)..".0" else stringVel[3] = tostring(vel.z)
         end
         host:sendChatCommand("/summon "..config.proxy[proxyID+1].." ~ ~"..player:getEyeHeight().." ~ {life:1180,Motion:["..stringVel[1]..","..stringVel[2]..","..stringVel[3].."]"..",Owner:\""..UUID.."\"}")
         if config.proxy[proxyID+1] == "minecraft:tnt" then
             host:swingArm()
         end
         end
         host:swingArm()
         return true
      end
   end
end

return mac