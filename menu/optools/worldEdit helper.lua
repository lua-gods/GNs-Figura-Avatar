local panel = require("libraries.panel")
local page = panel:newPage()

page:newElement("button"):setText("//set <held item>").ON_PRESS:register(function ()
   host:sendChatCommand("//set " .. player:getHeldItem().id)
end)
page:newElement("returnButton")

return page