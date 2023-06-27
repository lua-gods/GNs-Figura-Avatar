
local gnanim = require("libraries.GNanim")
local dance = gnanim:newStateMachine()

local emotes = {
   {"Scratch Head",animations.gn.scratch},
   {"Clean Arm",animations.gn.arms},
   {"Kazotskykick",animations.gn.Kazotskykick,"dance",0.5},
   {"Kazotskykick2",animations.gn.Kazotskykick2,"dance",0.5},
   {"Club Penguin",animations.gn.clubPenguin},
}
animations.gn.Kazotskykick:setSpeed(1.2)
animations.gn.Kazotskykick2:setSpeed(1.2)

local dance_music
local dance_music_id
local ppos = vectors.vec3(0,math.huge,0)

events.TICK:register(function ()
   
end)

events.TICK:register(function ()
   if player:isLoaded() then
      ppos = player:getPos()
      if dance_music then
         dance_music:pos(ppos)
      end
   end
end)

function pings.GNEMOTEID(id,music)
   if dance.animation == emotes[id][2] then
      if dance_music then
         dance_music:stop()
         dance_music_id = nil
      end
      dance:setState(nil)
   else
      dance:setState(emotes[id][2],true)
      if emotes[id][3] and emotes[id][3] ~= dance_music_id then
         local speed = 1
         if emotes[id][4] then
            speed = emotes[id][4]
         end
         if music then
            dance_music = sounds:playSound(emotes[id][3],ppos,1,speed):setLoop(true)
            dance_music_id = emotes[id][3]
         end
      else
         if dance_music and emotes[id][3] ~= dance_music_id then
            dance_music:stop()
         end
      end
   end
end

if not host:isHost() then return end
local play_music = true
local panel = require("libraries.panel")
local menu = panel:newPage()

menu:newElement("toggleButton"):setToggle(true,true):setText("Music").ON_TOGGLE:register(function (toggle)
   play_music = toggle
end)

for key, value in pairs(emotes) do
   menu:newElement("button"):setText(value[1]).ON_PRESS:register(function ()
      pings.GNEMOTEID(key,play_music)
   end)
end

menu:newElement("returnButton")
return menu