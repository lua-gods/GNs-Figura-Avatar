---@class PanelMargin
local PanelMargin = {}
PanelMargin.__index = PanelMargin
PanelMargin.__type = "panelpanelargin"

-->========================================[ API ]=========================================<--

---@param panel PanelRoot
---@return PanelMargin
function PanelMargin.new(panel)
   ---@type PanelMargin
   local compose = {root = panel,}
   setmetatable(compose,PanelMargin)
   return compose
end

-->========================================[ Render Handling ]=========================================<--
function PanelMargin:rebuild()end
function PanelMargin:update(anchor,offset,state)return {}end
function PanelMargin:clearTasks()end
-->========================================[ Input Handling ]=========================================<--

function PanelMargin:hover()
   self.root:update()
   return self.root.selected_index + math.sign(self.root.scroll_dir)
end

return PanelMargin