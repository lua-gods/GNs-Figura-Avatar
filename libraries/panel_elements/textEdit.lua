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
      tasks = {},
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

---@param id integer -- line number
function panelTextEdit:rebuild(id,pos)
   self.root.config.hud:newText("panel.TextEdit."..id):outline(true):pos(pos.x,pos.y,0)
   self.root.config.hud:newText("panel.TextEdit.underline.1."..id):outline(true):pos(pos.x,pos.y,0):text(("_"):rep(self.width))
   self.root.config.hud:newText("panel.TextEdit.underline.2."..id):outline(true):pos(pos.x+1,pos.y,0):text(("_"):rep(self.width))
   self.root.config.hud:newText("panel.TextEdit.cursor."..id):outline(true):pos(pos.x+1,pos.y,0):text(("_"):rep(self.width))
   self.tasks = {"panel.TextEdit."..id,"panel.TextEdit.underline.1."..id,"panel.TextEdit.underline.2."..id,"panel.TextEdit.cursor."..id}
end

---@param state PanelElementState
function panelTextEdit:update(state,pos)
   self.root.config.hud:getTask(self.tasks[1]):text(self.root.config.theme.style[state]:gsub("${TEXT}",'"'..self.text..'"'))
   self.root.config.hud:getTask(self.tasks[2]):text(self.root.config.theme.style[state]:gsub("${TEXT}",'"'..("_"):rep(self.width)..'"'))
   self.root.config.hud:getTask(self.tasks[3]):text(self.root.config.theme.style[state]:gsub("${TEXT}",'"'..("_"):rep(self.width)..'"'))
   if state == "active" then
      self.root.config.hud:getTask(self.tasks[4]):text(self.root.config.theme.style[state]:gsub("${TEXT}",'"|"')):pos(pos.x-client.getTextWidth(self.text),pos.y,0)
   else
      self.root.config.hud:getTask(self.tasks[4]):text("")
   end
end

function panelTextEdit:clearTasks()
   for _, name in pairs(self.tasks) do
      self.root.config.hud:removeTask(name)
   end
end

-->========================================[ Input Handling ]=========================================<--

function panelTextEdit:pressed()
   self.root:update()
   self.root:setSelectState(not self.root.selected)
   self.ON_PRESS:invoke(self)
end

local k2s = require("libraries.key2stringLib")

events.KEY_PRESS:register(function (key,status,modifier)
   ---@type paneltextedit
   local current = root.current_page.elements[root.hovering]
   if type(current) == "paneltextedit" then
      if root and root.selected then
         if status == 1 then
               local char = k2s.key2string(key,modifier)
               if char then
                  current.text = current.text .. char
               elseif key == 259 then -- backspace
                  current.text = current.text:sub(1,#current.text-1)
               elseif key == 257 then -- enter
                  current.confirmed_text = current.text
                  root:setSelectState(false)
                  current.ON_TEXT_CONFIRM:invoke(current)
               end
               root:update()
               return true
            else
               if key == 256 then
                  if not current.confirmed_text then
                     current.text = current.confirmed_text
                     
                     current.text = ""
                  end
                  root:setSelectState(false)
                  current.ON_TEXT_DECLINE:invoke(current)
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