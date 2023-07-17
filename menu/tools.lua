local panel = require("libraries.panel")
local page = panel:newPage()

require("menu.tools.teslacoul")(page)
require("menu.tools.pen")(page)
page:newElement("textEdit"):setPlaceholderText("IP address here")
page:newElement("slider")
page:newElement("toggleButton"):setText("Hello WOrld")
page:newElement("button"):setText("Projection").ON_PRESS:register(function ()
   panel:setPage(require("menu.tools.projection"))
end)

page:newElement("returnButton")

return page