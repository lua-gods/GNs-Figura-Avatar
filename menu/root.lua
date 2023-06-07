local panel = require("libraries.panel")

local menu = panel:newPage()
menu:newElement("button"):setText("Wardrobe").ON_PRESS:register(function ()
   panel:setPage(require("menu.wardrobe"))
end)
menu:newElement("button"):setText("Scripts").ON_PRESS:register(function ()
   panel:setPage(require("menu.scripts"))
end)
return menu