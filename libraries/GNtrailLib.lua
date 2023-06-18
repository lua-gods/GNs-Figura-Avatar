--[[______   __                _                 __
  / ____/ | / /___ _____ ___  (_)___ ___  ____ _/ /____  _____
 / / __/  |/ / __ `/ __ `__ \/ / __ `__ \/ __ `/ __/ _ \/ ___/
/ /_/ / /|  / /_/ / / / / / / / / / / / / /_/ / /_/  __(__  )
\____/_/ |_/\__,_/_/ /_/ /_/_/_/ /_/ /_/\__,_/\__/\___/____]]
local lib = {}
local smears = {}

local config = {
   world = nil
}
---This should be called before doing anything with this library.
---@param model ModelPart
---@return table
function lib:setWorld(model)
   if type(model) ~= "ModelPart" then error("world model given invalid: "..type(model),2) end
   config.world = model
   model:setParentType("World"):scale(-16,-16,16):setPos(0,0,0)
   return self
end

-->====================[ API ]====================<--

---A trail type that is controlled by two world positions
---@class twoLeadTrail
---@field ID integer
---@field leadA Vector3
---@field leadB Vector3
---@field lead_width number
---@field duration integer
---@field texture Texture
---@field points table
---@field sprites table
---@field render_type ModelPart.renderType
---@field sprites_flipped table
---@field diverge number
local twoLeadTrail = {}
twoLeadTrail.__index = twoLeadTrail

local smearID = 0
---Creates a new Trail
---@param texture Texture?
---@return twoLeadTrail
function lib:newTwoLeadTrail(texture)
   if type(texture) ~= "Texture" then texture = textures["trailworld.gradient"] end
   ---@type twoLeadTrail
   local compose = {
      ID = smearID,
      leadA = nil,
      leadB = nil,
      lead_width = 1,
      texture=texture,
      duration = 20,
      points = {},
      render_type = "EMISSIVE",
      sprites = {},
      sprites_flipped = {},
      diverge = 1,
   }
   smearID = smearID + 1
   setmetatable(compose,twoLeadTrail)
   compose:rebuildSpriteTasks()
   table.insert(smears,compose)
   return compose
end

---Sets the two points which the trail will follow  
---3rd agument defaults to 1 if none given
---@param A Vector3
---@param B Vector3
---@param scale number|nil
---@return twoLeadTrail
function twoLeadTrail:setLeads(A,B,scale)
   if not scale then scale = 1 end
   self.leadA = A:copy()
   self.leadB = B:copy()
   self.lead_width = scale
   self:update()
   return self
end

---sets the divergeness index.  
---the index can be a decimal, for control over how much the effect applies.
---***
--- 0 : shrink  
--- 0.5 : shrink halfway  
--- 1 : none  
--- 1.5 : grow halfway  
--- 2 : grow  
---@param index number
---@return twoLeadTrail
function twoLeadTrail:setDivergeness(index)
   self.diverge = index
   return self
end

---Sets the duration of the trail, the duration is based on update ticks(not minecraft ticks).
---@param ticks integer
---@return twoLeadTrail
function twoLeadTrail:setDuration(ticks)
   self.duration = ticks
   self:rebuildSpriteTasks()
   return self
end

---Sets the render type of the smear.
---@param render_type ModelPart.renderType
---@return twoLeadTrail
function twoLeadTrail:setRenderType(render_type)
   self.render_type = render_type
   twoLeadTrail:rebuildSpriteTasks()
   return self
end

---Deletes all the sprite tasks, must be called when discarding the object.
function twoLeadTrail:delete()
   for _, t in pairs(self.sprites) do config.world:removeTask(t:getName()) end
   for _, t in pairs(self.sprites_flipped) do config.world:removeTask(t:getName()) end
end

---Rebuilds the sprite tasks.
---@return twoLeadTrail
function twoLeadTrail:rebuildSpriteTasks()
   for _, t in pairs(self.sprites) do config.world:removeTask(t:getName()) end
   for _, t in pairs(self.sprites_flipped) do config.world:removeTask(t:getName()) end
   self.sprites = {}
   self.sprites_flipped = {}
   for i = 1, self.duration-1, 1 do
      local new = config.world:newSprite(self.ID.."GNSMEAR"..i):setTexture(self.texture):setRenderType(self.render_type)
      local v = new:getVertices()
      v[1]:uv(0,i/self.duration) v[2]:uv(1,i/self.duration) v[3]:uv(1,(i+1)/self.duration)v[4]:uv(0,(i+1)/self.duration)
      table.insert(self.sprites,new)
   end
   for i = 1, self.duration-1, 1 do
      local new = config.world:newSprite(self.ID.."GNSMEAR"..i.."FLIP"):setTexture(self.texture):setRenderType(self.render_type)
      local v = new:getVertices()
      v[2]:uv(0,i/self.duration) v[1]:uv(1,i/self.duration) v[4]:uv(1,(i+1)/self.duration)v[3]:uv(0,(i+1)/self.duration)
      table.insert(self.sprites_flipped,new)
   end
   return self
end

---Updates the Trail Rendering
---@return twoLeadTrail
function twoLeadTrail:update()
   if self.leadA and self.leadB then
      table.insert(self.points,1,{self.leadA,self.leadB,self.lead_width})
      while #self.points > self.duration do
         table.remove(self.points,self.duration+1)
      end
      
      for id = 1, #self.points-1, 1 do
         local invisible = ((self.points[id][3] + self.points[id+1][3]) == 0)
            self.sprites[id]:setVisible(not invisible)
            self.sprites_flipped[id]:setVisible(not invisible)
            if not invisible then
               local v = self.sprites[id]:getVertices()
               local v2 = self.sprites_flipped[id]:getVertices()
               local width, width_next
               width = 1-(math.map((id / self.duration),0,1,1,self.diverge) * self.points[id][3])
               width_next = 1-(math.map(((id + 1) / self.duration),0,1,1,self.diverge) * self.points[id + 1][3])
               local a, b, c, d = (self.points[id][1]), (self.points[id][2]), (self.points[id+1][1]), (self.points[id+1][2])
               local a2, b2, c2, d2 = 
               math.lerp(a,b,width*0.5), math.lerp(b,a,width*0.5), 
               math.lerp(d,c,width_next*0.5), math.lerp(c,d,width_next*0.5)
               v[1]:setPos(a2) v[2]:setPos(b2)
               v[3]:setPos(c2) v[4]:setPos(d2)
               v2[2]:setPos(a2) v2[1]:setPos(b2)
               v2[3]:setPos(d2) v2[4]:setPos(c2)
            end
      end
   end
   return self
end

return lib