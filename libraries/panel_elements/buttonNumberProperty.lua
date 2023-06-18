---@class PanelButtonNumberPropertyEdit
---@field text string
---@field input function
---@field root PanelRoot
---@field ON_PRESS KattEvent
---@field ON_RELEASE KattEvent
local PanelButtonNumberPropertyEdit = {}
PanelButtonNumberPropertyEdit.__index = PanelButtonNumberPropertyEdit
PanelButtonNumberPropertyEdit.__type = "PanelButtonNumberPropertyEdit"

local label = require("libraries.GNLabelLib")
local kitkat = require("libraries.KattEventsAPI")

-->====================[ API ]====================<--

function PanelButtonNumberPropertyEdit.new(panel)
   ---@type PanelButtonNumberPropertyEdit
   local compose = {
      root = panel,
      labels = {},
      
      text = "Untitled Button",
      ON_PRESS = kitkat.newEvent(),
      ON_RELEASE = kitkat.newEvent()
   }
   setmetatable(compose,PanelButtonNumberPropertyEdit)
   return compose
end

function PanelButtonNumberPropertyEdit:setText(text)
   self.text = text
   self.root:update()
   return self
end

function PanelButtonNumberPropertyEdit:setColorRGB(r,g,b)
   self.color = vectors.vec3(r,g,b)
   return self
end

function PanelButtonNumberPropertyEdit:setColorHex(hex)
   self.color = vectors.hexToRGB(hex)
   return self
end

-->====================[ Task Handling ]====================<--

function PanelButtonNumberPropertyEdit:rebuild()
   self.labels = {label.newLabel()}
end

function PanelButtonNumberPropertyEdit:update(anchor,offset,state)
   self.labels[1]:setText(self.text):setAnchor(anchor):setOffset(offset)
   return self.labels
end

function PanelButtonNumberPropertyEdit:clearTasks()
   for i, _ in pairs(self.labels) do
      self.labels[i]:delete()
   end
end

-->====================[ Input Handling ]====================<--

function PanelButtonNumberPropertyEdit:pressed()
   self.root:update()
   self.root:setSelectState(true)
   self.ON_PRESS:invoke(self)
end

function PanelButtonNumberPropertyEdit:released()
   self.root:update()
   self.root:setSelectState(false)
   self.ON_RELEASE:invoke(self)
end

return PanelButtonNumberPropertyEdit