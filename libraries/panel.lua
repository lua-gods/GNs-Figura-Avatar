--[[______   __
  / ____/ | / /
 / / __/  |/ /
/ /_/ / /|  /
\____/_/ |_/ ]]
if not host:isHost() then return end
---@diagnostic disable: undefined-field

local k2s = require("libraries.key2stringLib")

local config = {
   hud = models.menu,
   line_height = 11,
   select = keybinds:newKeybind("Panel Select","key.keyboard.grave.accent",false),
   theme = {
      sounds = {
         hover={id="minecraft:block.note_block.hat",pitch=1,volume=1},
         select={id="minecraft:block.note_block.hat",pitch=0.9,volume=1},
         deselect={id="minecraft:block.note_block.hat",pitch=0.95,volume=1},
         intro={id="minecraft:block.note_block.hat",pitch=1.5,volume=1},
         outro={id="minecraft:block.note_block.hat",pitch=1.3,volume=1},
      },
      style = {
         button = {
            normal = '{"text":${TEXT},"color":"gray"}',
            hover = '{"text":${TEXT},"color":"white"}',
            active = '{"text":${TEXT},"color":"dark_gray"}',
            disabled = '{"text":${TEXT},"color":"dark_gray"}',
         },
         textEdit = {

            cursor = "|",

            normal = '{"text":${TEXT},"color":"gray"}',
            hover = '{"text":${TEXT},"color":"white"}',
            active = '{"text":${TEXT},"color":"green"}',
            disabled = '{"text":${TEXT},"color":"dark_gray"}',
         }
      }
   }
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

function panel.reload()
   panel.reload_queue = true
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

function PanelButton:onInput(func)
   self.input = func
end


-->==========[ Text Input ]==========<--
---@class PanelTextEdit
---@field text string
---@field width number
---@field input function
local PanelTextEdit = {}
PanelTextEdit.__index = PanelTextEdit
PanelTextEdit.__type = "paneltextedit"

function PanelPage:newTextEdit(placeholder)
   ---@PanelTextEdit
   local compose = {
      text = "",
      display_text = "",
      placeholder = placeholder,
      input = nil,
      width = 20,
      _pxwidth = 120,
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

function PanelTextEdit:setWidth(width)
   self.width = width
   self._pxwidth = client.getTextWidth(("_"):rep(width))
   panel:update()
   return self
end

-->====================[ Renderer ]====================<--
config.hud:setParentType("Hud")

local taskLines = {}
local textedit_cursor_pos = 0

events.WORLD_RENDER:register(function (delta)
   local pos = client:getScaledWindowSize()/vec(-2,-1) + vec(-96,12)
   config.hud:setPos(pos.x,pos.y,-400)
   if panel.current_page then
      if panel.reload_queue then
         panel.reload_queue = false
         panel:update()
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
                  config.hud:newText(i):outline(true):pos(0,(i-1) * config.line_height)
                  table.insert(names,i)
               
               elseif typ == "paneltextedit" then
                  config.hud:newText(i.."text"):outline(true):pos(0,(i-1) * config.line_height)
                  config.hud:newText(i.."underline"):outline(true):pos(0,(i-1) * config.line_height - 1)
                  config.hud:newText(i.."underline2"):outline(true):pos(2,(i-1) * config.line_height - 1)
                  table.insert(names,i.."underline")
                  table.insert(names,i.."underline2")
                  table.insert(names,i.."text")
               end
               table.insert(taskLines,names)
            end
         end
      elseif panel.update_queue then
         panel.update_queue = false
         for i, value in pairs(taskLines) do
            local element = panel.current_page.elements[i]
            local typ = type(element)
            if typ == "panelbutton" then
               if i == panel.selected then
                  config.hud:getTask(value[1]):text('{"color":"white","text":"'..element.text..'"}')
               else
                  config.hud:getTask(value[1]):text('{"color":"gray","text":"'..element.text..'"}')
               end
            elseif typ == "paneltextedit" then
               if panel.interacting then
                  local display_text = ""
                  local post_cursor_display_text = ""
                  local post_cursor = false
                  if textedit_cursor_pos == 0 then
                     display_text = config.theme.style.textEdit.cursor
                  end
                  for l = string.len(element.text), 1, -1 do
                     if l == textedit_cursor_pos then
                        post_cursor = true
                        display_text = config.theme.style.textEdit.cursor..display_text
                     end
                     if post_cursor then
                        post_cursor_display_text = element.text:sub(l,l)..post_cursor_display_text
                     end
                     display_text = element.text:sub(l,l)..display_text
                     if client.getTextWidth(post_cursor_display_text) > element._pxwidth * 0.5 and client.getTextWidth(display_text) > element._pxwidth then
                        break
                     end
                  end

                  local trimmed_display_text = ""
                  for e = 1, #display_text, 1 do
                     if client.getTextWidth(trimmed_display_text) > element._pxwidth then
                        break
                     end
                     trimmed_display_text = trimmed_display_text..display_text:sub(e,e)
                  end
                  display_text = trimmed_display_text

                  local unselect_text = ""
                  local is_overflow = false
                  for e = 1, #element.text, 1 do
                     if client.getTextWidth(unselect_text) > element._pxwidth then
                        is_overflow = true
                        break
                     end
                     unselect_text = unselect_text..element.text:sub(e,e)
                  end
                  if is_overflow then
                     unselect_text = unselect_text.."..."
                  end
                  element.display_text = unselect_text

                  config.hud:getTask(value[3]):text(display_text)
               else
                  if element.text == "" then
                     config.hud:getTask(value[3]):text(string.gsub(config.theme.style.textEdit.normal,"${TEXT}",'"'..element.placeholder..'"'))
                  else
                     if i == panel.selected then
                        if panel.interacting then
                           config.hud:getTask(value[3]):text(string.gsub(config.theme.style.textEdit.active,"${TEXT}",'"'..element.display_text..'"'))
                        else
                           config.hud:getTask(value[3]):text(string.gsub(config.theme.style.textEdit.hover,"${TEXT}",'"'..element.display_text..'"'))
                        end
                     else
                        config.hud:getTask(value[3]):text(string.gsub(config.theme.style.textEdit.normal,"${TEXT}",'"'..element.display_text..'"'))
                     end
                  end
               end
               local underline = ("_"):rep(element.width)
               if i == panel.selected then
                  config.hud:getTask(value[1]):text(string.gsub(config.theme.style.textEdit.hover,"${TEXT}",'"'..underline..'"'))
                  config.hud:getTask(value[2]):text(string.gsub(config.theme.style.textEdit.hover,"${TEXT}",'"'..underline..'"'))
               else
                  config.hud:getTask(value[1]):text(string.gsub(config.theme.style.textEdit.normal,"${TEXT}",'"'..underline..'"'))
                  config.hud:getTask(value[2]):text(string.gsub(config.theme.style.textEdit.normal,"${TEXT}",'"'..underline..'"'))
               end
            end
         end
      end
   end
end)

---@param sound Minecraft.soundID
---@param pitch number
---@param volume number
local function UIplaySound(sound,pitch,volume)
   sounds:playSound(sound,client:getCameraPos()+vectors.vec3(0,-1,0),volume,pitch)
end

-->====================[ Input Handler ]====================<--

---@alias InputEvent string
---| "BUTTON_DOWN"
---| "BUTTON_UP"
---| "SCROLL_UP"
---| "SCROLL_DOWN"

config.select.press = function ()
   if panel.visible then
      UIplaySound(config.theme.sounds.select.id,config.theme.sounds.select.pitch,config.theme.sounds.select.volume)
      local c = panel.current_page.elements[panel.selected]
      if c.input then
         c.input(c,"BUTTON_DOWN")
      end
      if type(c) == "paneltextedit" then
         panel.interacting = true
         textedit_cursor_pos = #c.text
      end
      panel:update()
   end
   if not panel.visible then panel.visible = true panel:reload() UIplaySound(config.theme.sounds.intro.id,config.theme.sounds.intro.pitch,config.theme.sounds.intro.volume) end
   return true
end

config.select.release = function ()
   panel:update()
   local c = panel.current_page.elements[panel.selected]
   if c.input then
      c.input(c,"BUTTON_UP")
   end
end

events.MOUSE_SCROLL:register(function (dir)
   if panel.visible then
      if not panel.interacting then
         UIplaySound(config.theme.sounds.hover.id,config.theme.sounds.hover.pitch,config.theme.sounds.hover.volume)
         panel.selected = (panel.selected + dir - 1) % #panel.current_page.elements + 1
         panel.SELECTED_CHANGED:invoke(panel.selected)
         panel:update()
      else
         if type(panel.current_page.elements[panel.selected]) == "paneltextedit" then
            textedit_cursor_pos = math.clamp(textedit_cursor_pos + dir,0,#panel.current_page.elements[panel.selected].text)
            panel:update()
         end
      end
   end
   return panel.visible
end)

events.KEY_PRESS:register(function (key,status,modifier)
   local c = panel.current_page.elements[panel.selected]
   local typ = type(c)
   if status == 1 then
      if typ == "paneltextedit" and panel.interacting then
         local keystring = k2s.key2string(key,modifier)
         if key == 259 then -- backspace
            c.text = string.sub(c.text,1,string.len(c.text)-1)
            textedit_cursor_pos = textedit_cursor_pos - 1
            panel:update()
         elseif keystring then
            c.text = c.text:sub(1,textedit_cursor_pos)..keystring..c.text:sub(1+textedit_cursor_pos,#c.text)
            textedit_cursor_pos = textedit_cursor_pos + 1
            panel:update()
         end
         if key == 256 or key == 257 then -- exit edit mode
            panel.interacting = false
            textedit_cursor_pos = 0
            panel:update()
            UIplaySound(config.theme.sounds.deselect.id,config.theme.sounds.deselect.pitch,config.theme.sounds.deselect.volume)
         end
         return true
      end
      if key == 256 and panel.visible then -- exit edit mode
         panel.visible = false
         panel.reload_queue = true
         panel.interacting = false
         UIplaySound(config.theme.sounds.outro.id,config.theme.sounds.outro.pitch,config.theme.sounds.outro.volume)
         return true
      end
   end
end)

return panel