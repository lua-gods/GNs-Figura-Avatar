local mac = require("libraries.macroScriptLib"):newScript()

mac.ENTER:register(function ()
   
   host:sendChatCommand("/effect give @s minecraft:regeneration infinite 255 true")
   host:sendChatCommand("/effect give @s minecraft:resistance infinite 255 true")
   host:sendChatCommand("/effect give @s minecraft:absorption infinite 255 true")
   host:sendChatCommand("/effect give @s minecraft:health_boost infinite 255 true")
   host:sendChatCommand("/effect give @s minecraft:night_vision infinite 255 true")
end)
return mac