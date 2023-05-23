---@diagnostic disable: assign-type-mismatch, param-type-mismatch
--{"text":"ඞ🔥🌱","font":"figura:default"}
local config = {
   theme = {
      from = "#99e65f",
      to = "#1e6f50",
   },
   username = "GNamimates",
}

for key, value in pairs(config.theme) do
   config.theme[key] = vectors.hexToRGB(value)
end

for key, value in pairs(config.theme) do
   config.theme[key] = vectors.rgbToHSV(value)
end

local composite = ""


local raw_status = {}
local status = ""
local status_sync = 0

local function rebuild()
   if #raw_status ~= 0 then
      status = "["
      for i, element in pairs(raw_status) do
         status = status..element
         if i ~= #raw_status then
            status = status.." : "
         end
      end
      status = status.."]"
      status = '{"text":"'..status..'","color":"dark_gray"}'
   end
   composite = '{"font":"minecraft:default","text":""},{"text":"${badges}:tophat:","font":"figura:emoji","color":"#'..vectors.rgbToHex(vectors.hsvToRGB(config.theme.from))..'"},'
   local name = config.username
   for i = 1, #name, 1 do
      local percentage = i/#name
      composite = composite..'{"text":"'..name:sub(i,i)..'","color":"#'..vectors.rgbToHex(vectors.hsvToRGB(vectors.vec3(math.lerpAngle(config.theme.from.x*360,config.theme.to.x*360,percentage)/360,math.lerp(config.theme.from.y,config.theme.to.y,percentage),math.lerp(config.theme.from.z,config.theme.to.z,percentage))))..'","hoverEvent":{"action":"show_text","contents":["GNamimates#2357"]}}'
      if i ~= #name then
         composite = composite..","
      end
   end
end


nameplate.ENTITY:shadow(true):setPos(0,-0.1,0)

local n = {}


local function updateNameplate()
   rebuild()
   nameplate.CHAT:setText('['..composite.."]")
   if #raw_status ~= 0 then
      nameplate.LIST:setText('['..composite..","..status.."]")
      nameplate.ENTITY:setText('['..status..',{"text":"\\n"},'..composite.."]")
   else
      nameplate.LIST:setText('['..composite.."]")
      nameplate.ENTITY:setText('['..composite.."]")
   end
end

updateNameplate()

if host:isHost() then
   events.TICK:register(function ()
      status_sync = status_sync - 1
      if status_sync < 0 then
         status_sync = 20*10
         if #raw_status ~= 0 then
            pings.syncstatus(table.unpack(raw_status))
         end
      end
   end)
end

return n