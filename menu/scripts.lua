local panel = require("libraries.panel")

local menu = panel:newPage()


local paths = listFiles("scripts")

   for key, path in pairs(paths) do
      local name = ""
      for i = #path, 1, -1 do
         local char = path:sub(i,i)
         if char == "." then break end
         name = char .. name
      end
   ---@type macroScript
   
   config:setName("GN Macros States")
   local script = require(path)
   local state = config:load(script.namespace)
   if not state then state = false end

   menu:newElement("toggleButton"):setToggle(state):setText(name).ON_TOGGLE:register(function (toggle)
      script:setActive(toggle)
   end)
end

menu:newElement("returnButton")

return menu