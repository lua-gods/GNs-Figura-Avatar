local phase = 0
local i = 0
local queue = {}
local function printError(err)
   i = i + 1
   printJson('{"color":"red","text":">============= [Just GN '..i..' ] =============<\n"}')
   printJson('{"color":"red","text":"'..err:gsub('"','\\"')..'\n"}')
   printJson('{"color":"red","text":">-----------------------------------<\n"}')
end

for key, value in pairs(listFiles("services",true)) do
   require(value)
end