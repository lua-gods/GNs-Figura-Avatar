
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

local physics = {}

for key, value in pairs(parts) do
   physics[key] = {
      model = value,
      lin_p = vectors.vec3(),
      lin_v = vectors.vec3(),
      lin_gp = vectors.vec3(),
      lin_d = 0.8,
      lin_s = 0.1,

      ang_p = vectors.vec3(),
      ang_v = vectors.vec3(),
      ang_gp = vectors.vec3(),
      ang_d = 0.8,
      ang_s = 0.1,
   }
end


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
      if vel.xz:length() < 0.02 then
         dist = vectors.vec3(0,0,0)
      end
      dist = dist + vel
   end
   if lvel then
      ready = true
   end
end)

events.RENDER:register(function (delta, context)
   if ready and player:isLoaded() then
      local tdist = math.lerp(ldist,dist,delta)
      local tvel = math.lerp(lvel,vel,delta)
      local walking = vectors.vec3(math.clamp(math.abs(tvel.x) * 10,0,1),0,math.clamp(math.abs(tvel.z) * 10,0,1))
      local walk_dist = walking.xz:length()
      local tilt = vectors.vec3(math.clamp(tvel.x,-1,1),0,math.clamp(tvel.z,-1,1))
      for key, value in pairs(physics) do
         value.ang_s = math.map(walk_dist,0,1,0.01,0.3)
         value.lin_s = math.map(walk_dist,0,1,0.01,0.3)

         value.ang_d = math.map(walk_dist,0,1,0.95,0.8)
         value.lin_d = math.map(walk_dist,0,1,0.6,0.8)
      end
      if player:isOnGround() then
            physics.left_leg.ang_gp = vectors.vec3(
            (math.sin((tdist.z) * math.pi) * 30) * walking.z,
            0,
            0
         )
         physics.left_leg.lin_gp = vectors.vec3(
            0,
            math.max(math.sin(tdist.z * math.pi - math.pi * 1.25) * 2,-1) * walking.z,
            (-math.cos(tdist.z * math.pi)* 2 - math.pi * 0.5) * walking.z
         )

         physics.right_leg.ang_gp = vectors.vec3(
            (math.sin((tdist.z) * math.pi) * 30) * -walking.z,
            0,
            0
         )
         physics.right_leg.lin_gp = vectors.vec3(
            0,
            math.max(math.sin(tdist.z * math.pi - math.pi * 1.25) * -3,-1) * walking.z,
            (-math.cos(tdist.z * math.pi)* 2 + math.pi * 0.5) * -walking.z
         )
         physics.torso.ang_gp = vectors.vec3(
            0,
            math.sin(tdist.z * math.pi) * -5,
            0
         )
         physics.torso.lin_gp = vectors.vec3(
            0,
            (math.abs(math.cos(tdist.z * math.pi)) - 1) * walking.z
         )
         physics.left_arm.ang_gp = vectors.vec3(
            (math.sin(tdist.z * math.pi) * -45 + 15) * walking.z,
            0,
            -math.abs(math.cos(tdist.z * math.pi) * 10 * walking.z)
         )
         physics.right_arm.ang_gp = vectors.vec3(
            (math.sin(tdist.z * math.pi) * 45 + 15) * walking.z,
            0,
            math.abs(math.cos(tdist.z * math.pi) * 1 * walking.z)
         )
         physics.base.ang_gp = vectors.vec3(
            tilt.z * -45,
            tilt.x * 45,
            tilt.x * 45
         )
         physics.head.ang_gp = vectors.vec3(
            tilt.z * 45,
            math.sin(tdist.z * math.pi + 0.2) * 5,
            0
         )
      end
   end
end)

events.RENDER:register(function (delta, context)
   if context == "FIRST_PERSON" then
      parts.right_arm:setParentType("RIGHT_ARM"):setRot(0,0,0)
      parts.left_arm:setParentType("LEFT_ARM"):setRot(0,0,0)
   else
      parts.right_arm:setParentType("NONE")
      parts.left_arm:setParentType("NONE")
      for key, value in pairs(physics) do
         value.model:setRot(value.ang_p):setPos(value.lin_p)
      end
   end
end)

events.WORLD_RENDER:register(function (delta)
   for key, value in pairs(physics) do
      value.lin_p = value.lin_p + value.lin_v 
      value.lin_v = value.lin_v * value.lin_d + (value.lin_gp - value.lin_p) * value.lin_s
      value.ang_p = value.ang_p + value.ang_v 
      value.ang_v = value.ang_v * value.ang_d + (value.ang_gp - value.ang_p) * value.ang_s
   end
end)

parts.base:setParentType("None")