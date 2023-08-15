local prefix = "/"

local memorize = {
   math = math,
   inf = math.huge,
   bit32 = bit32
}

local cmd = {
   function (message,words)
      local list = words
      local expression = false
      local eval = ""
      for i = 1, #list, 1 do
         if expression then
            if (list[i]:lower() == "=" or list[i]:lower() == "is") and not eval:match('function%(') then
               local code = "return function(env) _ENV = env; return "..eval:gsub(" x ","*").." end"
               local func = load(code)
               local worky, result = pcall(func)
               if worky then
                  worky, result = pcall(result, memorize)
                  if worky then
                     return message .. " " .. tostring(result)
                  end
               end
            else
               eval = eval .. " " .. list[i]
            end
         end

         if i > 2 then
            local what = list[i-2]
            local mid = string.lower(list[i-1])
            local with = tonumber(list[i])
            if (mid == "is") and type(with) == "number" then
               memorize[list[i-2]] = with
               printJson('[{"text":"\\n' ..  what .. '","color":"white"},{"text":" = ","color":"gray"},{"text":"' ..  with .. '","color":"green"}]')
            end
         end
         if list[i]:lower() == "so" then
            expression = true
         end
      end
      return message
   end
}

---@param str string
---@return table
local function splitWords(str)
   local words = {}
   for word in str:gsub(","," "):gmatch("[%w%pt]+") do
       table.insert(words, word)
   end
   return words
end

events.CHAT_SEND_MESSAGE:register(function (message)
   local words = splitWords(message)
   for key, value in pairs(cmd) do
      if type(key) == "number" then
         return value(message,words)
      end
      if prefix .. key == words[1] then
         return value(message,words)
      end
   end
   return message
end)