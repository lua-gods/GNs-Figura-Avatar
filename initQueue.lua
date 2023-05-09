local phase = 0
local i = 0
local function printError(err)
   printJson('{"color":"red","text":">============= [Just GN '..i..' ] =============<\n"}')
   printJson('{"color":"red","text":"'..err:gsub('"','\\"')..'\n"}')
   printJson('{"color":"red","text":">-----------------------------------<\n"}')
   i = i + 1
end
events.WORLD_TICK:register(function()
   if phase ~= 2 then
      for _ = 1, 100, 1 do
         if not InitQueue then
            if phase == 0 then
               require("services.trust")
               models:setVisible(false)
               InitQueue = listFiles("services",true)
            elseif phase == 1 then
               InitQueue = listFiles("",true)
            end
            H = host:isHost()
            if H then
               InitQueueFullSize = #InitQueue
            end
         end
         if phase == 1 then
            if InitQueue[1] then
               if InitQueue[1]:sub(1,9) ~= "services" then
                  local ok,msg = pcall(require,InitQueue[1])
                  --print("loaded "..InitQueue[1],#InitQueue)
                  if not ok then
                     printError(msg)
                  end
               end
            end
         else
            local ok,msg = pcall(require,InitQueue[1])
            if not ok then
               printError(msg)
            end
            --print("loaded "..InitQueue[1],#InitQueue)
         end
         table.remove(InitQueue,1)
         if H then
            local compose ="§a"..tostring(("|"):rep(InitQueueFullSize-#InitQueue)).."§0"..tostring(("|"):rep(#InitQueue)).."  §f"..tostring(InitQueue[1])
            host:setActionbar( '"'..(" "):rep(client.getTextWidth(compose)*0.25)..compose..'      "')
         end
         if #InitQueue == 0 then
            if phase == 1 then
               models:setVisible(true)
               host:setActionbar("")
               events.WORLD_TICK:remove("queueInitProcessor")
            else
               InitQueue = nil
               phase = 1
               --print("loading csgo")
            end
         end
      end
   end
end,"queueInitProcessor")