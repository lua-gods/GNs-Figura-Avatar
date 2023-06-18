---@class PanelMargin
---@field root PanelRoot
---@field text string
---@field ON_PRESS KattEvent
---@field ON_RELEASE KattEvent
local Template = {}
Template.__index = Template
Template.__type = "paneltemplate"

local label = require("libraries.GNLabelLib")
local kitkat = require("libraries.KattEventsAPI")

-->========================================[ API ]=========================================<--

---@param panel PanelRoot
---@return PanelMargin
function Template.new(panel)
   ---@type PanelMargin
   local compose = {
      root = panel,
      labels = {},
      text = "Template",
      ON_PRESS = kitkat.newEvent(),
      ON_RELEASE = kitkat.newEvent(),
   }
   setmetatable(compose,Template)
   return compose
end

-->========================================[ Render Handling ]=========================================<--

function Template:rebuild()
   self.labels = {label.newLabel()}
end

---@param state PanelElementState
---@param anchor Vector2
---@param offset Vector2
function Template:update(anchor,offset,state)
   self.labels[1]:setText(self.text):setAnchor(anchor):setOffset(offset)
   return self.labels
end

function Template:clearTasks()
   for i, _ in pairs(self.labels) do
      self.labels[i]:delete()
   end
end

-->========================================[ Input Handling ]=========================================<--

function Template:pressed()
   self.root:update()
   self.root:setSelectState(true)
   self.ON_PRESS:invoke(self)
end

function Template:released()
   self.root:update()
   self.root:setSelectState(false)
   self.ON_RELEASE:invoke(self)
end

return Template