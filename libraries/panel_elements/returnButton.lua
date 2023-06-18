---@class ReturnPanelButton
---@field text string
---@field input function
---@field root PanelRoot
---@field ON_PRESS KattEvent
---@field ON_RELEASE KattEvent
local ReturnPanelButton = {}
ReturnPanelButton.__index = ReturnPanelButton
ReturnPanelButton.__type = "returnpanelbutton"

local label = require("libraries.GNLabelLib")
local kitkat = require("libraries.KattEventsAPI")

-->====================[ API ]====================<--

function ReturnPanelButton.new(panel)
   ---@type ReturnPanelButton
   local compose = {
      color = vectors.hexToRGB("#f5555d"),
      root = panel,
      labels = {},
      ON_PRESS = kitkat.newEvent(),
      ON_RELEASE = kitkat.newEvent()
   }
   setmetatable(compose,ReturnPanelButton)
   return compose
end

-->====================[ Task Handling ]====================<--

function ReturnPanelButton:rebuild()
   self.labels = {label.newLabel()}
end

function ReturnPanelButton:update(anchor,offset)
   self.labels[1]:setText("Return"):setAnchor(anchor):setOffset(offset)
   return self.labels
end

function ReturnPanelButton:clearTasks()
   self.labels[1]:delete()
end

-->====================[ Input Handling ]====================<--

function ReturnPanelButton:pressed()
   self.root:update()
   self.root:setSelectState(true)
   self.ON_PRESS:invoke(self)
end

function ReturnPanelButton:released()
   self.root:update()
   self.root:setSelectState(false)
   self.root:returnToLastPage()
   self.ON_RELEASE:invoke(self)
end

return ReturnPanelButton