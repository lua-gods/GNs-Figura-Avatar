--[[______   __                _                 __
  / ____/ | / /___ _____ ___  (_)___ ___  ____ _/ /____  _____
 / / __/  |/ / __ `/ __ `__ \/ / __ `__ \/ __ `/ __/ _ \/ ___/
/ /_/ / /|  / /_/ / / / / / / / / / / / / /_/ / /_/  __(__  )
\____/_/ |_/\__,_/_/ /_/ /_/_/_/ /_/ /_/\__,_/\__/\___/____]]
---@diagnostic disable: param-type-mismatch

local config = {
   model_path = models.gndrawlibspatial,
   texture_task_name_prefix = "gndrawlibspatial", -- prefix .. type
   white_texture = textures:newTexture("gndrawlibspatialwhitetexture",1,1):setPixel(0,0,vectors.vec3(1,1,1)),

   default_line_color = vectors.vec3(0,1,0)
}

local vecp = require("libraries.GNVecPlus")

local draw = {elements={Line={}}}
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
---@field SpriteTask any
local Line = {}
Line.__index = Line

local function UpdateTransform(line)
   local rot = vecp.toAngle(line.Dir)
   line.Transform = matrices.mat4():rotate(rot):invert()
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
   UpdateTransform(self)
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
   UpdateTransform(self)
   return self
end

function Line:dir(x,y,z)
   if type(x) == "Vector3" then
      self.Dir = x:copy()
   else self.Dir = vectors.vec3(x,y,z)
   end
   self.To = self.From + self.Dir
   self.Length = self.Dir:length()
   UpdateTransform(self)
   return self
end

function Line:length(dist)
   self.Length = dist
   self.Dir = self.Dir:normalize()*dist
   self.To = self.From+self.Dir
   return self
end

function Line:depth(dist)
   self.Depth = dist
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
   self.SpriteTask:setColor(self.Color)
   return self
end

function Line:width(width)
   self.Width = width
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

local lcpos = vectors.vec3()
local llinec = 0
events.WORLD_RENDER:register(function (delta)
   local cpos = client:getCameraPos()
   local linec = #draw.elements.Line
   if cpos ~= lcpos or llinec ~= linec then
      lcpos = cpos
      llinec = linec
      cpos = (cpos)
      for id, line in pairs(draw.elements.Line) do
         if line.Visible then
            local rot = vecp.toAngle(-line.Dir)
            local final_transform = matrices.mat4()
            local cposoffset = (line.Transform * (cpos.xyz-line.From):augmented()).xyz
            local y = math.deg(180-math.atan(cposoffset.x,cposoffset.z))
            final_transform:translate(0.5,0,line.Depth):scale(line.Width,line.Length+line.Width*0.5,1):translate(0,line.Width*0.25,0):rotateY(y):rotateZ(rot.z):rotateX(rot.x):rotateY(rot.y):translate(line.From)
            line.Task:setMatrix(final_transform):setEnabled(true)
         else
            line.Task:setEnabled(false)
         end
      end
   end
end)

return draw
