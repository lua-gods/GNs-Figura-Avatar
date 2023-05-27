local panel = require("libraries.panel")

local menu = panel:newPage()
local items = {
   panel.elements.toggleButton.new(panel),
   panel.elements.textEdit.new(panel),
   panel.elements.button.new(panel):setText("Wardrobe"),
   panel.elements.slider.new(panel):setText("Example"):setItemCount(20)
}

items[3].ON_PRESS:register(function ()
panel:setPage(require("menu.wardrobe"))
end)
menu:appendElements(items)
return menu