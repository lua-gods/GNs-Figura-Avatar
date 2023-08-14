if not (TRUST_LEVEL > 1) then
   models.plushie:setVisible(true) return
end
local parts = {
   base = models.gn.base,
   head = models.gn.base.Torso.Head,
   body = models.gn.base.Torso,
   left_arm = models.gn.base.Torso.LeftArm,
   right_arm = models.gn.base.Torso.RightArm,
   left_leg = models.gn.base.LeftLeg,
   right_leg = models.gn.base.RightLeg,
}
local time = 0
events.TICK:register(function ()
   time = time + 1
end)

local remember = {}
events.SKULL_RENDER:register(function (delta, block, item)
   if block and world.getBlockState(block:getPos():add(0,1,0)).id == "minecraft:structure_void" then
      for key, value in pairs(remember) do
         value[2]:setParentType("NONE")
      end
      
      local offset
      if player:isLoaded() then
         local bl,target = player:getTargetedBlock()
         offset = block:getPos():add(0.5,1.5,0.5)-target
      else
         offset = block:getPos():add(0.5,1.5,0.5)-client:getCameraPos()
      end
      local skrot = tonumber(block.properties.rotation)*(22.5)
      local rot = vectors.vec3(-math.deg(math.atan2(offset.y, offset.xz:length())),math.deg(math.atan2(offset.x,offset.z))+skrot,0)
      rot.y = (rot.y + 180) % 360 - 180
      local brot = math.clamp(-rot.y,-25,25)
      brot = brot * (1 - math.clamp(math.abs(rot.y / 180) * 4 - 3, 0, 1))

      local o = vectors.vec3(0,brot,0):add(rot.x,rot.y,0)

      parts.base:setRot(0,rot.y,0)
      parts.head:setRot(o.x*-0.4 +rot.x,-rot.y*0.2 - brot,0)
      parts.body:setRot(o.x*0.2+math.cos((time+delta)*0.1)*0.1,o.y*0.5 + brot,0):setPos(0,math.sin((time+delta)*0.1)*0.1,0)

      parts.left_arm:setRot(o.x*-0.2,o.y*0.3,-math.abs(o.y*0.1))
      parts.right_arm:setRot(o.x*-0.2,o.y*0.3,math.abs(o.y*0.1))
      parts.left_leg:setPos(0,0,math.sin(math.rad(o.y))*1.5):setRot(math.rad(o.y) * -6,0)
      parts.right_leg:setPos(0,0,-math.sin(math.rad(o.y))*1.5):setRot(math.rad(o.y) * 6,0)
      models.gn:setParentType("SKULL")
      models.plushie:setVisible(false)
      models.gn:setVisible(true):setScale(0.94)
   else
      models.gn:setVisible(false)
      models.plushie:setVisible(true)
   end
end)

---@param model ModelPart
local function getRemember(model,prefix)
   for key, value in pairs(model:getChildren()) do
      if prefix then
         remember[prefix.."."..value:getName()] = {value:getParentType(),value}
         getRemember(value,prefix.."."..value:getName())
      else
         remember[value:getName()] = {value:getParentType(),value}
         getRemember(value,value:getName())
      end
   end
end
getRemember(models.gn)
remember["gn"] = {models.gn:getParentType(),models.gn}

events.RENDER:register(function (delta,context)
   models.gn:setVisible(true):setScale(1)
   models.gn.base:setRot(0,0,0)
   for key, value in pairs(remember) do
      value[2]:setParentType(value[1])
   end
end)

