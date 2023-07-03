local panel = require("libraries.panel")
local page = panel:newPage()

require("menu.tools.sex")(page)
require("menu.tools.pen")(page)

page:newElement("button"):setText("Projection").ON_PRESS:register(function ()
   panel:setPage(require("menu.tools.projection"))
end)

page:newElement("returnButton")

return page