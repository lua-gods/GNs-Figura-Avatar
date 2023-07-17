
local config = {
   tick_span = 3, -- ticks
}

local parts = {
   base = models.gn.base,
   head = models.gn.base.Torso.Head,
   body = models.gn.base.Torso,
   left_arm = models.gn.base.Torso.LeftArm,
   right_arm = models.gn.base.Torso.RightArm,
   left_leg = models.gn.base.LeftLeg,
   right_leg = models.gn.base.RightLeg,
}

local is_flying = false
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
      local brot
      local vehicle = player:getVehicle()
      if vehicle then
         brot = vehicle:getRot().y
      else
         brot = player:getBodyYaw()
      end
      offset = vectors.vec2(player:getRot().x,(player:getRot().y - brot) % 360)
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
      local swing = vanilla_model.LEFT_LEG:getOriginRot().x
      local is_on_ground = player:isOnGround()
      is_on_ground = is_on_ground and 1 or 0
      parts.base:setPos(0,math.abs(swing)*0.01*is_on_ground,0)
      parts.head:setRot(o.x*-0.2,o.y*-0.5 - swing * 0.1 * 1,0)
      parts.body:setRot(o.x*0.2+math.cos((time+delta)*0.1)*0.1,o.y*0.5 + swing * 0.1,0):setPos(0,math.sin((time+delta)*0.1)*0.1,0)
      parts.head.FranHair:setRot(math.min(-o.x,0))
      if is_underwater and (pose == "STANDING" or pose == "CROUCHING") then
         parts.left_arm:setRot(o.x*-0.2,o.y*0.3,math.min(tvel.y*180-45,0))
         parts.right_arm:setRot(o.x*-0.2,o.y*0.3,-math.min(tvel.y*180-45,0))
         parts.left_leg:setRot(math.rad(o.y) * 6 + math.sin((time+delta)*0.2)*25*math.min(math.abs(tvel.y)*10,1))
         parts.right_leg:setRot(math.rad(o.y) * -6 - math.sin((time+delta)*0.2)*25*math.min(math.abs(tvel.y)*10,1))
      else
         if FEMINE_POSE then
            parts.left_arm:setRot(o.x*-0.2,o.y*0.3,-math.abs(o.y*0.2))
            parts.right_arm:setRot(o.x*-0.2,o.y*0.3,math.abs(o.y*0.2))
            parts.left_leg:setPos(0,0,math.sin(math.rad(o.y))*1.5):setRot(math.rad(o.y) * 6,0)
            parts.right_leg:setPos(0,0,-math.sin(math.rad(o.y))*1.5):setRot(math.rad(o.y) * -6,0)
         else
            parts.left_arm:setRot(o.x*-0.2,o.y*0.3,-math.abs(o.y*0.1))
            parts.right_arm:setRot(o.x*-0.2,o.y*0.3,math.abs(o.y*0.1))
            parts.left_leg:setPos(0,0,math.sin(math.rad(o.y))*1.5):setRot(math.rad(o.y) * -6,0)
            parts.right_leg:setPos(0,0,-math.sin(math.rad(o.y))*1.5):setRot(math.rad(o.y) * 6,0)
         end
      end
   end
end)

local blink_timer = 0

events.TICK:register(function ()
   blink_timer = blink_timer - 1
   if blink_timer < 0 then
      animations.gn.blink:play()
      blink_timer = math.random(0.5,3) * 20
   end
end)

local wait_timer = 0
local wait_animations = {
   animations.gn.arms,
   animations.gn.scratch,
}

function pings.APAOEKAO(id)
   wait_animations[id]:play()
end

events.TICK:register(function ()
   if IS_AFK and H then
      wait_timer = wait_timer - 1
      if wait_timer < 0 then
         pings.APAOEKAO(math.random(1,#wait_animations))
         wait_timer = math.random(5,30) * 20
      end
   end
end)