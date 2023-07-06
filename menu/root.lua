local panel = require("libraries.panel")
local menu = panel:newPage()



menu:newElement("button"):setText("OP Tools").ON_PRESS:register(function ()
   panel:setPage(require("menu.optools"))
end)

menu:newElement("button"):setText("Tools").ON_PRESS:register(function ()
   panel:setPage(require("menu.tools"))
end)

menu:newElement("button"):setText("Wardrobe").ON_PRESS:register(function ()
   panel:setPage(require("menu.wardrobe"))
end)
menu:newElement("button"):setText("Emotes").ON_PRESS:register(function ()
   panel:setPage(require("menu.Emotes"))
end)

local dropdown = menu:newElement("dropdown"):setText("dropdown")
dropdown:setSelectionList({"Hello","World","I am GN","Nice to meet you"}) 


return menu