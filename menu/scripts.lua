local panel = require("libraries.panel")

local menu = panel:newPage()
local ret = menu:newElement("button")
ret:setText("Return to Menu").ON_PRESS:register(function () panel:returnToLastPage()end)
table.insert(menu,ret)

local paths = listFiles("scripts")

for key, path in pairs(paths) do
   local name = ""
   for i = #path, 1, -1 do
      local char = path:sub(i,i)
      if char == "." then break end
      name = char .. name
   end
   ---@type macroScript
   local script = require(path)
   menu:newElement("toggleButton"):setText(name).ON_TOGGLE:register(function (toggle)
      script.is_active = toggle
      if toggle then
         script.ENTER:invoke()
      else
         script.EXIT:invoke()
      end
   end)
end





return menu