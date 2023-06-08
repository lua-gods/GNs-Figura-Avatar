local rep = {
   {":red:","§a"},
   {"s","ss"}
}

events.CHAT_SEND_MESSAGE:register(function (message)
   for _, value in pairs(rep) do
      message:gsub(value[1],value[2])
   end
   return message
end)