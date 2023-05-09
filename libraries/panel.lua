--[[______   __
  / ____/ | / /
 / / __/  |/ /
/ /_/ / /|  /
\____/_/ |_/ ]]
if not host:isHost() then return end
---@diagnostic disable: undefined-field

local config = {
   hud = models.menu,
   line_height = 11,
   select = keybinds:newKeybind("Panel Select","key.keyboard.grave.accent",false)
}

local kitkat = require("libraries.KattEventsAPI")

local panel = {
   VSILIBILITY_CHANGED = kitkat.newEvent(false),
   SELECTED_CHANGED = kitkat.newEvent(),
   RENDER_UPDATE = kitkat.newEvent(),

   selected = 1,
   visible = false,
   interacting = false,
   current_page = nil,

   update_queue = false,
   reload_queue = false,
}

function panel:setPage(page)
   self.current_page = page
   self.reload_queue = true
end

function panel:update()
   panel.update_queue = true
end

-->====================[ API ]====================<--

---@class PaneldPage
---@field elements table
---@field default integer
---@field name string
local PanelPage = {}
PanelPage.__index = PanelPage
PanelPage.__type = "panelpage"

function panel:newPage()
   ---@type PaneldPage
   local compose = {
      elements = {},
      default = 1,
      name = "Unnamed Page",
   }
   setmetatable(compose,PanelPage)
   return compose
end

function PanelPage:setDefault(indx)
   panel.default = indx
   self.update_queue = true
   return self
end

function PanelPage:setName(name)
   self.name = name
   panel:update()
   return self
end

function PanelPage:forceUpdate()
   panel:update()
   return self
end


---@alias InputEvent string
---| "BUTTON_DOWN"
---| "BUTTON_UP"
---| "SCROLL_UP"
---| "SCROLL_DOWN"

---@class PanelButton
---@field text string
---@field input function
local PanelButton = {}
PanelButton.__index = PanelButton
PanelButton.__type = "panelbutton"

function PanelPage:newButton(text)
   ---@PanelButton
   local compose = {
      text = text,
      input = nil,
   }
   setmetatable(compose,PanelButton)
   panel:update()
   table.insert(self.elements,compose)
   return self
end

function PanelButton:setText(text)
   self.text = text
   panel:update()
   return self
end

function PanelButton:inputListener(func)
   self.input = func
   panel:update()
   return self
end

-->==========[ Text Input ]==========<--
---@class PanelTextEdit
---@field text string
---@field input function
local PanelTextEdit = {}
PanelTextEdit.__index = PanelTextEdit
PanelTextEdit.__type = "paneltextedit"

function PanelPage:newTextEdit(placeholder)
   ---@PanelTextEdit
   local compose = {
      text = "",
      placeholder = placeholder,
      input = nil,
   }
   setmetatable(compose,PanelTextEdit)
   panel:update()
   table.insert(self.elements,compose)
   return self
end

function PanelTextEdit:setText(text)
   self.text = text
   panel:update()
   return self
end

function PanelTextEdit:inputListener(func)
   self.input = func
   panel:update()
   return self
end

-->====================[ Renderer ]====================<--
config.hud:setParentType("Hud")

local taskLines = {}

