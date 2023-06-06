local from = vectors.hexToRGB("#99e65f") 
local to = vectors.hexToRGB("#1e6f50")
local prefix = '{"text":"${badges}:<3_GN:","color":"white"}'
local name = "GNamimates"

local mid = ""
for i = 1, #name, 1 do
   local r = i/#name
   local hex = vectors.rgbToHex(
      vectors.vec3(
         math.lerp(from.x,to.x,r),
         math.lerp(from.y,to.y,r),
         math.lerp(from.z,to.z,r)
      )
   )
   mid = mid .. '{"text":"'..name:sub(i,i)..'","color":"#' .. hex .. '"}'
   if i ~= #name then
      mid = mid .. ","
   end
end



local lsyst = client:getSystemTime()

local ls = 0
local s = 1
local t = 0
events.TICK:register(function ()
   local csyst = client:getSystemTime()
   t = (csyst-lsyst) / 1000
   s = math.floor(t)
   if ls ~= s then
      local disp_time = ""
      local minute = math.floor(s / 60)
      
      if minute ~= 0 then
         local hour = math.floor(minute / 60)
         if hour ~= 0 then
            local day = math.floor(hour / 24)
            if day ~= 0 then
               disp_time = day.."d"
            else
               disp_time = hour.."h"
            end
         else
            disp_time = minute.."m"
         end
      else
         disp_time = s.."s"
      end
      local suffix = '{"text":"\n[AFK : '.. disp_time ..']","color":"gray"}'
      nameplate.ALL:setText('[' .. prefix .. ',' .. mid .. ',' .. suffix .. ']')
      ls = s
   end
end)

nameplate.ENTITY:shadow(true)