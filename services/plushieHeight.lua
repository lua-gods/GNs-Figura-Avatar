models.plushie:setParentType("SKULL")
events.SKULL_RENDER:register(function (delta, block, item)
   if block then
      local floor = world.getBlockState(block:getPos():add(0,-1,0))
      if floor.id:match("stairs") and floor.properties and floor.properties.half == "bottom" then
         models.plushie:setPos(0,-8,-2)
      else
         local height = 0
         for _, value in pairs(floor:getOutlineShape()) do
            if value[1].x <= 0.5 and value[2].x >= 0.5 and 
            value[1].z <= 0.5 and value[2].z >= 0.5 then
               height = math.max(value[2].y,value[1].y,height)
            end
         end
         models.plushie:setPos(0,(height - 1) * 16,0)
      end
   else models.plushie:setPos(0,0,0) end
end)