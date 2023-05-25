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
   panel:clearTasks()
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
   if panel.current_page then
      for i, element in pairs(panel.current_page.elements) do
         element:clearTasks()
      end
   end
   return self
end

---@param sound Minecraft.soundID
---@param pitch number
---@param volume number
local function UIplaySound(sound,pitch,volume)
   sounds:playSound(sound,client:getCameraPos()+vectors.vec3(0,-1,0),volume,pitch)
end

function panel:setSelectState(selected)
   self.selected = selected
   if selected then
      UIplaySound(panel.config.theme.sounds.select.id,panel.config.theme.sounds.select.pitch,panel.config.theme.sounds.select.volume)
   else
      UIplaySound(panel.config.theme.sounds.deselect.id,panel.config.theme.sounds.deselect.pitch,panel.config.theme.sounds.deselect.volume)
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
   panel.element_types[name] = require(path)
end


---@alias PanelElementState string
---| "normal" -- element idle
---| "hover" -- selector on element
---| "active" -- element being pressed
---| "disabled" -- element disabled

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
   if not panel.visible then panel:setVisible(true) panel:rebuild() end
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
         UIplaySound(panel.config.theme.sounds.hover.id,panel.config.theme.sounds.hover.pitch,panel.config.theme.sounds.hover.volume)
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
            local tpos = vectors.vec3(0,(i-1) * panel.config.line_height,0)
            local state = "normal"            
            if i == panel.hovering then
               if panel.selected then
                  state = "active"
               else
                  state = "hover"
               end
            end
            element:update(state,vectors.vec2(0,-1),vectors.vec2(95,(#panel.current_page.elements-i+1)*10))
         end
      end
   end
end)

return panel