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
   composite = '{"font":"minecraft:default","text":""},{"text":"${badges}:hat:","font":"figura:emoji","color":"#'..vectors.rgbToHex(vectors.hsvToRGB(config.theme.from))..'"},'
   local name = config.username
   for i = 1, #name, 1 do
      local percentage = i/#name
      composite = composite..'{"text":"'..name:sub(i,i)..'","color":"#'..vectors.rgbToHex(vectors.hsvToRGB(vectors.vec3(math.lerpAngle(config.theme.from.x*360,config.theme.to.x*360,percentage)/360,math.lerp(config.theme.from.y,config.theme.to.y,percentage),math.lerp(config.theme.from.z,config.theme.to.z,percentage))))..'","hoverEvent":{"action":"show_text","contents":["GNamimates#2357"]}}'
      if i ~= #name then
         composite = composite..","
      end
   end
end


nameplate.ENTITY:shadow(true)

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

function pings.syncstatus(...)
   raw_status = {...}
   updateNameplate()
end

function n:setStatus(...)
   pings.syncstatus(...)
end

function n:setNick(name)
   config.username = name
   updateNameplate()
end
local rainbow = false

function pings.syncnick(nick)
   models.gn:setPrimaryRenderType("CUTOUT_CULL")
   models.gn:setSecondaryRenderType("NONE")
   models.gn:setScale(1,1,1)
   models.gn:setPivot(0,0,0)
   models:setColor(1,1,1)
   rainbow = false
   if nick == "Dinnerbone" or nick == "Grumm" then
      models.gn:setScale(-1,-1,1)
      models.gn:setPivot(0,16,0)
      
   elseif nick == "GhostAmimates" then
      models.gn:setPrimaryRenderType("EMISSIVE")
   elseif nick == "CADamimates" then
      models.gn:setPrimaryRenderType("LINES_STRIP")
   elseif nick == "EnchantedAmimates" then
      models.gn:setSecondaryRenderType("GLINT")
   elseif nick == "PortalAmimates" then
      models.gn:setPrimaryRenderType("TEXTURED_PORTAL")
   elseif nick == "BlurryAmimates" then
      models.gn:setPrimaryRenderType("BLURRY")
   elseif nick == "RGBNamimates" then
      rainbow = true
   end
   n:setNick(nick)
end

local time = 0
events.TICK:register(function ()
   if rainbow then
      time = time + 1
      models:setColor(vectors.hsvToRGB(time*0.01,1,1))
   end
end)

return n