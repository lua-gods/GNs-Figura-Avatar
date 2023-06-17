local panel = require("libraries.panel")

local menu = panel:newPage()
menu:newElement("button"):setText("Status: Cringe"):setColorHex("00ff00").ON_PRESS:register(function ()
end)

menu:newElement("returnButton")
return menu