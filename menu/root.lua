local panel = require("libraries.panel")

local menu = panel:newPage()
menu:newElement("button"):setText("Entity NBT Editor").ON_RELEASE:register(function ()
   panel:setPage(require("menu.entitiyNbtEditor"))
end)
menu:newElement("button"):setText("Wardrobe").ON_PRESS:register(function ()
   panel:setPage(require("menu.wardrobe"))
end)
menu:newElement("button"):setText("Scripts").ON_PRESS:register(function ()
   panel:setPage(require("menu.scripts"))
end)
menu:newElement("button"):setText("End Gateway Generator").ON_PRESS:register(function ()
   panel:setPage(require("menu.endgateway"))
end)
return menu