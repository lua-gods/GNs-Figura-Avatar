local mac = require("libraries.macroScriptLib"):newScript("gn:nodrag")
local gravity = 1.01

mac.FRAME:register(function ()
   if not player:isOnGround() and not host:isFlying() then
      host:setVelocity(player:getVelocity():mul(gravity,1,gravity):add(0,-0.1,0))
   end
end)

return mac