local panel = require('libraries.panel')
local page = panel:newPage()

local pbuton = page:newElement("button"):setText("Set as Player Position")
local X = page:newElement("textEdit"):setPlaceholderText("X"):setColorRGB(1,0,0)
local Y = page:newElement("textEdit"):setPlaceholderText("Y"):setColorRGB(0,1,0)
local Z = page:newElement("textEdit"):setPlaceholderText("Z"):setColorRGB(0,0,1)

pbuton.ON_PRESS:register(function ()
   if player:isLoaded() then
      local pos = player:getPos()
      X:setValue(tostring(math.floor(pos.x)))
      Y:setValue(tostring(math.floor(pos.y)))
      Z:setValue(tostring(math.floor(pos.z)))
   end
end)
X.ON_TEXT_CONFIRM:register(function (message)
   local num = math.floor(tonumber(message))
   if not num then X.text = "" end
end)
Y.ON_TEXT_CONFIRM:register(function (message)
   local num = math.floor(tonumber(message))
   if not num then Y.text = "" end
end)
Z.ON_TEXT_CONFIRM:register(function (message)
   local num = math.floor(tonumber(message))
   if not num then Z.text = "" end
end)

page:newElement("button"):setText("Generate").ON_PRESS:register(function ()
   if X.text ~= "" and Y.text ~= "" and Z.text ~= "" then
      host:sendChatCommand('/give @p command_block{BlockEntityTag:{auto:1,Command:"setblock ~ ~ ~ end_gateway{Age:-9223372036854775807L,ExactTeleport:1,ExitPortal:{X:'..X.text..',Y:'..Y.text..',Z:'..Z.text..'}}"}} 1')
   end
end)

local morbious = page:newElement("toggleButton"):setText("Auto Remove Beam")
morbious.toggle = true
events.TICK:register(function ()
   if morbious.toggle and player:getSwingTime() == 3 then
      local target = player:getTargetedBlock(true)
      if target.id == "minecraft:end_gateway" then
         local pos = target:getPos()
         host:sendChatCommand("/data merge block "..math.floor(pos.x).." "..math.floor(pos.y).." "..math.floor(pos.z).." {Age:-9223372036854775807L}")
      end
   end
end)

page:newElement("returnButton")

return page