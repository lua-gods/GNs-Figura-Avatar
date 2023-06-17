local panel = require("libraries.panel")
if not panel then return end
models.hud:setParentType("HUD")
panel:setPage(require("menu.root"))