local mac = require("libraries.macroScriptLib"):newScript("gn:right_click_mount_target")

local format = {
   "_",
   "*",
   "~",
}

events.CHAT_SEND_MESSAGE:register(function (message)
   if mac.is_active and message:sub(1,1) ~= "/" then
      for key, value in pairs(format) do
         message = message:gsub(value,"\\"..value)
      end
   end
   return message
end)

return mac