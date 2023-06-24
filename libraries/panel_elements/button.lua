---@class PanelButton
---@field text string
---@field input function
---@field root PanelRoot
---@field ON_PRESS KattEvent
---@field ON_RELEASE KattEvent
local PanelButton = {}
PanelButton.__index = PanelButton
PanelButton.__type = "panelbutton"

local label = require("libraries.GNLabelLib")
local kitkat = require("libraries.KattEventsAPI")

-->====================[ API ]====================<--

function PanelButton.new(panel)
   ---@type PanelButton
   local compose = {
      root = panel,
      labels = {},
      
      text = "Untitled Button",
      ON_PRESS = kitkat.newEvent(),
      ON_RELEASE = kitkat.newEvent()
   }
   setmetatable(compose,PanelButton)
   return compose
end

function PanelButton:setText(text)
   self.text = text
   self.root:update()
   return self
end

function PanelButton:setColorRGB(r,g,b)
   self.color = vectors.vec3(r,g,b)
   self.root:update()
   return self
end

function PanelButton:setColorHex(hex)
   self.color = vectors.hexToRGB(hex)
   self.root:update()
   return self
end

-->====================[ Task Handling ]====================<--

function PanelButton:rebuild()
   self.labels = {label.newLabel()}
end

function PanelButton:update(anchor,offset,state)
   self.labels[1]:setText(self.text):setAnchor(anchor):setOffset(offset)
   return self.labels
end

function PanelButton:clearTasks()
   for i, _ in pairs(self.labels) do
      self.labels[i]:delete()
   end
end

-->====================[ Input Handling ]====================<--

function PanelButton:pressed()
   self.root:update()
   self.root:setSelectState(true)
   self.ON_PRESS:invoke(self)
end

function PanelButton:released()
   self.root:update()
   self.root:setSelectState(false)
   self.ON_RELEASE:invoke(self)
end

return PanelButton