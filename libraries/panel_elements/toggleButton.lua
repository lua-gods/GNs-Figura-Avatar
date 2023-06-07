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
-->====================[ Task Handling ]====================<--

function PanelToggleButton:rebuild(id)
   local l = label.newLabel()
   self.labels = {l}
end

function PanelToggleButton:update(state,anchor,offset)
   self.labels[1]:setAnchor(anchor):setOffset(offset)
   if self.toggle then
      self.labels[1]:setText(self.root:txt2theme("[-]"..self.text,state))
   else
      self.labels[1]:setText(self.root:txt2theme("[+]"..self.text,state))
   end
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