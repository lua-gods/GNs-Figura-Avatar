---@class PanelToggleButton
---@field text string
---@field input function
---@field toggle boolean
---@field root PanelRoot
---@field ON_PRESS KattEvent
---@field ON_TOGGLE KattEvent
---@field ON_RELEASE KattEvent
local PanelToggleButton = {}
PanelToggleButton.__index = PanelToggleButton
PanelToggleButton.__type = "paneltogglebutton"

local label = require("libraries.GNLabelLib")
local kitkat = require("libraries.KattEventsAPI")

-->====================[ API ]====================<--

function PanelToggleButton.new(panel)
   ---@type PanelToggleButton
   local compose = {
      root = panel,
      labels = {},
      toggle = false,
      text = "Untitled Button",
      ON_PRESS = kitkat.newEvent(),
      ON_RELEASE = kitkat.newEvent(),
      ON_TOGGLE    = kitkat.newEvent(),
   }
   setmetatable(compose,PanelToggleButton)
   return compose
end

function PanelToggleButton:setText(text)
   self.text = text
   self.root:update()
   return self
end

function PanelToggleButton:setColorRGB(r,g,b)
   self.color = vectors.vec3(r,g,b)
   self.root:update()
   return self
end

function PanelToggleButton:setToggle(toggle,ignore_events)
   self.toggle = toggle
   if not ignore_events then
      self.ON_TOGGLE:invoke(toggle)
   end
   return self
end

function PanelToggleButton:setColorHex(hex)
   self.color = vectors.hexToRGB(hex)
   self.root:update()
   return self
end

-->====================[ Task Handling ]====================<--

function PanelToggleButton:rebuild()
   self.labels = {
      title=label.newLabel(),slider=label.newLabel(),handle=label.newLabel()}
end

function PanelToggleButton:update(anchor,offset)
   self.labels.title:setText(self.text):setAnchor(anchor):setOffset(offset:copy():add(16,0))
   self.labels.slider:setAnchor(anchor):setOffset(offset)
   if self.toggle then
      self.labels.slider:setText("[  | "):setColorHEX("#99e65f")
      self.labels.handle:setText("[]"):setAnchor(anchor):setOffset(offset:add(4,0))
   else
      self.labels.slider:setText("|  ] "):setColorHEX("#f5555d")
      self.labels.handle:setText("[]"):setAnchor(anchor):setOffset(offset:add(2,0))
   end
   return self.labels
end

function PanelToggleButton:clearTasks()
   for i, _ in pairs(self.labels) do
      self.labels[i]:delete()
   end
end

-->====================[ Input Handling ]====================<--

function PanelToggleButton:pressed()
   self.root:update()
   self.toggle = not self.toggle
   self.root:setSelectState(true)
   self.ON_TOGGLE:invoke(self.toggle)
   self.ON_PRESS:invoke(self)
end

function PanelToggleButton:released()
   self.root:update()
   self.root:setSelectState(false)
   self.ON_RELEASE:invoke(self)
end

return PanelToggleButton