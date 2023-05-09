function pings.nameplateV(toggle)
   nameplate.ENTITY:visible(toggle)
end


if not host:isHost() then return end

PANEL = {
   lock_movement = false,
   enabled = false,
   selected = 1,
   viewing = nil
}


local panels = {}

for key, path in pairs(listFiles("panels",false)) do
   local name = ""
   for i = #path, 1, -1 do
      if path:sub(i,i) == "." then
         break
      end
      name = path:sub(i,i)..name
   end
   panels[name] = require(path)
end

local config = {
   keys = {},
   group = models.menu.HUD,
}

if player:getName() == "GNamimates" then
   config.keys.aw = keybinds:newKeybind(" ","key.keyboard.grave.accent",true,true)
   config.keys.aw.press = function ()
      if PANEL.enabled then
         local s = PANEL.viewing.selection[PANEL.selected]
         if type(s.onPress) == "function" then
            local result = s.onPress(s)
            PANEL.update()
         end
      else
         PANEL.selected = 1
         PANEL.enabled = true
         PANEL.loadScene("main_menu")
      end
      return true
   end
end

local value_task = nil
local tasks = {}

function PANEL.update()
   if PANEL.enabled then
      models.menu:setVisible(true)
      for key, text in pairs(tasks) do
         local value = PANEL.viewing.selection[key]
         if value.label then
            if key == PANEL.selected then
               text:text("§f "..value.label.."" )
            else
               text:text("§7"..value.label)
            end
         else
            text:text("")
         end
      end
      if PANEL.viewing.selection[PANEL.selected] then
         local value = PANEL.viewing.selection[PANEL.selected].value
         local val_type = type(value)
         if val_type == "function" then
            value_task:text("function")
         elseif val_type == "nil" then
            value_task:text("")
         elseif val_type == "boolean" then
            if value then
               value_task:text("'§aTrue'")
            else
               value_task:text("'§cFalse'")
            end
         elseif val_type == "string" then
            value_task:text(value)
         end
      end
   else
      models.menu:setVisible(false)
   end
end

function PANEL.loadScene(scene_name)
   local scene = panels[scene_name]
   if not scene then
      error("menu \""..scene_name.."\" dosent exist")
   end
   if PANEL.viewing then
      if type(PANEL.viewing.onClose) == "function" then
         PANEL.viewing.onClose()
      end
   end
   PANEL.viewing = scene
   if type(PANEL.viewing.onOpen) == "function" then
      PANEL.viewing.onOpen()
   end
   PANEL.selected = #scene.selection
   config.group:removeTask()
   tasks = {}
   
   for i = #scene.selection, 1, -1 do
      local new = config.group:newText(i):pos(0,i*10):outline(true):outlineColor(0.25,0.25,0.25)
      table.insert(tasks,new)
   end
   value_task = config.group:newText("value"):pos(83,35):outline(false)
   PANEL.update()
end

if PANEL.enabled then
   PANEL.loadScene("main_menu")
end


events.TICK:register(function()
   local pos = client:getScaledWindowSize()/vec(-2,-1) + vec(-93,16)
   models.menu:setPos(pos.x,pos.y,-400)
end)


events.MOUSE_SCROLL:register(function (dir)
   if PANEL.enabled and host:getScreen() == nil then
      --cmd_plt.selected = ((cmd_plt.selected + dir - 1) ) % #cmd_plt.viewing + 1
      local last_selected = PANEL.selected
      PANEL.selected = math.clamp(PANEL.selected - dir,1,#PANEL.viewing.selection)
      if not PANEL.viewing.selection[PANEL.selected].label then
         PANEL.selected = PANEL.selected + (math.abs(dir)/-dir)
      end
      if last_selected ~= PANEL.selected then
         PANEL.update()
         sounds:playSound("minecraft:entity.item_frame.add_item",client:getCameraPos()+vec(0,1,0),1,PANEL.selected/#PANEL.viewing.selection+1)
      end
      return true
   end
end)

return PANEL