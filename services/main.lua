
vanilla_model.ARMOR:setVisible(false)
vanilla_model.PLAYER:setVisible(false)
vanilla_model.HELMET_ITEM:setVisible(true)
vanilla_model.ELYTRA:setVisible(false)
models.gn:setPrimaryRenderType("CUTOUT_CULL")
avatar:store("color",vectors.hexToRGB("#008d52"))
avatar:store("version","4.3.1")
avatar:store("type","gncosmetutil2")
renderer:setShadowRadius(0)

--local panel = require("libraries.panelLib")
--
--local myPanel = panel:newPanel()
--local myPage = myPanel:newPage()
--myPage:newButton():text("I am a text, HELLO")
--myPage:newButton():text("Hello")
--myPage:newButton():text("Hello")
--myPage:newButton():text("Hello")
--myPage:newButton():text("Hello")
--myPage:newButton():text("Hello")
--myPage:newButton():text("Hello")
--myPage:newButton():text("Hello")
--myPage:newButton():text("Hello")
--myPage:newButton():text("Hello")
--myPage:newButton():text("Hello")
--myPage:newButton():text("Hello")
--myPage:newButton():text("Hello")
--myPage:newButton():text("Hello")
--myPage:newButton():text("Hello")
--myPage:newButton():text("Hello")
--local t = 0
--
--events.RENDER:register(function ()
--   t = t + 0.01
--   myPanel:setAnchor(math.cos(t)*0.5,math.sin(t)*0.2)
--   --myPanel:setAnchor(1,0.5)
--   myPanel:setPos(0,0)
--   myPage:update()
--end)
----local pos = client:getWindowSize()/client:getGuiScale()/2
----pos = pos * -1
----pos.x = pos.x + myPanel.Dimensions.x
----pos.y = pos.y - myPanel.Dimensions.y
----myPanel:setPos(pos.x,pos.y)

--local gnui = require("libraries.GNUILib")
--local myPatch = gnui:newNinepatchTexture()
--myPatch:setAnchor(0,0,1,1)
--myPatch:setRect(0,0,0,0)
--myPatch:setMargin(16,16,16,16)
--local i = 0
--events.RENDER:register(function ()
--   i = i + DELTA*0.5
--   --myPatch:setFrom(math.sin(i+124)*16,math.cos(i+351)*16)
--   --myPatch:setTo(128+math.sin(i)*16,128+math.cos(i)*16)
--   --myPatch:setMargin(16+math.sin(i)*8,16+math.cos(i)*8,16,16)
--   --myPatch:setMargin(16+math.sin(i)*8,16+math.cos(i)*8,16,16)
--end)

---@type VectorAPI|string|MatricesAPI|Action
local dog = ""

local eyes = models.gn.base.Torso.Head.HClothing.eyes

vanilla_model.HEAD:setVisible(false)

local look = vec(0,0)

local check_look_update = 0
local stare_at = nil

local last_offset = 0
local offset = 0

models.gn.base.Torso.Head:setParentType("Head")

