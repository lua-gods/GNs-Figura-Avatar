local mac = require("libraries.macroScriptLib"):newScript("gn:forcefield")

local trailMaker = require("libraries.GNtrailLib")

local wild = 35
local dur = 20

local aura
local mats
local tro = 0
local active = false

function pings.GNFF(toggle)
   active = toggle
   if toggle then
      if tro <= 0 then
         aura = {
            trailMaker:newTwoLeadTrail():setDuration(dur):setDivergeness(0),
            trailMaker:newTwoLeadTrail():setDuration(dur):setDivergeness(0),
            trailMaker:newTwoLeadTrail():setDuration(dur):setDivergeness(0),
            trailMaker:newTwoLeadTrail():setDuration(dur):setDivergeness(0),
         }
         mats = {
            matrices.mat4(),
            matrices.mat4(),
            matrices.mat4(),
            matrices.mat4(),
         }
      end
      tro = dur
   end
end

mac.ENTER:register(function ()
   pings.GNFF(true)
end)

mac.TICK:register(function ()
   local pos = player:getPos()
   host:sendChatCommand("/execute at @s as @e[type=!player,distance=0..3] at @s run tp @s ^ ^ ^-1 facing "..pos.x.." "..pos.y.." "..pos.z)
end)

events.TICK:register(function ()
   if not active then
      tro = tro - 1
      if tro == 0 then
         for key, value in pairs(aura) do
            value:delete()
         end
         aura = nil
         mats = nil
      end
   end
   for i = 1, 5, 1 do
   if aura then
      local ppos = player:getPos():add(0,1,0)
      for id, value in pairs(aura) do
         local a = mats[id].c3.xyz*3
         mats[id]:rotate(vectors.vec3((math.random()-0.5),(math.random()-0.5),(math.random()-0.5)):normalize()*wild)
         local b = vectors.vec3(math.random()-0.5,math.random()-0.5,math.random()-0.5):normalize()*0.5
         if tro == dur then
            value:setLeads(ppos+a+b,ppos+a-b)
         else
            if aura then
               value:setLeads(ppos,ppos)
            end
         end
      end
   end
   end
end)

mac.EXIT:register(function ()
   pings.GNFF(false)
end)

return mac