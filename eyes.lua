local config = {
   long_wait = 20*20,
   short_wait = 1*20,
}

local blink_time = 0

events.TICK:register(function()
   blink_time = blink_time - 1
   if blink_time < 0 then
      blink_time = math.random(config.short_wait,config.long_wait)
      animations.gn.blink:stop()
      animations.gn.blink:play()
   end
end)