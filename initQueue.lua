local phase = 0
local i = 0
local queue = {}
local function printError(err)
   i = i + 1
   printJson('{"color":"red","text":">============= [Just GN '..i..' ] =============<\n"}')
   printJson('{"color":"red","text":"'..err:gsub('"','\\"')..'\n"}')
   printJson('{"color":"red","text":">-----------------------------------<\n"}')
end
events.WORLD_TICK:register(function()
   if phase == 0 then
      queue = listFiles("services",true)
      phase = 1
   elseif phase == 1 then
      local ok,err = pcall(require,queue[1])
      table.remove(queue,1)
      if not ok then printError(err) end
      if #queue == 0 then
         events.WORLD_TICK:remove("preproccessor")
      end
   end
end,"preproccessor")