events.WORLD_RENDER:register(function (delta)
   local pos = client:getScaledWindowSize()/vec(-2,-1) + vec(-96,12)
   config.hud:setPos(pos.x,pos.y,-400)
   if panel.current_page then
      if panel.reload_queue then
         panel.reload_queue = false
         for _, value in pairs(taskLines) do
            for key, names in pairs(value) do
               config.hud:removeTask(names)
            end
         end
         taskLines = {}
         if panel.visible then
            for i, e in pairs(panel.current_page.elements) do
               local names = {}
               local typ = type(e)
               if typ == "panelbutton" then
                  config.hud:newText(i):text(e.text):outline(true):pos(0,(i-1) * config.line_height)
                  table.insert(names,i)
               elseif typ == "paneltextedit" then
                  config.hud:newText(i.."text"):text(e.text):outline(true):pos(0,(i-1) * config.line_height)
                  config.hud:newText(i.."underline"):text('{"text":"____________________","underlined":true}'):outline(true):pos(0,(i-1) * config.line_height - 1)
                  table.insert(names,i.."underline")
                  table.insert(names,i.."text")
               end
               table.insert(taskLines,names)
            end
         end
      elseif panel.update_queue then
         for i, value in pairs(taskLines) do
            local element = panel.current_page.elements[i]
            local typ = type(element)
            if typ == "panelbutton" then
               if i == panel.selected then
                  config.hud:getTask(value[1]):text('{"color":"white","text":"'..element.text..'"}')
               else
                  config.hud:getTask(value[1]):text('{"color":"gray","text":"'..element.text..'"}')
               end
            elseif typ then
               if panel.interacting then
                  local disp = ""
                  for l = string.len(element.text), 1, -1 do
                     disp = element.text:sub(l,l)..disp
                     if client.getTextWidth(disp) > 115 then
                        break
                     end
                  end
                  config.hud:getTask(value[2]):text(disp.."|")
               else
                  if element.text == "" then
                     config.hud:getTask(value[2]):text("§7"..element.placeholder)
                  else
                     if i == panel.selected then
                        config.hud:getTask(value[2]):text('{"color":"white","text":"'..element.text..'"}')
                     else
                        config.hud:getTask(value[2]):text('{"color":"gray","text":"'..element.text..'"}')
                     end
                  end
               end
               
               if i == panel.selected then
                  config.hud:getTask(value[1]):text('{"text":"____________________","underlined":true}')
               else
                  config.hud:getTask(value[1]):text('{"color":"gray","text":"____________________","underlined":true}')
               end
            end
         end
      end
   end
end)

-->====================[ Input Handler ]====================<--

config.select.press = function ()
   if not panel.visible then panel.visible = true end
   panel.reload_queue = true
   local c = panel.current_page.elements[panel.selected]
   if type(c) == "paneltextedit" then
      panel.interacting = true
   end
   return true
end

events.MOUSE_SCROLL:register(function (dir)
   panel.selected = (panel.selected + dir - 1) % #panel.current_page.elements + 1
   panel.SELECTED_CHANGED:invoke(panel.selected)
   panel:update()
   return panel.visible
end)

local lookup = {[32]=" ",
[39]="'",
[44]=",",
[45]="-",
[46]=".",
[47]="/",
[48]="0",
[49]="1",
[50]="2",
[51]="3",
[52]="4",
[53]="5",
[54]="6",
[55]="7",
[56]="8",
[57]="9",
[59]=";",
[61]="=",
[65]="A",
[66]="B",
[67]="C",
[68]="D",
[69]="E",
[60]="F",
[62]="H",
[71]="G",
[73]="I",
[74]="J",
[75]="K",
[76]="L",
[77]="M",
[78]="N",
[79]="O",
[70]="F",
[81]="Q",
[72]="H",
[80]="P",
[82]="R",
[83]="S",
[84]="T",
[85]="U",
[86]="V",
[87]="W",
[88]="X",
[89]="Y",
[90]="Z",
[92]="\\",
[93]="]",
[96]="`"}

events.KEY_PRESS:register(function (key,status,modifier)
   local c = panel.current_page.elements[panel.selected]
   if status == 1 then    
      if type(c) == "paneltextedit" and panel.interacting then
         if key == 259 then
            c.text = string.sub(c.text,1,string.len(c.text)-1)
         elseif lookup[key] then
            if modifier == 1 then
               c.text = c.text..lookup[key]
            else
               c.text = c.text..string.lower(lookup[key])
            end
         end
         if key == 256 then
            panel.interacting = false
            panel:update()
         end
         return true
      end
   end
end)

return panel