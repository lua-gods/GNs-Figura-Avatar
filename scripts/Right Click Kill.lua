local mac = require("libraries.macroScriptLib"):newScript("gn:right_click_kill")

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



keybinds:newKeybind("GNKILL",keybinds:getVanillaKey("key.attack")).press = function ()
   if mac.is_active and player:isLoaded() and not player:isSneaking() then
      local target = player:getTargetedEntity()
      if target then
         local pos = target:getPos()
         pos.x = math.floor(pos.x*100)/100
         pos.y = math.floor(pos.y*100)/100
         pos.z = math.floor(pos.z*100)/100
         host:sendChatCommand("/summon lightning_bolt "..pos.x.." "..pos.y.." "..pos.z)
         host:sendChatCommand("/damage "..target:getUUID().." 999999 minecraft:out_of_world")
         host:swingArm()
         return true
      end
   end
end

return mac