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

-->====================[ Task Handling ]====================<--

function PanelButton:rebuild(id)
   local l = label.newLabel()
   self.labels = {l}
end

function PanelButton:update(state,anchor,offset)
   self.labels[1]:setText(self.root:text2jsonTheme(self.text,state)):setAnchor(anchor):setOffset(offset)
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