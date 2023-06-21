local mac = require("libraries.macroScriptLib"):newScript("gn:right_click_mount_target")

local LabelLib = require("libraries.GNLabelLib")
---@type nil|EntityAPI
local a

local selection = {}

mac.ENTER:register(function ()
   a = nil

   events.WORLD_RENDER:register(function (delta)
      if selection and a then
         local size = a:getBoundingBox():mul(0.5,1,0.5)
         local pos = a:getPos(delta)
         local aabb = { -- axis alligned bounding box
            pos:copy():add(size.x,0,size.z),
            pos:copy():add(-size.x,0,size.z),
            pos:copy():add(-size.x,0,-size.z),
            pos:copy():add(size.x,0,-size.z),
            
            pos:copy():add(size.x,size.y,size.z),
            pos:copy():add(-size.x,size.y,size.z),
            pos:copy():add(-size.x,size.y,-size.z),
            pos:copy():add(size.x,size.y,-size.z),
         }
         local screen_size = client:getScaledWindowSize()
         for key, value in pairs(aabb) do
            aabb[key] = vectors.worldToScreenSpace(value)
         end
         local ssaabb = {
            aabb[1]:copy(),
            aabb[1]:copy(),
         }
         for key, value in pairs(aabb) do
            ssaabb[1] = vectors.vec2(math.min(ssaabb[1].x,value.x),math.min(ssaabb[1].y,value.y))
            ssaabb[2] = vectors.vec2(math.max(ssaabb[2].x,value.x),math.max(ssaabb[2].y,value.y))
         end
         local m = client:getScaledWindowSize():mul(0.5,-0.5)
         ssaabb[1]:mul(m)
         ssaabb[2]:mul(m)

         selection[1]:setOffset(ssaabb[1].x,ssaabb[1].y)
         selection[2]:setOffset(ssaabb[1].x,ssaabb[2].y)
         selection[3]:setOffset(ssaabb[2].x,ssaabb[2].y)
         selection[4]:setOffset(ssaabb[2].x,ssaabb[1].y)
      end
   end,"gn:right_click_mount_target")
end)



local function updateSelection()
   selection = {
      LabelLib:newLabel():setAnchor(0,0):setText("+"),
      LabelLib:newLabel():setAnchor(0,0):setText("+"),
      LabelLib:newLabel():setAnchor(0,0):setText("+"),
      LabelLib:newLabel():setAnchor(0,0):setText("+")
   }
end

local function clearSelection()
   for key, value in pairs(selection) do
      value:delete()
   end
end

mac.EXIT:register(function ()
   events.WORLD_RENDER:remove("gn:right_click_mount_target")
   clearSelection()
end)



keybinds:newKeybind("GNERRS",keybinds:getVanillaKey("key.use")).press = function ()
   if mac.is_active and player:isLoaded() and not player:isSneaking() then
      local target = player:getTargetedEntity()
      local target_same = false
      if target and a and a:getUUID() == target:getUUID() then
         target_same = true
      end
      if target and not target_same then
         if player:getVehicle() then
            host:sendChatCommand("ride "..player:getUUID().." dismount")
         end
         if a and a:isLoaded() then
            sounds:playSound("minecraft:entity.experience_orb.pickup",client:getCameraPos(),1,2)
            if a:getVehicle() then
               host:sendChatCommand("ride "..a:getUUID().." dismount")
            end
            host:sendChatCommand("ride "..a:getUUID().." mount "..target:getUUID())
            a = nil
            clearSelection()
         else
            a = target
            sounds:playSound("minecraft:entity.experience_orb.pickup",client:getCameraPos(),1,1)
            updateSelection()
         end
         return true
      elseif a then
         local _,target_block = player:getTargetedBlock(true)
         if target_block and not target_same then
            if a:getVehicle() then
               host:sendChatCommand("ride "..a:getUUID().." dismount")
            end
            host:sendChatCommand("tp "..a:getUUID().." "..target_block.x.." "..target_block.y.." "..target_block.z)
            sounds:playSound("minecraft:entity.experience_orb.pickup",client:getCameraPos(),1,2)
         else
            sounds:playSound("minecraft:entity.experience_orb.pickup",client:getCameraPos(),1,0.8)
         end
         clearSelection()
         a = nil
         return true
      end
   end
end

return mac