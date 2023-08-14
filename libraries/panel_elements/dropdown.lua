---@type PanelRoot
local root
---@class panelDropdownSelection
---@field root PanelRoot
---@field text string
---@field selected integer
---@field selection table
---@field ON_PRESS KattEvent
---@field ON_RELEASE KattEvent
---@field ON_SLIDE KattEvent
---@field ON_CONFIRM KattEvent
local panelDropdownSelection = {}
panelDropdownSelection.__index = panelDropdownSelection
panelDropdownSelection.__type = "panelDropdownSelection"

local label = require("libraries.GNLabelLib")
local kitkat = require("libraries.KattEventsAPI")

-->========================================[ API ]=========================================<--

---@param panel PanelRoot
---@return panelDropdownSelection
function panelDropdownSelection.new(panel)
   root = panel
   ---@type panelDropdownSelection
   local compose = {
      root = panel,
      labels = {},
      text = "Unnamed Dropdown",
      selected = 1,
      selection = {},
      ON_PRESS = kitkat.newEvent(),
      ON_SLIDE = kitkat.newEvent(),
      ON_CONFIRM = kitkat.newEvent(),
      ON_RELEASE = kitkat.newEvent(),
   }
   setmetatable(compose,panelDropdownSelection)
   return compose
end

function panelDropdownSelection:setText(text)
   self.text = text
   return self
end

function panelDropdownSelection:setSelectionList(list)
   self.selection = list
   self.root:rebuild()
   return self
end

-->========================================[ Render Handling ]=========================================<--

function panelDropdownSelection:rebuild()
   self.labels = {label.newLabel(),label.newLabel(),label.newLabel()}
   if self.selection then
      for i = 1, #self.selection, 1 do
         self.labels[#self.labels + 1] = label.newLabel()
      end
   end
end

---@param state PanelElementState
---@param anchor Vector2
---@param offset Vector2
function panelDropdownSelection:update(anchor,offset,state)
   if state == "active" then
      self.labels[1]:setText("< "..self.text):setAnchor(anchor):setOffset(offset)
   else
      self.labels[1]:setText("> "..self.text):setAnchor(anchor):setOffset(offset)
   end

   for i, value in pairs(self.selection) do
      if state == "active" then
         if self.selected == i then
            self.labels[i+3]:setText(value.." <"):setAnchor(anchor):setOffset(84-client.getTextWidth(value),25+i*10):setColorRGB(1,1,1)
         else
            self.labels[i+3]:setText(value.." |"):setAnchor(anchor):setOffset(87-client.getTextWidth(value),25+i*10):resetColor()
         end
      else
         self.labels[i+3]:setText("")
      end
   end
   return self.labels
end

function panelDropdownSelection:clearTasks()
   for i, _ in pairs(self.labels) do
      self.labels[i]:delete()
   end
end

-->========================================[ Input Handling ]=========================================<--

function panelDropdownSelection:pressed()
   self.root:update()
   self.root:setSelectState(not self.root.is_pressed)
   if not self.root.is_pressed then
      self.ON_CONFIRM:invoke(self.selected)
   end
   self.ON_PRESS:invoke(self)
end

function panelDropdownSelection:released()
   self.root:update()
   self.ON_RELEASE:invoke(self)
end

events.MOUSE_SCROLL:register(function (dir)
   if not root or not root.current_page then return end
   ---@type panelDropdownSelection
   local current = root.current_page.elements[root.selected_index]
   if type(current) == "panelDropdownSelection" then
      if root and root.is_pressed then
         local ls = current.selected
         current.selected = math.clamp(current.selected + dir,1,#current.selection)
         current.root:update()
         current.ON_SLIDE:invoke(current.selected)
         if ls ~= current.selected then
            root.UIplaySound(root.config.theme.sounds.select.id,math.lerp(0.5,1.5,current.selected/#current.selection),root.config.theme.sounds.select.volume)
         end
      end
   end
end)

return panelDropdownSelection