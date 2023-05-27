local panel = require("libraries.panel")

local menu = panel:newPage()
local items = {
   panel.elements.slider.new(panel),
   panel.elements.button.new(panel),
   panel.elements.button.new(panel),
   panel.elements.button.new(panel),
   panel.elements.button.new(panel),
}

items[1]:setText("Hello")

menu:appendElements(items)

return menu