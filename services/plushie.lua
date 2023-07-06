models.plushie:setParentType("SKULL")

events.SKULL_RENDER:register(function (delta, block, item, welder, context)
   if block then
      local pos = block:getPos()
      local floor = world.getBlockState(pos:copy():add(0,-1,0))
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
   else
      models.plushie:setPos(0,0,0)
   end
end)

local function DAMN(p)
   local pos = p:copy():add(0.5,0.5,0.5)
   sounds:playSound("damn",pos,100000,1)
   particles:newParticle("minecraft:flash",pos)
end

local plushies = {}
local powered = {}

events.WORLD_TICK:register(function ()
   for key, player in pairs(world.getPlayers()) do
      if player:getSwingTime() == 1 then
         local block = player:getTargetedBlock(true,5)
         if block and block.id == "minecraft:player_head" then
            local nbt = block:getEntityData()
            if nbt and nbt.SkullOwner and nbt.SkullOwner.Name == "GNamimates" then
               local pos = block:getPos()
               DAMN(pos)
            end
         end
      end
   end
   for key, pos in pairs(plushies) do
      if (world.getRedstonePower(pos) > 0) then
         if not powered[tostring(pos)] then
            DAMN(pos)
            powered[tostring(pos)] = true
         end
      else
         if powered[tostring(pos)] then
            powered[tostring(pos)] = false
         end
      end
   end
end)



events.WORLD_RENDER:register(function (delta)
   plushies = {}
end)

events.SKULL_RENDER:register(function (delta, block, item)
   if block then
      table.insert(plushies,block:getPos():add(0,-1,0))
   end
end)