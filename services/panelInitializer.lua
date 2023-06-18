local panel = require("libraries.panel")
panel:setModelpart(models.hud)
if not panel then return end
panel:setPage(require("menu.root"))