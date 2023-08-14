-- |==============================================================|--
-- |   _______   __                _                 __           |--
-- |  / ____/ | / /___ _____ ___  (_)___ ___  ____ _/ /____  _____|--
-- | / / __/  |/ / __ `/ __ `__ \/ / __ `__ \/ __ `/ __/ _ \/ ___/|--
-- |/ /_/ / /|  / /_/ / / / / / / / / / / / / /_/ / /_/  __(__  ) |--
-- |\____/_/ |_/\__,_/_/ /_/ /_/_/_/ /_/ /_/\__,_/\__/\___/____/  |--
-- |==============================================================|--
local gnanim = require "libraries.GNanim"

local config = {
   smear_subdiv = vec(8,8)
}

local staff = {
   state = gnanim.newStateMachine(),
   enabled = true,
   group = models.gn.base.Torso.RightArm.staff,
   smear_path = models.gn.base.Torso.RightArm.staff.tool.toolSmear,
}

local swing = false
local last = matrices.mat4()

local last_held_item = "minecraft:air"
local holding_weapon = false

local is_first_person = false
local was_first_person = false
local h = IS_HOST

local thing = staff.group:newBlock("thing")
thing:block("minecraft:dirt"):scale(0.4,0.4,0.4):pos(2.5,11,-10.5):rot(-90,0,0)

local function update_hand()
   if ((last_held_item:find("sword")) and not is_first_person) and staff.enabled then
      vanilla_model.RIGHT_ITEM:setVisible(false)
      holding_weapon = true
      staff.group:setVisible(true)
   else
      vanilla_model.RIGHT_ITEM:setVisible(true)
      staff.group:setVisible(false)
      holding_weapon = false
   end
end

update_hand()

pings.GNTOGGLESTAFF = function (toggle)
   staff.toggleStaff(toggle)
end

function staff.toggleStaff(toggle)
   staff.enabled = toggle
   staff.group:setVisible(toggle)
   update_hand()
   if player:isLoaded() then
      if toggle then
         staff.pos = player:getPos()
      end
   end
end

if h then
   events.TICK:register(function()

      
      was_first_person = is_first_person
      is_first_person = renderer:isFirstPerson()
   end)
end


events.TICK:register(function()
   if staff.enabled then
      local held_item = player:getHeldItem()
      if held_item.id ~= last_held_item then
         last_held_item = held_item.id
         update_hand()
      end
      if was_first_person ~= is_first_person then update_hand() end
      if holding_weapon then
         if player:getSwingTime() == 1 then
            --sounds:playSound("minecraft:entity.player.attack.sweep", player:getPos(), 1, 0.7)
            if not player:isOnGround() and player:getVelocity().y < 0 then
               staff.state:setState(animations.gn.tool_smash, true)
            else
               if swing then
                  staff.state:setState(animations.gn.tool_attack1, true)
               else
                  staff.state:setState(animations.gn.tool_attack2, true)
               end
               swing = not swing
            end
         end
      end
      
   end
end)

local last_frame_time = client:getSystemTime()

events.RENDER:register(function(dt)
   if staff.enabled then
      local frame_time = client:getSystemTime()
      local delta = (frame_time-last_frame_time) / 1000
      last_frame_time = frame_time
      local smear = -staff.group.tool.toolSmear:getAnimPos().x * 0.1
      if player then staff.group.tool.toolSmear:setRot(player:getRot().x * smear, 0, 0) end
      
      local current = staff.group.tool.toolSmear:partToWorldMatrix()

      local width = math.floor(smear * 20)
      if width ~= 0 then
         for x = 1, config.smear_subdiv.x, 1 do
            local true_mat = math.lerp(last, current, x / config.smear_subdiv.x)
            for i = 0, math.ceil(width * 0.26), 0.25 do
                  local pos = (true_mat * vec(0, 0, i * config.smear_subdiv.x - 24, 1)).xyz
                  local new = particles.end_rod:pos(pos):lifetime(2):scale(1):spawn()
            end
         end
      end
      last = current:copy()
   end
end)

return staff