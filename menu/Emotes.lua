
local gnanim = require("libraries.GNanim")
local dance = gnanim:newStateMachine()
dance.transition_duration = 0.1

local emotes = {
   {
      name="Scratch Head",
      anim=animations.gn.scratch
   },
   {
      name="Clean Arm",
      anim=animations.gn.arms
   },
   {
      name="Kazotskykick",
      anim=animations.gn.Kazotskykick,
      music={
         name="kick",
         loop=true,
         speed=1,
      }
   },
   {
      name="Kazotskykick2",
      anim=animations.gn.Kazotskykick2,
      music={
         name="kick",
         loop=true,
         speed=1,
      }
   },
   {
      name="Club Penguin",
      anim=animations.gn.clubPenguin,
      music={
         name="spog",
         loop=true,
         speed=1
      }
   },
   {
      name="Roblox Death",
      anim=animations.gn.roblox,
      music={
         name="lego",
         loop=false,
         speed=1
      }},
      {
         name="carramelDancen",
         anim=animations.gn.carramelDancen,
         music={
            name="caramel",
            loop=true,
            speed=1
         }
      },
      {
         name="Sit Down",
         anim=animations.gn.sit,
      },
      {
         name="Wave",
         anim=animations.gn.wave,
         music={
            name="pirate",
            loop=true,
            speed=1
         }
      },
      {
         name="Spin",
         anim=animations.gn.spin,
         music={
            name="wash",
            loop=true,
            speed=1
         }
      },
      
         
}
animations.gn.Kazotskykick:setSpeed(1.2)
animations.gn.carramelDancen:setSpeed(1.4)
animations.gn.Kazotskykick2:setSpeed(1.2)

local dance_music
local dance_music_id
local ppos = vectors.vec3(0,math.huge,0)

events.WORLD_TICK:register(function ()
   if player:isLoaded() then
      ppos = player:getPos()
      if dance_music then
         dance_music:pos(ppos)
      end
   end
end)

function pings.GNEMOTEID(id,music)
   local e = emotes[id]
   if dance.animation == e.anim then
      if dance_music then
         dance_music:stop()
         dance_music_id = nil
      end
      dance:setState(nil)
   else
      dance:setState(e.anim,true)
      if e.music and e.music.name and e.music.name ~= dance_music_id then
         local speed = 1
         if e.music.speed then
            speed = e.music.speed
         end
         if music then
            if dance_music then
               dance_music:stop()
            end
            dance_music = sounds:playSound(e.music.name,ppos,1,speed):setLoop(e.music.loop):setAttenuation(2)
            dance_music_id = e.music.name
         end
      else
         if dance_music and e.music and e.music.name ~= dance_music_id then
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

menu:newElement("toggleButton"):setText("Force AFK").ON_TOGGLE:register(function (toggle)
   FORCE_AFK = toggle
end)

for key, e in pairs(emotes) do
   menu:newElement("button"):setText(e.name).ON_PRESS:register(function ()
      pings.GNEMOTEID(key,play_music)
   end)
end

events.WORLD_RENDER:register(function (delta)
   local eye = models.gn.EyeHeight:getAnimPos()/16
   renderer:offsetCameraPivot(eye)
   renderer:setEyeOffset(eye)
   nameplate.ENTITY:setPos(eye)
end)

menu:newElement("returnButton")
return menu