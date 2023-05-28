local panel = require("libraries.panel")

local menu = panel:newPage()
menu:newElement("button"):setText("Wardrobe").ON_PRESS:register(function ()
   panel:setPage(require("menu.wardrobe"))
end)
menu:newElement("toggleButton")
menu:newElement("textEdit").ON_TEXT_CONFIRM:register(function (text)
   print("confirmed")
end)
menu:newElement("slider"):setText("Example"):setItemCount(10)
return menu