--[[______   __                _                 __
  / ____/ | / /___ _____ ___  (_)___ ___  ____ _/ /____  _____
 / / __/  |/ / __ `/ __ `__ \/ / __ `__ \/ __ `/ __/ _ \/ ___/
/ /_/ / /|  / /_/ / / / / / / / / / / / / /_/ / /_/  __(__  )
\____/_/ |_/\__,_/_/ /_/ /_/_/_/ /_/ /_/\__,_/\__/\___/____]]
local lib = {}
local smears = {}

local config = {
   world = models.World
}

models.World:scale(-16,-16,16):setParentType("World")

-->====================[ API ]====================<--

---@class twoPointSmear
---@field leadA Vector3
---@field leadB Vector3
---@field duration integer
---@field texture Texture
---@field points table
---@field sprites table
---@field ID integer
---@field sprites_flipped table
local twoPointSmear = {}
twoPointSmear.__index = twoPointSmear

local smearID = 0
function lib:newTwoPointSmear()
   ---@type twoPointSmear
   local compose = {
      ID = smearID,
      leadA = vectors.vec3(),
      leadB = vectors.vec3(),
      texture=textures.gradient,
      duration = 20,
      points = {},
      sprites = {},
      sprites_flipped = {},
   }
   smearID = smearID + 1
   setmetatable(compose,twoPointSmear)
   compose:reloadSprites()
   table.insert(smears,compose)
   return compose
end

function twoPointSmear:reloadSprites()
   for i = 1, self.duration-1, 1 do
      local p = 1-(i/self.duration)
      local new = models.World:newSprite(self.ID.."GNSMEAR"..i):setTexture(self.texture):setRenderType("EMISSIVE")
      table.insert(self.sprites,new)
   end
   for i = 1, self.duration-1, 1 do
      local p = 1-(i/self.duration)
      local new = models.World:newSprite(self.ID.."GNSMEAR"..i.."FLIP"):setTexture(self.texture):setRenderType("EMISSIVE")
      table.insert(self.sprites_flipped,new)
   end
end

local newSmear = lib:newTwoPointSmear()

-->====================[ Renderer ]====================<--


events.WORLD_RENDER:register(function (delta)
   if not player:isLoaded() then return end
   local root = models.gn.base.Torso.Body.sword.Anchor1.Anchor2
   newSmear.leadA = (root:partToWorldMatrix() * vectors.vec4(0,0,0,1)).xyz
   newSmear.leadB = (root:partToWorldMatrix() * vectors.vec4(0,0,-32,1)).xyz
   for i, s in pairs(smears) do
      table.insert(s.points,1,{newSmear.leadA,newSmear.leadB})
      if #s.points > s.duration then
         table.remove(s.points,s.duration+1)
      end
      for id = 1, s.duration, 1 do
         if s.points[id+1] then
            local v = s.sprites[id]:getVertices()
            v[1]:setPos((s.points[id][1])):normal(vectors.vec3(0,1,0)):uv(0,id/s.duration)
            v[2]:setPos((s.points[id][2])):normal(vectors.vec3(0,1,0)):uv(1,id/s.duration)
            v[4]:setPos((s.points[id+1][1])):normal(vectors.vec3(0,1,0)):uv(0,(id+1)/s.duration)
            v[3]:setPos((s.points[id+1][2])):normal(vectors.vec3(0,1,0)):uv(1,(id+1)/s.duration)
            local v2 = s.sprites_flipped[id]:getVertices()
            v2[2]:setPos((s.points[id][1])):normal(vectors.vec3(0,1,0)):uv(0,id/s.duration)
            v2[1]:setPos((s.points[id][2])):normal(vectors.vec3(0,1,0)):uv(1,id/s.duration)
            v2[3]:setPos((s.points[id+1][1])):normal(vectors.vec3(0,1,0)):uv(0,(id+1)/s.duration)
            v2[4]:setPos((s.points[id+1][2])):normal(vectors.vec3(0,1,0)):uv(1,(id+1)/s.duration)
         end
         --s.sprites[id]:setPos(s.points[id][2])
      end
   end
end)

return lib