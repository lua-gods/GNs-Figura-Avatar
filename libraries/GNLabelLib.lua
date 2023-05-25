--[[______   __                _                 __
  / ____/ | / /___ _____ ___  (_)___ ___  ____ _/ /____  _____
 / / __/  |/ / __ `/ __ `__ \/ / __ `__ \/ __ `/ __/ _ \/ ___/
/ /_/ / /|  / /_/ / / / / / / / / / / / / /_/ / /_/  __(__  )
\____/_/ |_/\__,_/_/ /_/ /_/_/_/ /_/ /_/\__,_/\__/\___/____]]
local lib = {}
local labels = {}
if not H then
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
---@field max_size Vector2
---@field size Vector2
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
      text_align = 0,
      max_size = vectors.vec2(),
      size = vectors.vec2(),
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
   self:updatePositioning()
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
   self:updatePositioning()
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
   self:updatePositioning()
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
   self:updatePositioning()
   return self
end

function Label:setTextAlign(align)
   self.text_align = align
   self:updatePositioning()
   return self
end


---sets the maximum size of the Label.  
---setting both to 0 will make the maximum size infinite
---@param x number|Vector2
---@param y number|nil
function Label:setMaxSize(x,y)
   if type(x) == "number" then
      self.max_size = vectors.vec2(x,y)
   else self.max_size = x end
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
   self.tasks[taskName] =  self.parent:newText(taskName):shadow(true)
   self:updateTextDisplay()
   self:updatePositioning()
end

function Label:updatePositioning()
   local i = 0
   for task_name, task in pairs(self.tasks) do
      local pos = vectors.vec2(self.anchor.x-0.5,self.anchor.y-0.5)
      *client:getScaledWindowSize()
      task:pos(pos.x+self.offset.x,pos.y+self.offset.y,0)
   end
   return self
end

function Label:updateTextDisplay()
   local i = 0
   for task_name, task in pairs(self.tasks) do
      task:text(self.text)
   end
   return self
end

local last_window_size = vectors.vec2()
events.WORLD_RENDER:register(function (delta)
   local window_size = client:getWindowSize()
   if last_window_size ~= window_size then
      last_window_size = window_size
      for _, label in pairs(labels) do
         label:updatePositioning()
      end
   end
end)

return lib