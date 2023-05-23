local lib = {}

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

local labelID = 0
function lib.newLabel()
   ---@type Label
   local compose = {
      id = labelID,
      parent = config.defualt_parent,
      text = "Empty Label",
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
---@param y number
function Label:setOffset(x,y)
   if type(x) == "number" then
      self.offset = vectors.vec2(x,y)
   else self.offset = x end
   self:updatePositioning()
   return self
end

---sets the anchor position  
---the range is from -1 to 1, top to bottom, left to right
---@param x number|Vector2
---@param y number
function Label:setAnchor(x,y)
   if type(x) == "number" then
      self.anchor = vectors.vec2(x,y)
   else self.anchor = x end
   self:updatePositioning()
   return self
end

---sets the anchor origin position  
---the range is from -1 to 1, top to bottom, left to right
---@param x number|Vector2
---@param y number
function Label:setAnchorOrigin(x,y)
   if type(x) == "number" then
      self.origin = vectors.vec2(x,y)
   else self.origin = x end
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
---@param y number
function Label:setMaxSize(x,y)
   if type(x) == "number" then
      self.max_size = vectors.vec2(x,y)
   else self.max_size = x end
   return self
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
   self.tasks[taskName] =  self.parent:newText(taskName)
   self:updateTextDisplay()
   self:updatePositioning()
end

function Label:updatePositioning()
   local i = 0
   for task_name, task in pairs(self.tasks) do
      local pos = vectors.vec2(self.anchor.x-0.5,self.anchor.y-0.5)
      *client:getScaledWindowSize()
      task:pos(pos.x,pos.y,0)
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

return lib