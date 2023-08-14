---@diagnostic disable: undefined-field
--[[______   __                _                 __
  / ____/ | / /___ _____ ___  (_)___ ___  ____ _/ /____  _____
 / / __/  |/ / __ `/ __ `__ \/ / __ `__ \/ __ `/ __/ _ \/ ___/
/ /_/ / /|  / /_/ / / / / / / / / / / / / /_/ / /_/  __(__  )
\____/_/ |_/\__,_/_/ /_/ /_/_/_/ /_/ /_/\__,_/\__/\___/____]]
local katt = require("libraries.KattEventsAPI")
local lib = {SCREEN_RESIZED = katt.newEvent()}
local labels = {}
if not IS_HOST then
   return
end
local config = {
   defualt_parent = models.hud
}

---@alias LabelOverflowType string
---| "IGNORE"
---| "CUTOFF"
---| "WARP"

---@class Label
---@field id integer
---@field text string
---@field parent ModelPart
---@field scale Vector2
---@field color Vector3
---@field anchor Vector2
---@field origin Vector2
---@field offset Vector2
---@field tasks table
local Label = {}
Label.__index = Label
Label.__type = "label"

local labelID = 1
function lib.newLabel()
   ---@type Label
   local compose = {
      id = labelID,
      parent = config.defualt_parent,
      text = "",
      color=nil,
      text_align = 0,
      outline_color = vectors.vec3(0,0,0),
      default_color = vectors.vec3(1,1,1),
      scale = vectors.vec2(1,1),
      anchor = vectors.vec2(),
      origin = vectors.vec2(),
      offset = vectors.vec2(),
      tasks = {},
   }
   setmetatable(compose,Label)
   compose:buildTasks()
   labels[labelID] = compose
   labelID = labelID + 1
   return compose
end

---Sets the display text of the given label.
---@param text string
---@return Label
function Label:setText(text)
   self.text = text
   self:updateTextDisplay()
   self:updateTransform()
   return self
end

---Sets the color of the label in RGB
---@param R number
---@param G number
---@param B number
function Label:setColorRGB(R,G,B)
   self.color = vectors.vec3(R,G,B)
   self:updateTextDisplay()
   return self
end

---Sets the color of the label in HEX
---@param hex string
function Label:setColorHEX(hex)
   self.color = vectors.hexToRGB(hex)
   self:updateTextDisplay()
   return self
end

---Sets the default color of the label in RGB
---@param R number
---@param G number
---@param B number
function Label:setDefaultColorRGB(R,G,B)
   self.default_color = vectors.vec3(R,G,B)
   self:updateTextDisplay()
   return self
end

---Sets the default color of the label in HEX
---@param hex string
function Label:setDefaultColorHEX(hex)
   self.default_color = vectors.hexToRGB(hex)
   self:updateTextDisplay()
   return self
end

---Sets the default color of the label in RGB
---@param R number
---@param G number
---@param B number
function Label:setOutlineColorRGB(R,G,B)
   self.outline_color = vectors.vec3(R,G,B)
   self:updateTextDisplay()
   return self
end

---Sets the default color of the label in HEX
---@param hex string
function Label:setOutlineColorHex(hex)
   self.outline_color = vectors.hexToRGB(hex)
   self:updateTextDisplay()
   return self
end

function Label:resetColor()
   self.color = nil
   self:updateTextDisplay()
   return self
end

---sets the offset from the origin of the anchor
---@param x number|Vector2
---@param y number|nil
function Label:setOffset(x,y)
   if type(x) == "Vector2" then
      self.offset = x:copy():mul(-1,1)
   else 
      self.offset = vectors.vec2(-x,y)
   end
   self:updateTransform()
   return self
end

---sets the offset from the origin of the anchor
---@param x number|Vector2
---@param y number|nil
function Label:setScale(x,y)
   if type(x) == "Vector2" then
      self.scale = x:copy()
   else 
      self.scale = vectors.vec2(x,y)
   end
   self:updateTransform()
   return self
end

---sets the anchor position  
---the range is from -1 to 1, top to bottom, left to right
---@param x number|Vector2
---@param y number|nil
function Label:setAnchor(x,y)
   if type(x) == "Vector2" then
      self.anchor = x:copy():mul(-0.5,0.5)
   else
      self.anchor = vectors.vec2(x * -0.5,y * 0.5)
   end
   self:updateTransform()
   return self
end

---sets the anchor origin position  
---the range is from -1 to 1, top to bottom, left to right
---@param x number|Vector2
---@param y number|nil
function Label:setAnchorOrigin(x,y)
   if type(x) == "Vector2" then
      self.origin = x 
   else 
      self.origin = vectors.vec2(x,y)
   end
   self:updateTransform()
   return self
end

---queues itself for deletion on the next frame
function Label:delete()
   self:clearTasks()
   labels[self.id] = nil
end

---sets the modelPart thats gonna contain the rendering
---@param model ModelPart
function Label:setParent(model)
   self:clearTasks()
   self.parent = model
   self:buildTasks()
   return self
end

function Label:clearTasks()
   for id, task in pairs(self.tasks) do
      self.parent:removeTask(id)
   end
end


function Label:buildTasks()
   local taskName = "gnlabellib."..self.id..".label"
   self.tasks[taskName] =  self.parent:newText(taskName):outline(true)
   self:updateTextDisplay()
   self:updateTransform()
end

function Label:updateTransform()
   local i = 0
   for task_name, task in pairs(self.tasks) do
      local pos = lib.pos2UI(self.offset.x,self.offset.y,self.anchor.x,self.anchor.y)
      task:pos(pos.x,pos.y,0):scale(self.scale.x,self.scale.y,1)
   end
   return self
end

function lib.pos2UI(ox,oy,ax,ay)
   return vectors.vec2(ax-0.5,ay-0.5)*client:getScaledWindowSize() + vectors.vec2(ox,oy)
end

function Label:updateTextDisplay()
   local i = 0
   local final_color = self.default_color
   if self.color then
      final_color = self.color
   end
   for task_name, task in pairs(self.tasks) do
      task:text('{"text":"'..self.text..'","color":"#'..vectors.rgbToHex(final_color)..'"}'):outlineColor(self.outline_color)
   end
   return self
end

local last_window_size = vectors.vec2()
events.POST_WORLD_RENDER:register(function (delta)
   local window_size = client:getWindowSize()
   if last_window_size ~= window_size then
      last_window_size = window_size
      lib.SCREEN_RESIZED:invoke(window_size)
      for _, label in pairs(labels) do
         label:updateTransform()
      end
   end
end)
return lib