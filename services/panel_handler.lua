local panel = require("libraries.panel")

local main_panel = panel:newPage()
main_panel:newButton("Testing Button 1")
main_panel:newButton("I do literally nothing")
main_panel:newTextEdit("insert credit card info")

panel:setPage(main_panel)