local panel = require("libraries.panel")

local menu = panel:newPage()
menu:newElement("button"):setText("Wardrobe").ON_PRESS:register(function ()
   panel:setPage(require("menu.wardrobe"))
end)
menu:newElement("button"):setText("Macros").ON_PRESS:register(function ()
   panel:setPage(require("menu.macros"))
end)
menu:newElement("slider"):setText("Example"):setItemCount(10)
return menu