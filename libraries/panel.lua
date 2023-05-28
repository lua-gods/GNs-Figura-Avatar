--[[______   __
  / ____/ | / /
 / / __/  |/ /
/ /_/ / /|  /
\____/_/ |_/ ]]
if not H then return end
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
   elements = { -- static anotation support :(
      button = require("libraries.panel_elements.button"),
      slider = require("libraries.panel_elements.slider"),
      textEdit = require("libraries.panel_elements.textEdit"),
      toggleButton = require("libraries.panel_elements.toggleButton"),
   },

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
local built = false

---@alias PanelElementState string
---| "normal" -- element idle
---| "hover" -- selector on element
---| "active" -- element being pressed
---| "disabled" -- element disabled

---sets the theme for the given text
---@param text string
---@param style_name PanelElementState
---@return unknown
function panel:txt2theme(text,style_name)
   local f = panel.config.theme.style[style_name]:gsub("${TEXT}",'"'..text:gsub([[\]], [[\\]]):gsub([["]], [[\"]])..'"')
   return f
end

function panel:setPage(page)
   self:clearTasks()
   panel.hovering = 1
   self.current_page = page
   self:rebuild()
   return self
end

function panel:update()
   self.queue_update = true
   return self
end

function panel:rebuild()
   self.queue_rebuild = true
   return self
end

function panel:setVisible(visible)
   if self.visible ~= visible then
      self.visible = visible
      self:rebuild()
   end
   return self
end

function panel:clearTasks()
   if panel.current_page and built then
      for i, element in pairs(panel.current_page.elements) do
         element:clearTasks()
         built = false
      end
   end
   return self
end

---@param sound Minecraft.soundID
---@param pitch number
---@param volume number
function panel.UIplaySound(sound,pitch,volume)
   sounds:playSound(sound,client:getCameraPos()+vectors.vec3(0,-1,0),volume,pitch)
end

function panel:setSelectState(selected)
   self.selected = selected
   if selected then
      panel.UIplaySound(panel.config.theme.sounds.select.id,panel.config.theme.sounds.select.pitch,panel.config.theme.sounds.select.volume)
   else
      panel.UIplaySound(panel.config.theme.sounds.deselect.id,panel.config.theme.sounds.deselect.pitch,panel.config.theme.sounds.deselect.volume)
   end
   panel:update()
end

--for _, path in pairs(listFiles("libraries/panel_elements",false)) do
--   local name = ""
--   for i = #path, 1, -1 do
--      local c = path:sub(i,i)
--      if c == "." then break end
--      name = c..name
--   end
--   panel.elements[name] = require(path)
--end

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

---@deprecated
---@param type string
---@return PanelButton|PanelToggleButton|panelSlider|paneltextedit
function PanelPage:newElement(type)
   if panel.elements[type] then
      local element = panel.elements[type].new(panel)
      table.insert(self.elements,element)
      return element
   end
   return nil
end

---comment
function PanelPage:appendElement(instance)
   table.insert(self.elements,instance)
   return PanelPage
end

function PanelPage:appendElements(tabl)
   for key, value in pairs(tabl) do
      table.insert(self.elements,value)
   end
   return PanelPage
end

-->====================[ Input Handler ]====================<--

events.KEY_PRESS:register(function (key,status,modifier)
   if status == 1 then
      if panel.visible and key == 256 then
         if panel.visible and not panel.selected then
            panel:setVisible(false)
         end
         return true
      end
   end
end)


panel.config.select.press = function ()
   if panel.visible then
      local element = panel.current_page.elements[panel.hovering]
      element:pressed()
   end
   if not panel.visible then panel:setVisible(true) end
   return true
end


panel.config.select.release = function ()
   if panel.visible and panel.selected then
      local element = panel.current_page.elements[panel.hovering]
      element:released()
   end
end

events.MOUSE_SCROLL:register(function (dir)
   if not panel.current_page then return end
   if panel.visible then
      if not panel.selected then
         panel.UIplaySound(panel.config.theme.sounds.hover.id,panel.config.theme.sounds.hover.pitch,panel.config.theme.sounds.hover.volume)
         panel.hovering = (panel.hovering - dir - 1) % #panel.current_page.elements + 1
         panel.SELECTED_CHANGED:invoke(panel.hovering)
         panel:update()
      end
   end
   return panel.visible
end)

-->====================[ Renderer ]====================<--
panel.config.hud:setParentType("Hud")
events.WORLD_RENDER:register(function (delta)

   if panel.current_page then
      if panel.queue_rebuild then
         panel.queue_rebuild = false
         if built then
            built = false
            panel:clearTasks()
         end
         if panel.visible and not built then
            panel.queue_update = true
            for i, element in pairs(panel.current_page.elements) do
               element:rebuild()
            end
            built = true
         end
      elseif panel.queue_update and panel.visible and built then
         panel.queue_update = false
         for i, element in pairs(panel.current_page.elements) do
            local state = "normal"            
            if i == panel.hovering then
               if panel.selected then
                  state = "active" else
                  state = "hover"
               end
            end
            element:update(state,vectors.vec2(0,-1),vectors.vec2(101,(#panel.current_page.elements-i+1)*10))
         end
      end
   end
end)

return panel