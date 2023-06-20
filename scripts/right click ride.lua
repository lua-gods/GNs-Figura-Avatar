local mac = require("libraries.macroScriptLib"):newScript()

keybinds:newKeybind("GNERRS",keybinds:getVanillaKey("key.use")).press = function ()
   if mac.is_active and player:isLoaded() and not player:isSneaking() then
      local target = player:getTargetedEntity()
      if target then
         if player:getVehicle() then
            host:sendChatCommand("ride "..player:getUUID().." dismount")
         end
         host:sendChatCommand("ride "..player:getUUID().." mount "..target:getUUID())
      end
   end
end

return mac