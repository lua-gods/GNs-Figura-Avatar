-- |==============================================================|--
-- |   _______   __                _                 __           |--
-- |  / ____/ | / /___ _____ ___  (_)___ ___  ____ _/ /____  _____|--
-- | / / __/  |/ / __ `/ __ `__ \/ / __ `__ \/ __ `/ __/ _ \/ ___/|--
-- |/ /_/ / /|  / /_/ / / / / / / / / / / / / /_/ / /_/  __(__  ) |--
-- |\____/_/ |_/\__,_/_/ /_/ /_/_/_/ /_/ /_/\__,_/\__/\___/____/  |--
-- |==============================================================|--
local CONFIG = {
   smear = {
      gradient = {"0C2E44", "134C4C", "1E6F50", "33984B", "5AC54F", "99E65F", "D3FC7E", "FFFFFF"}
   },
   path = models.gn.base.Torso.Body.sword
}
local gnanim = require "libraries.GNanim"

for key, value in pairs(CONFIG.smear.gradient) do
   CONFIG.smear.gradient[key] = vectors.hexToRGB(value)
end

local sword = {
   state = gnanim:newStateMachine(),
   enabled = true,
}

animations.sword.attack1:speed(1.2)
animations.sword.attack2:speed(1.2)
animations.sword.attack_down:speed(1.2)
CONFIG.path:setPivot(0,22,0)
sword.state:setState(animations.sword.idle)
if player:isLoaded() then
   sword.pos = player:getPos()
end

local swing = false

local last_held_item = "minecraft:air"
local is_holding_sword = false

local is_first_person = false
local was_first_person = false
local h = host:isHost()


local function update_hand()
   if ((last_held_item:find("sword")) and not is_first_person) and sword.enabled then
      vanilla_model.RIGHT_ITEM:setVisible(false)
      is_holding_sword = true
   else
      vanilla_model.RIGHT_ITEM:setVisible(true)
      is_holding_sword = false
   end
end

pings.GNTOGGLESWORD = function (toggle)
   sword.toggleSword(toggle)
end

function sword.toggleSword(toggle)
   sword.enabled = toggle
   CONFIG.path:setVisible(toggle)
   update_hand()
   if player:isLoaded() then
      if toggle then
         sword.pos = player:getPos()
      end
   end
end

events.RENDER:register(function (delta, context)
   if context == "RENDER" then
      is_first_person = false
   elseif context == "FIRST_PERSON" then
      is_first_person = true
   end
end)

events.TICK:register(function()
   if sword.enabled and player:isLoaded() then
      local held_item = player:getHeldItem()
      if held_item.id ~= last_held_item then
         last_held_item = held_item.id
         update_hand()
      end
      if was_first_person ~= is_first_person then update_hand() was_first_person = is_first_person end
      if is_holding_sword then
         if player:getSwingTime() == 1 then
            sounds:playSound("swing", player:getPos(), 0.1, math.random() * 0.1 + 0.8)
            if not player:isOnGround() and player:getVelocity().y < 0 then
               sword.state:setState(animations.sword.attack_down, true)
            else
               if swing then
                  sword.state:setState(animations.sword.attack1, true)
               else
                  sword.state:setState(animations.sword.attack2, true)
               end
               swing = not swing
            end
         end
      end
      
   end
end)

local last_frame_time = client:getSystemTime()

--events.RENDER:register(function(dt)
--   if sword.enabled then
--      local frame_time = client:getSystemTime()
--      local delta = (frame_time-last_frame_time) / 1000
--      last_frame_time = frame_time
--      local smear = -CONFIG.path.Anchor1.Anchor2.SmearController:getAnimPos().x
--      if player then CONFIG.path.Anchor1.Anchor2:setRot(player:getRot().x * smear, 0, 0) end
--      
--      local current = CONFIG.path.Anchor1.Anchor2:partToWorldMatrix()
--
--      local width = math.floor(smear * 20)
--      if width ~= 0 then
--         for x = 1, 4, 1 do
--            local true_mat = math.lerp(last, current, x / 4)
--            for i = 0, math.ceil(width * 0.26), 1 do
--                  local lifetime = 3 + x * 0.2 + math.random() * 0.5
--                  local pos = (true_mat * vec(0, 0, i * 4 - 24, 1)).xyz
--                  local new = particles.end_rod:pos(pos):lifetime(lifetime):scale(2):spawn()
--                  --table.insert(smear_particles, new)
--                  --table.insert(smear_particles_age, lifetime + 2)
--            end
--         end
--      end
--      --smear_update_delay = smear_update_delay - 1
--      --if smear_update_delay < 0 then
--      --   smear_update_delay = 1
--      --   for key, value in pairs(smear_particles) do
--      --      if not value:isAlive() then
--      --         table.remove(smear_particles, key)
--      --         table.remove(smear_particles_age, key)
--      --      else
--      --         smear_particles_age[key] = smear_particles_age[key] - delta * 40
--      --         value:color(CONFIG.smear.gradient[math.floor(math.clamp(smear_particles_age[key] * 2, 1, 10))])
--      --      end
--      --   end
--      --end
--      last = current:copy()
--   end
--end)

return sword