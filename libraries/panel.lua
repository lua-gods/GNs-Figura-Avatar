--[[______   __
  / ____/ | / /
 / / __/  |/ /
/ /_/ / /|  /
\____/_/ |_/ ]]
if not host:isHost() then return end
---@diagnostic disable: undefined-field


local kitkat = require("libraries.KattEventsAPI")

---@class PanelRoot
local panel = {
   VSILIBILITY_CHANGED = kitkat.newEvent(false),
   SELECTED_CHANGED = kitkat.newEvent(),
   RENDER_UPDATE = kitkat.newEvent(),
   scroll_dir = 0,
   selected_index = 1,
   visible = false,
   is_pressed = false,
   current_page = nil,
   page_tree = {},
   elements = { -- static anotation support :(
      --button = require("libraries.panel_elements.button"),
      --slider = require("libraries.panel_elements.slider"),
      --textEdit = require("libraries.panel_elements.textEdit"),
      --toggleButton = require("libraries.panel_elements.toggleButton"),
   },

   config = {
      hud = nil,
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

---sets the model part on where to render the menu at
---@param model_part ModelPart
---@return PanelRoot
function panel:setModelpart(model_part)
   model_part:setParentType("HUD")
   panel.config.hud = model_part
   return panel
end

function panel:setPage(page)
   if not page then error("Page Given missing",2) end
   if page ~= self.current_page then
      panel.selected_index = #page.elements
      page.ON_ENTER:invoke()
      self:clearTasks()
      panel.is_pressed = false
      if self.last_page then
         self.last_page.ON_EXIT:invoke()
      end
      self.last_page = self.current_page
      self.current_page = page
      table.insert(self.page_tree,page)
      self:rebuild()
   end
   return self
end

function panel:returnToLastPage()
   if #self.page_tree > 1 then
      table.remove(self.page_tree,#self.page_tree)
      panel:setPage(self.page_tree[#self.page_tree])
      table.remove(self.page_tree,#self.page_tree)
   end
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
   sounds:playSound(sound,client:getCameraPos()+vectors.vec3(0,1,0),volume,pitch)
end

function panel:setSelectState(selected)
   self.is_pressed = selected
   if selected then
      panel.UIplaySound(panel.config.theme.sounds.select.id,panel.config.theme.sounds.select.pitch,panel.config.theme.sounds.select.volume)
   else
      panel.UIplaySound(panel.config.theme.sounds.deselect.id,panel.config.theme.sounds.deselect.pitch,panel.config.theme.sounds.deselect.volume)
   end
   panel:update()
end

for _, path in pairs(listFiles("libraries/panel_elements",false)) do
   local name = ""
   for i = #path, 1, -1 do
      local c = path:sub(i,i)
      if c == "." then break end
      name = c..name
   end
   panel.elements[name] = require(path)
end

-->====================[ API ]====================<--

---@class PaneldPage
---@field elements table
---@field default integer
---@field ON_ENTER KattEvent
---@field ON_EXIT KattEvent
---@field name string
local PanelPage = {}
PanelPage.__index = PanelPage
PanelPage.__type = "panelpage"

function panel:newPage()
   ---@type PaneldPage
   local compose = {
      elements = {},
      default = 1,
      ON_ENTER = kitkat.newEvent(),
      ON_EXIT = kitkat.newEvent(),
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
   return self
end

function PanelPage:appendElements(tabl)
   for key, value in pairs(tabl) do
      table.insert(self.elements,value)
   end
   return self
end

function PanelPage:clearAllEmenets()
   self.elements = {}
   return self
end

-->====================[ Input Handler ]====================<--

events.KEY_PRESS:register(function (key,status,modifier)
   if status == 1 then
      if panel.visible and key == 256 then
         if panel.visible and not panel.is_pressed then
            panel:setVisible(false)
         end
         return true
      end
   end
end)


panel.config.select.press = function ()
   if panel.visible and panel.current_page then
      local element = panel.current_page.elements[panel.selected_index]
      element:pressed()
   end
   if not panel.visible then panel:setVisible(true) end
   return true
end


panel.config.select.release = function ()
   if panel.visible and panel.is_pressed then
      local element = panel.current_page.elements[panel.selected_index]
      element:released()
   end
end

events.MOUSE_SCROLL:register(function (dir)
   if not panel.current_page then return end
   if panel.visible then
      dir = -math.floor(dir + 0.5)
      if not panel.is_pressed then
         panel.selected_index = math.clamp(panel.selected_index + dir,1,#panel.current_page.elements)
         panel.SELECTED_CHANGED:invoke(panel.selected_index)
         panel.scroll_dir = dir
         if panel.current_page and panel.current_page.elements[panel.selected_index] then
            if panel.current_page.elements[panel.selected_index].hover then
               local r = panel.current_page.elements[panel.selected_index].hover(panel.current_page.elements[panel.selected_index],panel)
               if type(r) == "number" then
                  panel.selected_index = math.clamp(r,1,#panel.current_page.elements)
               end
            end
         end
         panel:update()
      end
   end
   return panel.visible
end)

-->====================[ Renderer ]====================<--
events.WORLD_RENDER:register(function (delta)

   if panel.current_page then
      if panel.queue_rebuild then
         panel.queue_rebuild = false
         panel:clearTasks()
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
            local glow = (panel.selected_index == i and not panel.is_pressed)
            local state = "normal"            
            if i == panel.selected_index then
               if panel.is_pressed then
                  state = "active" else
                  state = "hover"
               end
            end
            local labels = element:update(vectors.vec2(0,-1),vectors.vec2(95,(math.min(#panel.current_page.elements,client:getScaledWindowSize().y/20)-i+1)*10),state)
            if not labels then
               error("Element labels not returned")
            end
            for _, l in pairs(labels) do
               if glow then
                  l:setDefaultColorRGB(1,1,1)
                  l:setOutlineColorRGB(0.2,0.2,0.2)
               else
                  l:setDefaultColorRGB(0.6,0.6,0.6)
                  l:setOutlineColorRGB(0,0,0)
               end
               if element.color and not l.color then
                  l:setColorRGB(element.color:unpack())
               end
            end
         end
      end
   end
end)
return panel