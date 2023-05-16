---@class Template
---@field root PanelRoot
---@field ON_PRESS KattEvent
---@field ON_RELEASE KattEvent
local Template = {}
Template.__index = Template
Template.__type = "paneltemplate"

local kitkat = require("libraries.KattEventsAPI")

-->========================================[ API ]=========================================<--

---@param panel PanelRoot
---@return Template
function Template.new(panel)
   ---@type Template
   local compose = {
      root = panel,
      tasks = {},
      ON_PRESS = kitkat.newEvent(),
      ON_RELEASE = kitkat.newEvent(),
   }
   setmetatable(compose,Template)
   return compose
end

-->========================================[ Render Handling ]=========================================<--

---@param id integer -- line number
function Template:rebuild(id,pos)
   self.root.config.hud:newText("panel.template."..id):outline(true):pos(pos)
   self.tasks = {"panel.template."..id}
end

---@param state PanelElementState
---@param pos Vector3
function Template:update(state,pos)
   self.root.config.hud:getTask(self.tasks[1]):text(self.root.config.theme.style[state]:gsub("${TEXT}",'"'.."TEMPLATE"..'"'))
end

function Template:clearTasks()
   for _, name in pairs(self.tasks) do
      self.root.config.hud:removeTask(name)
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