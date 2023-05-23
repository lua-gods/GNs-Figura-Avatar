
local config = {
   tick_span = 4, -- ticks
}

local vel = vectors.vec3()
local last_vel = vectors.vec3()
local offset = vectors.vec2()
local last_offset = vectors.vec2()
local time = 0
local is_underwater = false
local pose = nil
events.TICK:register(function ()
   time = time + 1
   if time % config.tick_span == 0 then
      is_underwater = player:isUnderwater()
      pose = player:getPose()
      last_offset = offset:copy()
      last_vel = vel:copy()
      vel = player:getVelocity()
      offset = vectors.vec2(player:getRot().x,(player:getRot().y - player:getBodyYaw()) % 360)
   end
end)

events.RENDER:register(function (delta, context)
   if context == "RENDER" then
      do
         local ratio = 1/config.tick_span
         delta = delta * ratio + (time % config.tick_span * ratio)
      end
      if offset.y > 180 then offset.y = offset.y - 360 end
      local o = -math.lerp(last_offset,offset,delta)
      local tvel = math.lerp(last_vel,vel,delta)
      models.gn.base.Torso.Head:setRot(o.x*-0.2,o.y*-0.5,0)
      models.gn.base.Torso:setRot(o.x*0.2+math.cos((time+delta)*0.1)*0.1,o.y*0.5,0):setPos(0,math.sin((time+delta)*0.1)*0.1,0)
      models.gn.base.Torso.Body.Shirt.BClothing.Tie:setRot(math.max(o.x*-0.2,0),0,o.y*0.1)
      if is_underwater and (pose == "STANDING" or pose == "CROUCHING") then
         models.gn.base.Torso.LeftArm:setRot(o.x*-0.2,o.y*0.3,math.min(tvel.y*180-45,0))
         models.gn.base.Torso.RightArm:setRot(o.x*-0.2,o.y*0.3,-math.min(tvel.y*180-45,0))
         models.gn.base.LeftLeg:setRot(math.rad(o.y) * 6 + math.sin((time+delta)*0.2)*25*math.min(math.abs(tvel.y)*10,1))
         models.gn.base.RightLeg:setRot(math.rad(o.y) * -6 - math.sin((time+delta)*0.2)*25*math.min(math.abs(tvel.y)*10,1))
      else
         models.gn.base.Torso.LeftArm:setRot(o.x*-0.2,o.y*0.3,0)
         models.gn.base.Torso.RightArm:setRot(o.x*-0.2,o.y*0.3,0)
         models.gn.base.LeftLeg:setPos(0,0,math.sin(math.rad(o.y))*1.5):setRot(math.rad(o.y) * 6,0)
         models.gn.base.RightLeg:setPos(0,0,-math.sin(math.rad(o.y))*1.5):setRot(math.rad(o.y) * -6,0)
      end

      if math.random() < 0.01 then
         animations.gn.blink:play()
      end
   end
end)