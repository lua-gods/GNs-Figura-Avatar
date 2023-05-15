local panel = require("libraries.panel")
if not panel then return end
local main_panel = panel:newPage()
main_panel:newElement("button"):setText("yo")
main_panel:newElement("button"):setText("yo")
main_panel:newElement("button"):setText("yo")
main_panel:newElement("button"):setText("yo")
main_panel:newElement("button"):setText("yo")
main_panel:newElement("button"):setText("yo")
main_panel:newElement("button"):setText("yo")
main_panel:newElement("button"):setText("I do literally nothing")
--main_panel:newTextEdit("insert credit card info")

panel:setPage(main_panel)