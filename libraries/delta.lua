if F then
   local lastFrameTime = client:getSystemTime()
   events.WORLD_RENDER:register(function()
      DELTA = (client:getSystemTime()-lastFrameTime) * 0.01
      lastFrameTime = client:getSystemTime()
   end)
else
   DELTA = 0.01666
end