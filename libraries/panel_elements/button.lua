---@class PanelButton
---@field text string
---@field input function
---@field root PanelRoot
---@field ON_PRESS KattEvent
---@field ON_RELEASE KattEvent
local PanelButton = {}
PanelButton.__index = PanelButton
PanelButton.__type = "panelbutton"

local kitkat = require("libraries.KattEventsAPI")

-->====================[ API ]====================<--

function PanelButton.new(panel)
   ---@type PanelButton
   local compose = {
      root = panel,
      tasks = {},
      
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

function PanelButton:rebuild(id,pos)
   self.root.config.hud:newText("PanelButton"..id):outline(true):pos(pos)
   self.tasks = {"PanelButton"..id}
end

function PanelButton:update(state,pos)
   self.root.config.hud:getTask(self.tasks[1]):text(self.root.config.theme.style[state]:gsub("${TEXT}",'"'..self.text..'"'))
end

function PanelButton:clearTasks()
   for _, name in pairs(self.tasks) do
      self.root.config.hud:removeTask(name)
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