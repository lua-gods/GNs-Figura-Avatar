local mac = require("libraries.macroScriptLib"):newScript()

keybinds:newKeybind("GNERRS",keybinds:getVanillaKey("key.use")).press = function ()
   if mac.is_active and player:isLoaded() then
      local target = player:getTargetedEntity()
      host:sendChatCommand("ride "..player:getUUID().." mount "..target:getUUID())
   end
end

return mac