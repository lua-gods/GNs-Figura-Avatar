local panel = require("libraries.panel")

local menu = panel:newPage()
menu:newElement("button"):setText("Wardrobe").ON_PRESS:register(function ()
   print("lol")
end)
return menu