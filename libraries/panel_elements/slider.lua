---@class panelSlider
---@field root PanelRoot
---@field text string
---@field count integer
---@field selected integer
---@field ON_PRESS KattEvent
---@field ON_RELEASE KattEvent
---@field ON_SLIDE KattEvent
local panelSlider = {}
panelSlider.__index = panelSlider
panelSlider.__type = "panelslider"

local label = require("libraries.GNLabelLib")
local kitkat = require("libraries.KattEventsAPI")
local root = nil

-->========================================[ API ]=========================================<--

---@param panel PanelRoot
---@return panelSlider
function panelSlider.new(panel)
   ---@type panelSlider
   local compose = {
      root = panel,
      labels = {},
      text = "panelSlider",
      count = 5,
      selected = 1,
      ON_PRESS = kitkat.newEvent(),
      ON_RELEASE = kitkat.newEvent(),
      ON_SLIDE = kitkat.newEvent(),
   }
   root = panel
   setmetatable(compose,panelSlider)
   return compose
end


-->========================================[ Render Handling ]=========================================<--
function panelSlider:rebuild()
   local dots = {}
   for i = 1, self.count, 1 do
      dots[i] = label.newLabel()
   end
   self.labels = {label.newLabel()}
end

---@param state PanelElementState
---@param anchor Vector2
---@param offset Vector2
function panelSlider:update(state,anchor,offset)
   if state == "active" then
      local compose = "["
      for i = 1, self.count, 1 do
         if i == self.selected then
            compose = compose.."[•]"
         else
            compose = compose.." • "
         end
      end
      self.labels[1]:setText(self.root:text2jsonTheme(compose.."] " .. self.text,state)):setAnchor(anchor):setOffset(offset)
   else
      self.labels[1]:setText(self.root:text2jsonTheme("[] " .. self.text,state)):setAnchor(anchor):setOffset(offset)
   end
end

function panelSlider:clearTasks()
   if self.labels[1] then
      self.labels[1]:delete()
      self.labels[2]:delete()
      for i, l in pairs(self.labels[3]) do
         l:delete()
      end
      self.labels[4]:delete()
   end
end

function panelSlider:setText(text)
   self.text = text
   self.root:update()
   return self
end

---@param count integer
---@return panelSlider
function panelSlider:setItemCount(count)
   self.count = count
   self.root:update()
   return self
end

-->========================================[ Input Handling ]=========================================<--

function panelSlider:pressed()
   self.root:update()
   self.root:setSelectState(true)
   self.ON_PRESS:invoke(self)
end

function panelSlider:released()
   self.root:update()
   self.root:setSelectState(false)
   self.ON_RELEASE:invoke(self)
end

events.MOUSE_SCROLL:register(function (dir)
   if not root then return end
   ---@type panelSlider
   local current = root.current_page.elements[root.hovering]
   if type(current) == "panelslider" then
      if root and root.selected then
         current.selected = (current.selected - 1 + dir) % current.count + 1
         current.root:update()
         current.ON_SLIDE:invoke(current.selected)
         root.UIplaySound(root.config.theme.sounds.select.id,math.lerp(0.5,1.5,current.selected/current.count),root.config.theme.sounds.select.volume)
      end
   end
end)

return panelSlider