
local paths = listFiles("scripts")
for _, path in pairs(paths) do
   require(path)
end