--[[______   __                _                 __
  / ____/ | / /___ _____ ___  (_)___ ___  ____ _/ /____  _____
 / / __/  |/ / __ `/ __ `__ \/ / __ `__ \/ __ `/ __/ _ \/ ___/
/ /_/ / /|  / /_/ / / / / / / / / / / / / /_/ / /_/  __(__  )
\____/_/ |_/\__,_/_/ /_/ /_/_/_/ /_/ /_/\__,_/\__/\___/____]]

local kb = {}

local og = keybinds

keybinds = {
   fromVanilla = keybinds.fromVanilla,
   getKeybinds = keybinds.getKeybinds,
   getVanillaKey = keybinds.getVanillaKey,
   newKeybind = keybinds.newKeybind,
   of = keybinds.of,
}
local config_path = avatar:getName()..".keybinds"

events.TICK:register(function ()
   config:setName(config_path)
   for key, value in pairs(kb) do
      if value.key ~= value.keybind:getKey() then
         local new = value.keybind:getKey()
         config:save(value.keybind:getName(),new)
         value.key = new
      end
   end
end)

---Creates a new Keybind
---@param name string
---@param key Minecraft.keyCode?
---@param gui boolean?
local new = function (self,name, key, gui)
   config:setName(config_path)
   local k = config:load(name)
   local new
   if k then
      new = og:newKeybind(name,k,gui)
   else
      new = og:newKeybind(name,key,gui)
   end
   table.insert(kb,{keybind = new, key = key})
   return new
end
keybinds.newKeybind = new
keybinds.of = new