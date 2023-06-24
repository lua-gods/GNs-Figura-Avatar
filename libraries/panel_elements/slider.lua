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
---@type PanelRoot
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

function panelSlider:setColorRGB(r,g,b)
   self.color = vectors.vec3(r,g,b)
   self.root:update()
   return self
end

function panelSlider:setColorHex(hex)
   self.color = vectors.hexToRGB(hex)
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

-->========================================[ Render Handling ]=========================================<--
function panelSlider:rebuild()
   self.labels = {label.newLabel()}
end

---@param state PanelElementState
---@param anchor Vector2
---@param offset Vector2
function panelSlider:update(anchor,offset,state)
   if state == "active" then
      local compose = ""
      for i = 1, self.count, 1 do
         if i == self.selected then
            compose = compose.."["..i.."]"
         else
            compose = compose.."•"
         end
      end
      self.labels[1]:setText(compose.." " .. self.text):setAnchor(anchor):setOffset(offset)
   else
      self.labels[1]:setText("["..self.selected.."] " .. self.text):setAnchor(anchor):setOffset(offset)
   end
   return self.labels
end

function panelSlider:clearTasks()
   self.labels[1]:delete()
end

function panelSlider:setText(text)
   self.text = text
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
   local current = root.current_page.elements[root.selected_index]
   if type(current) == "panelslider" then
      if root and root.is_pressed then
         current.selected = math.clamp(current.selected + dir,1,current.count)
         current.root:update()
         current.ON_SLIDE:invoke(current.selected)
         root.UIplaySound(root.config.theme.sounds.select.id,math.lerp(0.5,1.5,current.selected/current.count),root.config.theme.sounds.select.volume)
      end
   end
end)

return panelSlider