--[[______   __                _                 __
  / ____/ | / /___ _____ ___  (_)___ ___  ____ _/ /____  _____
 / / __/  |/ / __ `/ __ `__ \/ / __ `__ \/ __ `/ __/ _ \/ ___/
/ /_/ / /|  / /_/ / / / / / / / / / / / / /_/ / /_/  __(__  )
\____/_/ |_/\__,_/_/ /_/ /_/_/_/ /_/ /_/\__,_/\__/\___/____]] 
local config = require("handgun.config")
local GNanim = require("handgun.libraries.GNanimLite")
local active = true

local gunST = GNanim.newStateMachine()
gunST:setDefaultState(config.animation_idle)

config.model_head:setPos(0, -6, -4)
local ammo = config.ammo_max

for key, value in pairs(config.model_flash) do value:setPrimaryRenderType("EMISSIVE") end
for _, value in pairs(config.model_arms) do
   value:setPrimaryTexture("SKIN")
   for _, v in pairs(value:getChildren()) do
      if v:getType() == "GROUP" then v:setPrimaryTexture("CUSTOM", textures["handgun.handgun"]) end
   end
end

local function uuidToIntegerArray(uuid)
   local function twosComplement(val, numBits)
      local maxVal = 2 ^ (numBits - 1)
      if val >= maxVal then val = val - 2 * maxVal end
      return val
   end
   local integerArray = {}
   uuid = uuid:gsub("-", "")
   for i = 1, 32, 8 do
      local hexGroup = uuid:sub(i, i + 7)
      local intValue = tonumber(hexGroup, 16)
      intValue = twosComplement(intValue, 32) -- Convert to signed integer
      table.insert(integerArray, intValue)
   end
   return integerArray
end

local shoot = keybinds:newKeybind("Shoot", "key.mouse.left")

shoot.press = function()
   if not active then return end
   if ammo <= 0 then return true end
   local stringVel = {}
   local vel = player:getLookDir() * config.projectile_power
   vel.x = math.floor(vel.x * config.projectile_precision) / config.projectile_precision
   if vel.x == math.floor(vel.x) then
      stringVel[1] = tostring(vel.x) .. ".0"
   else
      stringVel[1] = tostring(vel.x)
   end
   vel.y = math.floor(vel.y * config.projectile_precision) / config.projectile_precision
   if vel.y == math.floor(vel.y) then
      stringVel[2] = tostring(vel.y) .. ".0"
   else
      stringVel[2] = tostring(vel.y)
   end
   vel.z = math.floor(vel.z * config.projectile_precision) / config.projectile_precision
   if vel.z == math.floor(vel.z) then
      stringVel[3] = tostring(vel.z) .. ".0"
   else
      stringVel[3] = tostring(vel.z)
   end
   local uuid = uuidToIntegerArray(player:getUUID())
   if player:getPermissionLevel() > 0 then
      for i = 1, 1, 1 do
         host:sendChatCommand("/summon arrow ~ ~" .. (player:getEyeHeight()) ..
                              ' ~ {life:1180,pickup:2,Motion:[' .. stringVel[1] .. "," ..
                              stringVel[2] .. "," .. stringVel[3] .. "],Owner:[I;" .. uuid[1] .. "," ..
                              uuid[2] .. "," .. uuid[3] .. "," .. uuid[4] .. "],Silent:1}")
      end
   end
   pings.SHOOT()
   ammo = ammo - 1
   return true
end

function PLAYSOUND(sound, pitch)
   if player:isLoaded() then
      if not pitch then pitch = 1 end
      sounds:playSound(sound, player:getPos(), 1, pitch)
   end
end
-- >====================[ HUD ]====================<--
local labelLib = require("handgun.libraries.GNLabelLib")
local AvailableAmmo1
local backdropAmmo1
if host:isHost() then
   AvailableAmmo1 = labelLib:newLabel():setZDepth(-1):setOffset(0, 0):setAnchor(-1, 1)
                       :setScale(2, 2):setOutlineColorRGB(0.4, 0.4, 0.25):setColorRGB(1, 1, 0.5)
   backdropAmmo1 = labelLib:newLabel():setOffset(0, 0):setAnchor(-1, 1):setScale(2, 2)
                      :setOutlineColorRGB(0.25, 0.25, 0.25):setColorRGB(0.5, 0.5, 0.5)
