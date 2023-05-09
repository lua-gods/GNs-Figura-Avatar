local phase = 0
local i = 0
local queue = {}
local function printError(err)
   printJson('{"color":"red","text":">============= [Just GN '..i..' ] =============<\n"}')
   printJson('{"color":"red","text":"'..err:gsub('"','\\"')..'\n"}')
   printJson('{"color":"red","text":">-----------------------------------<\n"}')
end
events.WORLD_TICK:register(function()
   if phase == 0 then
      queue = listFiles("services",true)
      phase = 1
   elseif phase == 1 then
      i = i + 1
      local ok,err = pcall(require,queue[i])
      if not ok then printError(err) end
      print(i,queue[i])
      if i == #queue then phase = 2 end
   end
end,"queueInitProcessor")