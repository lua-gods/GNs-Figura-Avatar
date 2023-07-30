--[[______   __                _                 __
  / ____/ | / /___ _____ ___  (_)___ ___  ____ _/ /____  _____
 / / __/  |/ / __ `/ __ `__ \/ / __ `__ \/ __ `/ __/ _ \/ ___/
/ /_/ / /|  / /_/ / / / / / / / / / / / / /_/ / /_/  __(__  )
\____/_/ |_/\__,_/_/ /_/ /_/_/_/ /_/ /_/\__,_/\__/\___/____]]
---@diagnostic disable: param-type-mismatch

local config = {
   model_path = models:newPart("gndrawlibspatialworld"):setParentType("WORLD"),
   texture_task_name_prefix = "gndrawlibspatial", -- prefix .. type
   white_texture = textures:newTexture("gnlinepixel",1,1):setPixel(0,0,vectors.vec3(1,1,1)),

   default_line_color = vectors.vec3(0,1,0)
}


local lcpos = vectors.vec3()
local cpos = vectors.vec3()

local draw = {elements={Line={}},queue_update={}}
config.model_path:setParentType("World")
config.model_path:setScale(16,16,16)

---@class Line
---@field id integer
---@field From Vector3
---@field To Vector3
---@field Dir Vector3
---@field Length number
---@field Depth number
---@field Color Vector3
---@field Width number
---@field UniformWidth boolean
---@field Visible boolean
---@field Delete boolean
---@field Task any
local Line = {}
Line.__index = Line
Line.__type = "Line"

function Line:updateTransform()
   draw.queue_update[#draw.queue_update+1] = self
end

---@param x number|Vector3
---@param y number|nil
---@param z number|nil
---@return Line
function Line:from(x,y,z)
   if type(x) == "Vector3" then
      self.From = x:copy()
   else self.From = vectors.vec3(x,y,z)
   end
   self.Dir = self.To-self.From
   self.Length = self.Dir:length()
   self:updateTransform()
   return self
end

---@param x number|Vector3
---@param y number|nil
---@param z number|nil
function Line:to(x,y,z)
   if type(x) == "Vector3" then
      self.To = x:copy()
   else self.To = vectors.vec3(x,y,z)
   end
   self.Dir = self.To-self.From
   self.Length = self.Dir:length()
   self:updateTransform()
   return self
end

function Line:dir(x,y,z)
   if type(x) == "Vector3" then
      self.Dir = x:copy()
   else self.Dir = vectors.vec3(x,y,z)
   end
   self.To = self.From + self.Dir
   self.Length = self.Dir:length()
   self:updateTransform()
   return self
end

function Line:length(dist)
   self.Length = dist
   self.Dir = self.Dir:normalize()*dist
   self.To = self.From+self.Dir
   self:updateTransform()
   return self
end

function Line:depth(dist)
   self.Depth = dist
   self:updateTransform()
   return self
end

---@param r number|Vector3
---@param g number|nil
---@param b number|nil
function Line:color(r,g,b)
   if type(r) == "Vector3" then
      self.Color = r:copy()
   else self.Color = vectors.vec3(r,g,b)
   end
   self.Task:setColor(self.Color)
   self:updateTransform()
   return self
end

function Line:width(width)
   self.Width = width
   self:updateTransform()
   return self
end

function Line:uniformWidth(toggle)
   self.UniformWidth = toggle
   return self
end

---@param visible boolean
---@return Line
function Line:visible(visible)
   self.Visible = visible
   return self
end

---@return Line
function Line:delete()
   config.model_path:removeTask(config.texture_task_name_prefix .. "line" .. self.id)
   draw.elements.Line[self.id] = nil
   return self
end

local lineID = 0
function draw:newLine()
   lineID = lineID + 1
   ---@type Line
   local compound = {
      Dir=nil,
      Length=nil,
      id = lineID,
      From = vectors.vec3(),
      To = vectors.vec3(),
      Color = vectors.vec3(1,1,1),
      Width = 0.05,
      Depth = 0,
      UniformWidth = false,
      Visible = true,
      Delete = true,
      Transform = matrices.mat4(),
      Task = config.model_path:newSprite(config.texture_task_name_prefix .. "line" .. lineID):setTexture(config.white_texture):setRenderType("EMISSIVE_SOLID")}
   setmetatable(compound,Line)
   compound.Task:color(compound.Color)
   table.insert(draw.elements.Line,compound)
   return compound
end

local function flatvec(vector, normal)
   normal = normal:normalize()
   local projectionMagnitude = vector:dot(normal)
   local projection = normal * projectionMagnitude
   local flattenedVector = vector - projection
   return flattenedVector
end

local llinec = 0
events.WORLD_RENDER:register(function (delta)
   cpos = client:getCameraPos()
   local linec = #draw.elements.Line
   if cpos ~= lcpos or llinec ~= linec then
      lcpos = cpos
      llinec = linec
      for id, line in pairs(draw.elements.Line) do
         line:updateTransform()
      end
   end
   for key, e in pairs(draw.queue_update) do
      if type(e) == "Line" then
         if e.Visible and e.Dir then
            local a = vectors.worldToScreenSpace(e.From)
            local b = vectors.worldToScreenSpace(e.To)
            if a.z > 0 or b.z > 0 then
               local mat = matrices.mat4()
               local offset = (cpos-e.From)
               local width = e.Width
               local floppa = flatvec(offset,-e.Dir)
               if e.UniformWidth then
                  width = width * floppa:length()
               end
               mat.c2 = (-e.Dir:normalize() * (e.Length + width * 0.5)):augmented(0)
               mat.c3 = (floppa:normalize()):augmented(0)
               mat.c1 = vectors.rotateAroundAxis(90,mat.c3.xyz,e.Dir):augmented(0) * width
               mat.c4 = (e.From + mat.c1.xyz * 0.5 - e.Dir:normalized() * width * 0.25):augmented()
               e.Task:setMatrix(mat * (1 + e.Depth)):setVisible(true)
            end
         else
            e.Task:setVisible(false)
         end
      end
   end
   draw.queue_update = {}
end)
draw.config = config
return draw
