--[[______   __
  / ____/ | / /
 / / __/  |/ /
/ /_/ / /|  /
\____/_/ |_/ ]]
if not host:isHost() then return end
---@diagnostic disable: undefined-field

local k2s = require("libraries.key2stringLib")


local kitkat = require("libraries.KattEventsAPI")

---@class PanelRoot
local panel = {
   VSILIBILITY_CHANGED = kitkat.newEvent(false),
   SELECTED_CHANGED = kitkat.newEvent(),
   RENDER_UPDATE = kitkat.newEvent(),

   hovering = 1,
   visible = false,
   selected = false,
   current_page = nil,
   element_types = {},

   config = {
      hud = models.menu,
      line_height = 11,
      select = keybinds:newKeybind("Panel Select","key.keyboard.grave.accent",false),
      theme = {
         sounds = {
            
            hover={id="minecraft:entity.glow_item_frame.rotate_item",pitch=1,volume=1},
            select={id="minecraft:block.wooden_button.click_on",pitch=1.1,volume=0.3},
            deselect={id="minecraft:block.wooden_button.click_off",pitch=0.9,volume=0.3},
            intro={id="minecraft:block.note_block.hat",pitch=1.5,volume=1},
            outro={id="minecraft:block.note_block.hat",pitch=1.3,volume=1},
         },
         style = {
            normal = '{"text":${TEXT},"color":"gray"}',
            hover = '{"text":${TEXT},"color":"white"}',
            active = '{"text":${TEXT},"color":"green"}',
            disabled = '{"text":${TEXT},"color":"dark_gray"}',
         }
      },
   },
   queue_update = false,
   queue_rebuild = false
}

function panel:setPage(page)
   self.current_page = page
   self:rebuild()
end

function panel:update()
   self.queue_update = true
end

function panel:rebuild()
   self.queue_rebuild = true
end

for _, path in pairs(listFiles("libraries/panel_elements",false)) do
   local name = ""
   for i = #path, 1, -1 do
      local c = path:sub(i,i)
      if c == "." then break end
      name = c..name
   end
   panel.element_types[name] = require(path)
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

function PanelPage:newElement(type)
   if panel.element_types[type] then
      local element = panel.element_types[type].new(panel)
      table.insert(self.elements,element)
      return element
   end
end


-->==========[ Text Input ]==========<--
---@class PanelTextEdit
---@field text string
---@field width number
---@field input function
---@field ON_TEXT_CHANGE KattEvent
---@field ON_TEXT_CONFIRM KattEvent
---@field ON_TEXT_DECLINE KattEvent
local PanelTextEdit = {}
PanelTextEdit.__index = PanelTextEdit
PanelTextEdit.__type = "paneltextedit"

function PanelPage:newTextEdit(placeholder)
   ---@PanelTextEdit
   local compose = {
      text = "",
      last_text = "",
      display_text = "",
      placeholder = placeholder,
      input = nil,
      width = 20,
      _pxwidth = 120,
      ON_TEXT_CHANGE = kitkat.newEvent(),
      ON_TEXT_CONFIRM = kitkat.newEvent(),
      ON_TEXT_DECLINE = kitkat.newEvent(),
   }
   setmetatable(compose,PanelTextEdit)
   panel:update()
   table.insert(self.elements,compose)
   return self
end

function PanelTextEdit:setText(text)
   self.text = text
   self.last_text = text
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

function PanelTextEdit:rebuild(id)
   panel.config.hud:newText(id.."text"):outline(true):pos(0,(id-1) * panel.config.line_height)
   panel.config.hud:newText(id.."underline"):outline(true):pos(0,(id-1) * panel.config.line_height - 1)
   panel.config.hud:newText(id.."underline2"):outline(true):pos(2,(id-1) * panel.config.line_height - 1)
   return {id.."underline",id.."underline2",id.."text"}
end

function PanelTextEdit:update(tasks)
   
end

-->==========[ Slider ]==========<--
---@class PanelSlider
---@field text string
---@field value number
---@field low number
---@field high number
---@field step number
---@field ON_VALUE_CHANGE KattEvent
local PanelSlider = {}
PanelSlider.__index = PanelSlider
PanelSlider.__type = "panelslider"

function PanelPage:newSlider(text,value,low,high,step)
   local compose = {
      text = text,
      value = value,
      low = low,
      high = high,
      step = step,
      ON_VALUE_CHANGE = kitkat.newEvent()
   }
   setmetatable(compose,PanelSlider)
   return compose
end

---@param sound Minecraft.soundID
---@param pitch number
---@param volume number
local function UIplaySound(sound,pitch,volume)
   sounds:playSound(sound,client:getCameraPos()+vectors.vec3(0,-1,0),volume,pitch)
end

-->====================[ Input Handler ]====================<--

local textedit_cursor_pos = 0

panel.config.select.press = function ()
   if panel.visible then
      UIplaySound(panel.config.theme.sounds.select.id,panel.config.theme.sounds.select.pitch,panel.config.theme.sounds.select.volume)
      local element = panel.current_page.elements[panel.hovering]
      element:pressed()
      if type(element) == "paneltextedit" then
         element.last_text = element.text
         panel.selected = true
         textedit_cursor_pos = #element.text
      end
   end
   if not panel.visible then panel.visible = true panel:rebuild() UIplaySound(panel.config.theme.sounds.intro.id,panel.config.theme.sounds.intro.pitch,panel.config.theme.sounds.intro.volume) end
   return true
