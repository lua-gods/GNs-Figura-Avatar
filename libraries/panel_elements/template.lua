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
function Template:rebuild(id)
   self.root.config.hud:newText("panel.template."..id):outline(true):pos(0,(id-1) * self.root.config.line_height)
   self.tasks = {"Template"..id}
end

---@param state PanelElementState
function Template:update(state)
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
   self.root.selected = true
   self.ON_PRESS:invoke()
end

function Template:released()
   self.root:update()
   self.root.selected = false
   self.ON_RELEASE:invoke()
end

return Template