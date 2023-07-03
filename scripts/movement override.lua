local mac = require("libraries.macroScriptLib"):newScript("gn:movement_override")
local lpos
local pos
local vel = vectors.vec3()
local speed = 0.1

local trailMaker = require("libraries.GNtrailLib")

local Input = {
   forward = keybinds:newKeybind("mo Move Forward","key.keyboard.w"),
   backward = keybinds:newKeybind("mo Move Backward","key.keyboard.s"),
   left = keybinds:newKeybind("mo Move Right","key.keyboard.a"),
   right = keybinds:newKeybind("mo Move Left","key.keyboard.d"),
   up = keybinds:newKeybind("mo Move Up","key.keyboard.space"),
   down = keybinds:newKeybind("mo Move Down","key.keyboard.left.shift")
}

local aura

function pings.GNAURA(toggle)
   if toggle then
      aura = {
         trailMaker:newTwoLeadTrail():setDuration(10):setDivergeness(0),
         trailMaker:newTwoLeadTrail():setDuration(10):setDivergeness(0),
         trailMaker:newTwoLeadTrail():setDuration(10):setDivergeness(0),
      }
   else
      if aura then
         for key, value in pairs(aura) do
            value:delete()
         end
      end
   end
end

mac.ENTER:register(function ()
   pings.GNAURA(true)
   pos = player:getPos()
   lpos = pos:copy()
   vel = player:getVelocity()
end)

mac.TICK:register(function ()
   lpos = pos:copy()
   pos = pos + vel
   vel = vel * 0.8
   host:sendChatCommand("/tp @s "..pos.x.." "..pos.y.." "..pos.z)
   host:sendChatCommand("/gamemode creative")

   local mat = matrices.mat4():rotateY(-player:getRot().y)
   if Input.forward:isPressed() then
      vel = vel + mat.c3.xyz * speed
   end
   if Input.backward:isPressed() then
      vel = vel - mat.c3.xyz * speed
   end
   if Input.left:isPressed() then
      vel = vel + mat.c1.xyz * speed
   end
   if Input.right:isPressed() then
      vel = vel - mat.c1.xyz * speed
   end
   if Input.up:isPressed() then
      vel = vel + mat.c2.xyz * speed
   end
   if Input.down:isPressed() then
      vel = vel - mat.c2.xyz * speed
   end
end)

mac.FRAME:register(function (delta)
   if player:isLoaded() then
      renderer:setCameraPivot(math.lerp(lpos,pos,delta):add(0,player:getEyeHeight()))
   end
   if aura then
      local ppos = player:getPos():add(0,1,0)
      for key, value in pairs(aura) do
         local a = vectors.vec3(math.random()-0.5,(math.random()-0.5)*2,math.random()-0.5)
         local b = vectors.vec3(math.random()-0.5,math.random()-0.5,math.random()-0.5):normalize()*0.25
         value:setLeads(ppos+a+b,ppos+a-b)
      end
   end
end)


mac.EXIT:register(function ()
   for key, value in pairs(aura) do
      value:delete()
   end
   aura = nil
   renderer:setCameraPivot()
   pings.GNAURA(false)
end)

return mac