if not (TRUST_LEVEL > 3) then return end
local paths = listFiles("scripts")
for _, path in pairs(paths) do
   require(path)
end