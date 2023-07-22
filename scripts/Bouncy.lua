local mac = require("libraries.macroScriptLib"):newScript("gn:bouncy")

local bouncy = 1
local threshold = 0.001
local last_velocity = vectors.vec3()

mac.TICK:register(function ()
   local velocity = player:getVelocity()
   if math.abs(last_velocity.x + velocity.x) > threshold and velocity.x == 0 then
      host:setVelocity(last_velocity:mul(-bouncy,1,1))
   end
   if math.abs(last_velocity.y + velocity.y) > threshold and velocity.y == 0 then
      host:setVelocity(last_velocity:mul(1,-bouncy,1))
   end
   if math.abs(last_velocity.z + velocity.z) > threshold and velocity.z == 0 then
      host:setVelocity(last_velocity:mul(1,1,-bouncy))
   end
   last_velocity = velocity
end)

return mac