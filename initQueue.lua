local phase = 0
local i = 1
local function printError(err)
   printJson('{"color":"red","text":">============= [Just GN '..i..' ] =============<\n"}')
   printJson('{"color":"red","text":"'..err:gsub('"','\\"')..'\n"}')
   printJson('{"color":"red","text":">-----------------------------------<\n"}')
end

IS_HOST = host:isHost()
TRUST_LEVEL = ({BLOCKED=0,LOW=1,DEFAULT=2,HIGH=3,MAX=4})[avatar:getPermissionLevel()]

local queue = listFiles("services",true)
events.WORLD_TICK:register(function ()
   require(queue[i])
   i = i + 1
   if i > #queue then
      events.WORLD_TICK:remove("queueStart")
   end
end,"queueStart")