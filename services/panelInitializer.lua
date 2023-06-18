local panel = require("libraries.panel")
if not panel then return end
panel:setModelpart(models.hud)
panel:setPage(require("menu.root"))