local panel = require("libraries.panel")
local page = panel:newPage()

page:newElement("button"):setText("Builder").ON_PRESS:register(function ()
   panel:setPage(require("menu.optools.builder"))
end)

page:newElement("button"):setText("Scripts").ON_PRESS:register(function ()
   panel:setPage(require("menu.scripts"))
end)
page:newElement("button"):setText("End Gateway Generator").ON_PRESS:register(function ()
   panel:setPage(require("menu.optools.endgateway"))
end)
page:newElement("button"):setText("Message Fallback").ON_PRESS:register(function ()
   panel:setPage(require("menu.optools.chatfallback"))
end)

page:newElement("button"):setText("worldEdit Helper").ON_PRESS:register(function ()
   panel:setPage(require("menu.optools.worldEdit helper"))
end)



page:newElement("returnButton")

return page