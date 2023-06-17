---@class paneltextedit
---@field root PanelRoot
---@field width integer
---@field text string
---@field confirmed_text string
---@field placeholder string
---@field ON_PRESS KattEvent
---@field ON_RELEASE KattEvent
---@field ON_TEXT_CONFIRM KattEvent
---@field ON_TEXT_DECLINE KattEvent
local panelTextEdit = {}
panelTextEdit.__index = panelTextEdit
panelTextEdit.__type = "paneltextedit"

local label = require("libraries.GNLabelLib")
local kitkat = require("libraries.KattEventsAPI")

---@type PanelRoot
local root = nil

-->========================================[ API ]=========================================<--

---@param panel PanelRoot
---@return paneltextedit
function panelTextEdit.new(panel)
   root = panel
   ---@type paneltextedit
   local compose = {
      root = panel,
      labels = {},
      placeholder = "placeholder",
      conrfirmed_text = "",
      text = "",
      width = 16,
      ON_PRESS = kitkat.newEvent(),
      ON_RELEASE = kitkat.newEvent(),
      ON_TEXT_CONFIRM = kitkat.newEvent(),
      ON_TEXT_DECLINE = kitkat.newEvent(),
   }
   setmetatable(compose,panelTextEdit)
   return compose
end

-->========================================[ Render Handling ]=========================================<--

function panelTextEdit:rebuild()
   self.labels = {label.newLabel(),label.newLabel(),label.newLabel(),label.newLabel()}
end

---@param anchor Vector2
---@param offset Vector2
function panelTextEdit:update(anchor,offset,state)
   self.labels[1]:setText(self.text):setAnchor(anchor):setOffset(offset)
   self.labels[2]:setText(("_"):rep(self.width)):setAnchor(anchor):setOffset(offset)
   self.labels[3]:setText(("_"):rep(self.width)):setAnchor(anchor):setOffset(offset:add(2,0))
   if state == "active" then
      self.labels[4]:setText("|"):setAnchor(anchor):setOffset(offset.x+client.getTextWidth(self.text),offset.y)
   else
      self.labels[4]:setText("")
   end
   return self.labels
end

function panelTextEdit:clearTasks()
   for i, _ in pairs(self.labels) do
      self.labels[i]:delete()
   end
end

-->========================================[ Input Handling ]=========================================<--

function panelTextEdit:pressed()
   self.root:update()
   self.root:setSelectState(not self.root.is_pressed)
   self.ON_PRESS:invoke(self)
end

local k2s = require("libraries.key2stringLib")

events.KEY_PRESS:register(function (key,status,modifier)
   ---@type paneltextedit
   if not root then return end
   local current = root.current_page.elements[root.selected_index]
   if type(current) == "paneltextedit" then
      if root and root.is_pressed then
         if status == 1 then
               local char = k2s.key2string(key,modifier)
               if char then
                  current.text = current.text .. char
               elseif key == 259 then -- backspace
                  current.text = current.text:sub(1,#current.text-1)
               elseif key == 257 then -- enter
                  current.confirmed_text = current.text
                  root:setSelectState(false)
                  current.ON_TEXT_CONFIRM:invoke(current.confirmed_text)
               end
               root:update()
               return true
            else
               if key == 256 then
                  current.ON_TEXT_DECLINE:invoke(current.text)
                  if not current.confirmed_text then
                     current.text = current.confirmed_text
                     
                     current.text = ""
                  end
                  root:update()
                  root:setSelectState(false)
               end
            end
         end
      end
   end)

function panelTextEdit:released()
   self.root:update()
   self.ON_RELEASE:invoke(self)
end

return panelTextEdit