local panel = require("libraries.panel")
local page = panel:newPage()

local transition = 0
local toggle = false


events.WORLD_RENDER:register(function (delta)
   if toggle then
      transition = math.min(transition + 0.02,1)
   else
      transition = math.max(transition - 0.02,0)
   end
   if transition > 0.01 then
      ---@type Matrix4
      local t = -(math.cos(math.pi * transition) - 1) / 2
      local cmat = matrices.mat4()
      cmat:scale(1,1,1/(1+t * t * 20)):translate(0,0,-t * 4)
      renderer:setCameraMatrix(cmat)
   else
      renderer:setCameraMatrix()
   end
end)

page:newElement("toggleButton"):setText("Orthographic Mode").ON_TOGGLE:register(function (t)
   toggle = t
end)
page:newElement("returnButton")


return page