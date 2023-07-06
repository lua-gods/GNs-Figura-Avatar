local panel = require("libraries.panel")
local page = panel:newPage()

local transition = 0
local toggle = false
local iso = false

local spin = 0 
local sping = 0 


events.WORLD_RENDER:register(function (delta)
   if toggle then
      transition = math.min(transition + 0.02,1)
   else
      transition = math.max(transition - 0.04,0)
   end
   if transition > 0.01 then
      ---@type Matrix4
      local t = -(math.cos(math.pi * transition) - 1) / 2
      local fov = client:getFOV()
      local F = fov*(1-t * 0.999)
      local dist = 3
      local cmat = matrices.mat4(
         vec(1,        0,        0,        0),
         vec(0,        1,        0,        0),
         vec(0,        0,        F/fov,    (F/fov)-1),
         vec(0,        0,        0,        1)
     ):transpose()
      renderer:setCameraMatrix(matrices.translate4(0,0,-dist)* cmat* matrices.translate4(0,0,dist))
      local prot = player:getRot()
      if renderer:isCameraBackwards() then
         prot:add(0,180):mul(-1,1)
      end
      prot.y = (prot.y + 180) % 360 - 180
      sping = 45+math.floor(prot.y/90)*90
      if iso then
         local rot = math.lerp(vectors.vec3(prot.x,prot.y,0),vectors.vec3(35,spin,0),t)
         renderer:setCameraRot(rot)
      end
      spin = math.lerpAngle(spin,sping,0.1)
   else
      renderer:setCameraMatrix()
      renderer:setCameraRot()
   end
   if not iso then
      renderer:setCameraRot()
   end
end)

client:getFOV()
renderer:getFOV()

page:newElement("toggleButton"):setText("Toggle").ON_TOGGLE:register(function (t)
   toggle = t
end)
page:newElement("toggleButton"):setText("Isometric").ON_TOGGLE:register(function (t)
   iso = t
end)
page:newElement("returnButton")


return page