end
local sacle = 0.05
models.handgun.model.hed.nec.RA.UI:setScale(sacle, sacle, sacle):setLight(15, 15)
local function updateUI()
   if host:isHost() then
      local a = ("|"):rep((ammo))
      backdropAmmo1:setText(("|"):rep(config.ammo_max - ammo)):setOffset(client.getTextWidth(a) * 2,
                                                                         0)
      AvailableAmmo1:setText(a)
   end
end
updateUI()

function pings.RELOAD() gunST:setState(config.animation_reload, true) end
function pings.SHOOT()
   
   gunST:setState(config.animation_shoot, true)
   updateUI()
end
-- >====================[ Rendering ]====================<--

local lswing = vectors.vec2()
local swing = vectors.vec2()
local swing_vel = vectors.vec2()

local lrot = vectors.vec2()
events.TICK:register(function()
   local rot = player:getRot()
   local accel = rot - lrot
   lswing = swing:copy()
   swing_vel = swing_vel * 0.2 + accel * 0.1 - swing * 0.9
   swing = swing + swing_vel
   lrot = rot

end)
local is_fps = false
events.WORLD_RENDER:register(function(delta) -- FIrst person renderer
   if is_fps and player:isLoaded() then
      config.model_base:setParentType("WORLD"):setPos(client:getCameraPos() * 16)
      config.model_head:setRot(0, 0, 0)
      local true_swing = math.lerp(lswing, swing, delta)
      local rot = player:getRot():sub(true_swing.x, true_swing.y)
      config.model_neck:setPos(0, 0, 0)
      config.model_base:setRot(-rot.x, 180 - rot.y, 0)
   end
end)

events.RENDER:register(function(delta, context) -- other view renderer
   is_fps = context == "FIRST_PERSON"
   if player:isLoaded() then
      if context ~= "FIRST_PERSON" and context ~= "OTHER" then
         local true_swing = -math.lerp(lswing, swing, delta)
         local rot = player:getRot(delta):add(true_swing.x, true_swing.y)
         rot.y = (rot.y - player:getBodyYaw(delta) + 180) % 360 - 180
         config.model_base:setParentType("NONE"):setPos(0, 28+models.gn.base:getAnimPos().y+models.gn.base.Torso:getAnimPos().y, 4):setRot(0, 0, 0)
         config.model_head:setRot(-rot.x, -rot.y, 0)
         if player:isSneaking() then
            config.model_neck:setPos(0, -4, -4)
         else
            config.model_neck:setPos(0, 0, -4)
         end
      else
         renderer:offsetCameraRot(config.model_camera:getAnimRot():mul(-1, 1, 1) * 0.2)
      end
   end
end)

local was_holding_something
events.RENDER:register(function()
   if player:isLoaded() then
      HOLDING_GUN = player:getHeldItem().id == "minecraft:crossbow"
      if was_holding_something ~= HOLDING_GUN then
         if not HOLDING_GUN then
            active = false
            config.model_base:setVisible(false)
            config.animation_intro:stop() 
         else
            models.gn.base.Torso.RightArm.RightItemPivot:setVisible(true)
            active = true
            gunST:setState(config.animation_intro, true)
            config.model_base:setVisible(true)
         end
      end
      vanilla_model.RIGHT_ITEM:setVisible(not HOLDING_GUN)
      was_holding_something = HOLDING_GUN
   end
end)

---@param animation Animation
local function isPaused(animation)
   return animation:getTime() == animation:getLength() or not animation:isPlaying()
end

if host:isHost() then
   local is_reloading = false
   keybinds:newKeybind("Reload", "key.mouse.middle").press = function()
      if not is_reloading and HOLDING_GUN then ammo = 0 end
   end
   events.TICK:register(function()
      if ammo <= 0 then
         if is_reloading then
            if isPaused(config.animation_reload) then
               ammo = config.ammo_max
               updateUI()
               is_reloading = false
            end
         else
            if isPaused(config.animation_shoot) then
               is_reloading = true
               pings.RELOAD()
            end
         end
      end
   end)
end

config.model_arrow:setPrimaryRenderType("EMISSIVE_SOLID")

local delta = 0
local last = client:getSystemTime()
events.WORLD_RENDER:register(function(_)
   local curr = client:getSystemTime()
   delta = (curr - last) / 1000
   last = curr
end)

events.ARROW_RENDER:register(function(_, arrow)
   config.model_arrow:setScale(1, 1, arrow:getVelocity():length() * delta * 10 * 32)
end)
