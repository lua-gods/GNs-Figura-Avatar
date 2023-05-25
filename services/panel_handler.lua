local panel = require("libraries.panel")
if not panel then return end

local main_panel = panel:newPage()
local canvas_panel = panel:newPage()
canvas_panel:newElement("button"):setText("Return").ON_PRESS:register(function ()
   panel:setPage(main_panel)
end)
canvas_panel:newElement("button"):setText("Place Canvas")




--main_panel:newElement("button"):setText("I do literally nothing")
--main_panel:newElement("button"):setText("I do literally nothing")
--main_panel:newElement("button"):setText("I do literally nothing")
--main_panel:newElement("button"):setText("I do literally nothing")
--main_panel:newElement("button"):setText("I do literally nothing")
--main_panel:newElement("button"):setText("I do literally nothing")
--main_panel:newElement("button"):setText("I do literally nothing")
--main_panel:newElement("button"):setText("I do literally nothing")
--main_panel:newElement("button"):setText("I do literally nothing")
--main_panel:newElement("button"):setText("I do literally nothing")
--   main_panel:newElement("button"):setText("I do literally nothing")
--main_panel:newElement("textEdit")
--main_panel:newElement("button"):setText("Canvas").ON_PRESS:register(function ()
--   panel:setPage(canvas_panel)
--end)

panel:setPage(require("menu.root"))