events.TICK:register(function()
   last_offset = offset
   offset = vectors.vec2(player:getRot().x,(player:getRot().y - player:getBodyYaw()) % 360)
   if offset.y > 180 then offset.y = offset.y - 360 end
   check_look_update = check_look_update + 1
   if check_look_update > 5 then
      check_look_update = 0
      local can_look_at = {}
      local closest = 99999
      stare_at = nil
      for i, p in pairs(world.getPlayers()) do
         if p:getName() ~= player:getName() then
            local mat = matrices.mat4()
            local head_rot = player:getRot()
            mat:rotate(head_rot.x,-head_rot.y,0)
            mat:invert()

            local B = p:getPos()+vec(0,p:getEyeHeight(),0)
            local A = player:getPos()+vec(0,player:getEyeHeight(),0)
            B = B - A
            B = (mat * vec(B.x,B.y,B.z,1)).xyz
            B = vec(B.x,-B.y,B.z) -- idk why I have to do this
            
            if B.z > 0 -- is in front
            and math.abs(B.x / B.z) < 0.5 -- is within the local X position
            and math.abs(B.y / B.z) < 0.5 -- is within the local Y position 
            and closest > (math.abs(B.x / B.z) + math.abs(B.y / B.z)) then
               closest = math.abs(B.x / B.z) + math.abs(B.y / B.z)
               stare_at = p
            end
         end
      end
      if #can_look_at > 0 then
         stare_at = can_look_at[math.floor(math.random()*(#can_look_at-1)+1.5)]
      end
   end
   
   if stare_at and stare_at:isLoaded() then
      local mat = matrices.mat4()
      local head_rot = player:getRot()
      mat:rotate(head_rot.x,-head_rot.y,0)
      mat:invert()

      local A = stare_at:getPos()+vec(0,stare_at:getEyeHeight(),0)
      local B = player:getPos()+vec(0,player:getEyeHeight(),0)
      A = A - B
      A = (mat * vec(A.x,A.y,A.z,1)).xyz
      A = vec(A.x,-A.y,A.z)

      look = vec(
         math.clamp(A.x / -A.z,-1,1),
         math.clamp(A.y / -A.z,-1,1))
   else
      look = vec(
         offset.y/90,
         (player:getRot().x)/-90
      )
   end
   eyes:setPos(math.clamp(look.x,-1,1),0,0)
end)

local traillib = require("libraries.GNtrailLib"):setWorld(models.trailworld)
local newSmear = traillib:newTwoLeadTrail(textures["trailworld.gradient"]):setDuration(20):setDivergeness(0)

events.WORLD_RENDER:register(function (delta)
   if not player:isLoaded() then return end
   local sword = models.gn.base.Torso.Body.sword.Anchor1.Anchor2
   local sword_smear_toggle = sword.SmearController:getAnimPos().x
   if sword_smear_toggle < 0 then
      local sword_blade_matrix = sword:partToWorldMatrix()
      newSmear:setLeads(
         (sword_blade_matrix * vectors.vec4(0,0,0,1)).xyz,
         (sword_blade_matrix * vectors.vec4(0,0,-32,1)).xyz,
         sword_smear_toggle * 1)
   end
end)

--local arrow_trails = {}
--local cdir = vectors.vec3()
--
--events.WORLD_RENDER:register(function (delta)
--   local mat = matrices.mat4()
--   local crot = client:getCameraRot()
--   mat:rotateX(crot.x):rotateY(-crot.y)
--   cdir = mat.c1.xyz
--   local count = 0
--   for id, data in pairs(arrow_trails) do
--      count = count + 1
--      if data.health < 0 then
--         if arrow_trails[id] then
--            arrow_trails[id].trail:delete()
--            arrow_trails[id] = nil
--         end
--      elseif data.health < 40 then
--         if data.trail.leadA and data.trail.leadB then
--            data.trail:setLeads(data.trail.leadA,data.trail.leadB,0)
--         end
--      end
--      data.health = data.health - 1
--   end
--end)
--
-----@diagnostic disable-next-line: undefined-field
--events.ARROW_RENDER:register(function (delta,arrow)
--   local id = arrow:getUUID()
--   local arrow_vel = arrow:getVelocity():length()
--   local data = arrow_trails[id]
--   if data then
--      local pos = arrow:getPos(delta) 
--      data.trail:setLeads(pos-cdir,pos+cdir,arrow_vel*0.1)
--      if arrow_vel > 0.01 then
--         data.health = 60
--      end
--   else
--      if arrow_vel > 0.01  then
--         arrow_trails[id] = {health=30,trail=traillib:newTwoLeadTrail(textures["trailworld.gradient"]):setDuration(60):setDivergeness(4)}
--      end
--   end
--end)
if not H then return end
models.hud:setParentType("HUD")