local panel = require("libraries.panel")
local page = panel:newPage()

local input = page:newElement("textEdit"):setPlaceholderText("message")
page:newElement("button"):setText("send").ON_PRESS:register(function ()
   if input.text:sub(1,1) == "/" then
      host:sendChatCommand(input.text)
   else
      host:sendChatMessage(input.text)
   end
end)
page:newElement("button"):setText("clear").ON_PRESS:register(function ()
   input.text = ""
end)
page:newElement("returnButton")

return page