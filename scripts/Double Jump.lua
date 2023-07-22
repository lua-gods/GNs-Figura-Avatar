local mac = require("libraries.macroScriptLib"):newScript("gn:figura++")

local t = 0

local jump_key = keybinds:fromVanilla("key.jump")
local was_on_ground
local multiply = 1

mac.TICK:register(function ()
   local is_on_ground = player:isOnGround()
   if jump_key:isPressed() then
      if was_on_ground ~= is_on_ground then
         if was_on_ground then
            host:setVelocity(player:getVelocity():mul(multiply,multiply,multiply))
            multiply = multiply + 1
         end
      end
   else
      multiply = 1
   end
   was_on_ground = is_on_ground
end)

return mac