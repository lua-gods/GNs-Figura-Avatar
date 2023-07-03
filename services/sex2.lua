
local base = models.gn

local thickness = 0.4
local depth = 1
local darkness = 0.5

local outlines = {
   vectors.vec3(1,1,1),
   vectors.vec3(1,-1,1),
   vectors.vec3(-1,1,1),
   vectors.vec3(-1,-1,1),

   vectors.vec3(1,1,-1),
   vectors.vec3(1,-1,-1),
   vectors.vec3(-1,1,-1),
   vectors.vec3(-1,-1,-1),
}


local m = {}
base:setMatrix(matrices.mat4() * 0.9)
for index, offset in ipairs(outlines) do
   local model = base:copy("outline"..index):setPrimaryRenderType("CUTOUT_CULL"):setColor(darkness,darkness,darkness)
   models:addChild(model)
   m[index] = model
end

for key, offset in pairs(outlines) do
   local mat = matrices.mat4():translate(offset * thickness)
   m[key]:setVisible(true):setMatrix(mat * depth)
end

events.RENDER:register(function (delta, context)
   if context == "RENDER" then
      if player:isLoaded() then
         for key, moma in pairs(m) do
            moma:setVisible(true)
         end
      end
   else
      for key, moma in pairs(m) do
         moma:setVisible(false)
      end
   end
end)
