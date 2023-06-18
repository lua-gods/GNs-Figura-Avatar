local mac = require("libraries.macroScriptLib"):newScript()

mac.ENTER:register(function ()
   print("ENTER")
end)

mac.TICK:register(function ()
   print("TICK")
end)

mac.EXIT:register(function ()
   print("EXIT")
end)

return mac