end


panel.config.select.release = function ()
   if panel.visible and panel.selected then
      local element = panel.current_page.elements[panel.hovering]
      UIplaySound(panel.config.theme.sounds.deselect.id,panel.config.theme.sounds.deselect.pitch,panel.config.theme.sounds.deselect.volume)
      element:released()
   end
end

events.MOUSE_SCROLL:register(function (dir)
   if not panel.current_page then return end
   if panel.visible then
      if not panel.selected then
         UIplaySound(panel.config.theme.sounds.hover.id,panel.config.theme.sounds.hover.pitch,panel.config.theme.sounds.hover.volume)
         panel.hovering = (panel.hovering + dir - 1) % #panel.current_page.elements + 1
         panel.SELECTED_CHANGED:invoke(panel.hovering)
         panel:update()
      else
         if type(panel.current_page.elements[panel.hovering]) == "paneltextedit" then
            textedit_cursor_pos = math.clamp(textedit_cursor_pos + dir,0,#panel.current_page.elements[panel.hovering].text)
            panel:update()
         end
      end
   end
   return panel.visible
end)

events.KEY_PRESS:register(function (key,status,modifier)
   if not panel.current_page then return end
   local c = panel.current_page.elements[panel.hovering]
   local typ = type(c)
   if status == 1 then
      if typ == "paneltextedit" and panel.selected then
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
         if key == 257 then -- confirm
            panel.selected = false
            textedit_cursor_pos = 0
            panel:update()
            UIplaySound(panel.config.theme.sounds.deselect.id,panel.config.theme.sounds.deselect.pitch,panel.config.theme.sounds.deselect.volume)
         end
         if key == 256 then -- decline
            c.text = c.last_text
            textedit_cursor_pos = 0
            panel.selected = false
            panel:update()
            UIplaySound(panel.config.theme.sounds.deselect.id,panel.config.theme.sounds.deselect.pitch,panel.config.theme.sounds.deselect.volume)
         end
         return true
      end
      if key == 256 and panel.visible then -- exit edit mode
         panel.visible = false
         panel:rebuild()
         panel.selected = false
UIplaySound(panel.config.theme.sounds.outro.id,panel.config.theme.sounds.outro.pitch,panel.config.theme.sounds.outro.volume)
         return true
      end
   end
end)

-->====================[ Renderer ]====================<--
panel.config.hud:setParentType("Hud")

events.WORLD_RENDER:register(function (delta)
   local pos = client:getScaledWindowSize()/vec(-2,-1) + vec(-96,12)
   panel.config.hud:setPos(pos.x,pos.y,-400)

   if panel.current_page then
      if panel.queue_rebuild then
         panel.queue_rebuild = false
         panel:update()
         for i, element in pairs(panel.current_page.elements) do
            element:clearTasks()
         end
         if panel.visible then
            for i, element in pairs(panel.current_page.elements) do
               element:rebuild(i)
            end
         end
      elseif panel.queue_update and panel.visible then
         panel.queue_update = false
         for i, element in pairs(panel.current_page.elements) do
            if i == panel.hovering then
               if panel.selected then
                  element:update("active")
               else
                  element:update("hover")
               end
            else
               element:update("normal")
            end
            local typ = type(element)
            if typ == "paneltextedit" then
               if panel.selected then
                  local display_text = ""
                  local post_cursor_display_text = ""
                  local post_cursor = false
                  if textedit_cursor_pos == 0 then
                     display_text = panel.config.theme.style.textEdit.cursor
                  end
                  for l = string.len(element.text), 1, -1 do
                     if l == textedit_cursor_pos then
                        post_cursor = true
                        display_text = panel.config.theme.style.textEdit.cursor..display_text
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

                  panel.config.hud:getTask(element[3]):text(display_text)
               else
                  if element.text == "" then
                     panel.config.hud:getTask(element[3]):text(string.gsub(panel.config.theme.style.textEdit.normal,"${TEXT}",'"'..element.placeholder..'"'))
                  else
                     if i == panel.hovering then
                        if panel.selected then
                           panel.config.hud:getTask(element[3]):text(string.gsub(panel.config.theme.style.textEdit.active,"${TEXT}",'"'..element.display_text..'"'))
                        else
                           panel.config.hud:getTask(element[3]):text(string.gsub(panel.config.theme.style.textEdit.hover,"${TEXT}",'"'..element.display_text..'"'))
                        end
                     else
                        panel.config.hud:getTask(element[3]):text(string.gsub(panel.config.theme.style.textEdit.normal,"${TEXT}",'"'..element.display_text..'"'))
                     end
                  end
               end
               local underline = ("_"):rep(element.width)
               if i == panel.hovering then
                  panel.config.hud:getTask(element[1]):text(string.gsub(panel.config.theme.style.textEdit.hover,"${TEXT}",'"'..underline..'"'))
                  panel.config.hud:getTask(element[2]):text(string.gsub(panel.config.theme.style.textEdit.hover,"${TEXT}",'"'..underline..'"'))
               else
                  panel.config.hud:getTask(element[1]):text(string.gsub(panel.config.theme.style.textEdit.normal,"${TEXT}",'"'..underline..'"'))
                  panel.config.hud:getTask(element[2]):text(string.gsub(panel.config.theme.style.textEdit.normal,"${TEXT}",'"'..underline..'"'))
               end
            end
         end
      end
   end
end)

return panel