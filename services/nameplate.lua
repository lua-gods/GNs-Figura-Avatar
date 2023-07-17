local from = vectors.hexToRGB("#99e65f") 
local to = vectors.hexToRGB("#1e6f50")
local prefix = '{"text":"${badges}:<3_GN:","color":"white"}'
local entity_name = avatar:getEntityName()
local suffix = ""
local mid = ""

for i = 1, #entity_name, 1 do
   local r = i/#entity_name
   local hex = vectors.rgbToHex(
      vectors.vec3(
         math.lerp(from.x,to.x,r),
         math.lerp(from.y,to.y,r),
         math.lerp(from.z,to.z,r)
      )
   )
   mid = mid .. '{"text":"'..entity_name:sub(i,i)..'","color":"#' .. hex .. '"}'
   if i ~= #entity_name then
      mid = mid .. ","
   end
end

local cmid = ""

local lsyst = client:getSystemTime()

local ls = 0
local s = 1
events.TICK:register(function ()
   if IS_AFK then
      local csyst = client:getSystemTime()
      s = math.floor((csyst-TIME_SINCE_INACTIVE)/1000)
      if ls ~= s and s ~= 0 then
         local disp_time = ""
         local minute = math.floor(s / 60)
         
         if minute ~= 0 then
            local hour = math.floor(minute / 60)
            if hour ~= 0 then
               local day = math.floor(hour / 24)
               if day ~= 0 then
                  local year = math.floor(day / 356)
                  if year ~= 0 then
                     local century = math.floor(year / 100)
                     if century ~= 0 then
                        disp_time = century.."cnt " .. (year % 100).."yr " .. (day % 356).."dy " .. (hour % 24).."hr " .. (minute % 60) .."m " .. (s % 60) .."s"
                     else
                        disp_time = year.."yr " .. (day % 31).."dy " .. (hour % 24).."hr " .. (minute % 60).."m " .. (s % 60) .."s"
                     end
                  else
                     disp_time = (day % 31).."dy " .. (hour % 24).."hr " .. (minute % 60).."m " .. (s % 60) .."s"
                  end
               else
                  disp_time = (hour % 24).."hr " .. (minute % 60).."m " .. (s % 60) .."s"
               end
            else
               disp_time = (minute % 60).."m " .. (s % 60) .."s"
            end
         else
            disp_time = s.."s"
         end
         suffix = '{"text":"\n[AFK : '.. disp_time ..']","color":"gray"}'
      end
   else
      suffix = '{"text":""}'
   end
   nameplate.ALL:setText('[' .. prefix .. ',' .. mid .. ',' .. suffix .. ']')
   ls = s
end)

nameplate.ENTITY:shadow(true)