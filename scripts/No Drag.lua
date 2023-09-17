local mac = require("libraries.macroScriptLib"):newScript("gn:nodrag")
local gravity = 1.01

mac.TICK:register(function ()
   if player:isOnGround() then
      host:setDrag(true)
   else
      host:setDrag(false)
   end
end)

mac.EXIT:register(function ()
   host:setDrag(true)
end)

return mac