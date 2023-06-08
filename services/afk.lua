TIME_SINCE_INACTIVE = 0
local was_afk = false
IS_AFK = false

local function reset()
   TIME_SINCE_INACTIVE = client:getSystemTime()
end
reset()

function pings.GNISAFK(TIME)
   TIME_SINCE_INACTIVE = TIME
   IS_AFK = ((client:getSystemTime()-TIME_SINCE_INACTIVE) / 1000 > 15)
end
local check_time = 0
events.TICK:register(function ()
   check_time = check_time + 1
   if check_time > 20 then
      check_time = 0
      if host:isHost() then
         pings.GNISAFK(TIME_SINCE_INACTIVE)
      end
   end
end)

events.KEY_PRESS:register(function (_,_,_)reset()end)
events.MOUSE_MOVE:register(function (_,_)reset()end)