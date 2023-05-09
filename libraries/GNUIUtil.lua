local util = {}

function util.anchorToPos(x,y,ox,oy)
   local pos = client:getWindowSize()/client:getGuiScale()/2
   pos.x = pos.x * math.map(x,-1,1,0,-2) + ox
   pos.y = pos.y * math.map(y,-1,1,0,-2) + oy
   return pos
end

return util