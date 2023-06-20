local panel = require("libraries.panel")
local page = panel:newPage()

local timer = 0

local function updatePages()
   page:clearAllEmenets()
   for key, value in pairs(world:getPlayers()) do
      page:newElement("button"):setText(value:getName())
   end
end

events.TICK:register(function ()
   timer = timer - 1
   if timer < 0 then
      timer = 60
      updatePages()
   end
end)



page:newElement("returnButton")

return page