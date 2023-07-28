
local parts = {
   base = models.gn.base,
   head = models.gn.base.Torso.Head,
   torso = models.gn.base.Torso,
   body = models.gn.base.Torso.Body,
   left_arm = models.gn.base.Torso.LeftArm,
   right_arm = models.gn.base.Torso.RightArm,
   left_leg = models.gn.base.LeftLeg,
   right_leg = models.gn.base.RightLeg,
}



events.TICK:register(function ()
   parts.left_arm:setVisible(not HOLDING_GUN)
   parts.right_arm:setVisible(not HOLDING_GUN)
end)

for key, value in pairs(parts) do
   value:setParentType("None")
end

local lpos,pos
local lvel,vel
local lrot,rot
local ldist,dist = nil,vectors.vec3()
local ready = false


events.TICK:register(function ()
   lpos = pos
   lvel = vel
   ldist = dist
   lrot = rot
   pos = player:getPos()
   rot = player:getRot()
   if lpos then
      local v = lpos - pos
      local mat = matrices.mat4():rotateY(player:getBodyYaw() % 360)
      vel = (-v:augmented() * mat).xyz
      --vel = vectors.vec3(0,0,0.2)
      dist = dist + vel
   end
   if lvel then
      ready = true
   end
end)

events.RENDER:register(function (delta, context)
   if ready then
      local tdist = math.lerp(ldist,dist,delta)
      local tvel = math.lerp(lvel,vel,delta)
      local walking = vectors.vec3(math.clamp(math.abs(tvel.x) * 10,0,1),0,math.clamp(math.abs(tvel.z) * 10,0,1))
      local tilt = vectors.vec3(math.clamp(tvel.x,-1,1),0,math.clamp(tvel.z,-1,1))
      parts.left_leg:setRot(
         (math.sin((tdist.z) * math.pi) * 30) * walking.z,
         0,
         0
      ):setPos(
         0,
         math.max(math.sin(tdist.z * math.pi - math.pi * 1.25) * 2,-1) * walking.z,
         (-math.cos(tdist.z * math.pi)* 2 - math.pi * 0.5) * walking.z
      )
      parts.right_leg:setRot(
         (math.sin((tdist.z) * math.pi) * 30) * -walking.z,
         0,
         0
      ):setPos(
         0,
         math.max(math.sin(tdist.z * math.pi - math.pi * 1.25) * -3,-1) * walking.z,
         (-math.cos(tdist.z * math.pi)* 2 + math.pi * 0.5) * -walking.z
      )
      parts.torso:setRot():setRot(
         0,
         math.sin(tdist.z * math.pi) * -5,
         0
      )
      :setPos(
         0,
         (math.abs(math.cos(tdist.z * math.pi)) - 1) * walking.z
      )
      parts.left_arm:setRot(
         (math.sin(tdist.z * math.pi) * -45 + 15) * walking.z,
         0,
         -math.abs(math.cos(tdist.z * math.pi) * 10 * walking.z)
      )
      parts.right_arm:setRot(
         (math.sin(tdist.z * math.pi) * 45 + 15) * walking.z,
         0,
         math.abs(math.cos(tdist.z * math.pi) * 1 * walking.z)
      )
      parts.base:setRot(
         tilt.z * -45,
         tilt.x * 45,
         tilt.x * 45
      )
      parts.head:setRot(
         tilt.z * 45,
         math.sin(tdist.z * math.pi + 0.2) * 5,
         0
      )
   end
end)

events.RENDER:register(function (delta, context)
   if context == "FIRST_PERSON" then
      parts.right_arm:setParentType("RIGHT_ARM"):setRot(0,0,0)
      parts.left_arm:setParentType("LEFT_ARM"):setRot(0,0,0)
   else
      parts.right_arm:setParentType("NONE")
      parts.left_arm:setParentType("NONE")
   end
end)

parts.base:setParentType("None")