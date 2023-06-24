local mac = require("libraries.macroScriptLib"):newScript("renderer:hide_inside_mob")

mac.ENTER:register(function ()
   
end)
mac.FRAME:register(function ()
   renderer.renderVehicle = not renderer:isFirstPerson()
end)

mac.EXIT:register(function ()
   renderer.renderVehicle = true
end)

return mac