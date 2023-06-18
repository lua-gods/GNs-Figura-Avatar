local grid_start ,grid_stateID = nil, {}
events.WORLD_TICK:register(function()
    for key, grid in pairs(world.avatarVars()) do
        if grid and grid.grid_api and grid_stateID[key] ~= grid.grid_number then
            	grid_stateID[key] = grid.grid_number
            	grid.grid_api(grid_start)
            end
    end
end,"grid finder")
-- avatar:store("force_grid_mode", "demo:fireworks3d")
function grid_start(grid)
   local fireworks = {}
   local fadeList = {}
	local myMode = grid.newMode("demo:fireworks3d")
    local depth = 31
   local views = {}
   for i = 1, depth do
    views[i] = textures:newTexture("demofireworksfinalpass"..i,256,256):fill(0,0,256,256,vec(0,0,0, 0))
   end
   myMode.INIT:register(function()
      myMode:setLayerCount(depth + 1)
      local gap = myMode:getGridSize() / 256 * 2
      for i = 1, depth do
        myMode:setLayerTexture(views[i], i)
        myMode:setLayerDepth((i - 1) * gap, i)
    end
        myMode:setLayerColor(vec(0, 0, 0), depth + 1)
   end)
   
   local function newFirework(pos,velx,vely,velz)
      table.insert(fireworks,{
         pos=vec(pos,0, math.floor(depth / 2)),
         vel=vec(velx,vely,velz),
         fuse = vely*100 + 20,
         explodes = true,
         color = vec(math.random(),math.random(),math.random())
      })
   end

   local function newAsh(posx,posy,posz,velx,vely,velz,clr)
      table.insert(fireworks,{
         pos=vec(posx,posy, posz),
         vel=vec(velx,vely, velz),
         fuse = math.lerp(5,60,math.random()),
         explodes = false,
         color = clr
      })
   end

   local spawn_timer = 0

   myMode.TICK:register(function ()

      spawn_timer = spawn_timer - 1

      if spawn_timer < 0 then
         spawn_timer = math.random(0,10)
         newFirework(math.random(0,256),math.random()-0.5,math.random()*1.5, (math.random()-0.5) * 0.5)
      end
      for i = 1, depth do
        views[i]:update()
      end
      local fade = 0.9
      local fadeLimit = 0.05
      for i, p in pairs(fadeList) do
        local view = views[p.z]
        local c = view:getPixel(p.x, p.y)
        c.a = c.a * fade
        if c.a < fadeLimit then
            fadeList[i] = nil
            view:setPixel(p.x, p.y, 0, 0, 0, 0)
        else
            view:setPixel(p.x, p.y, c)
        end
      end
    --   view:update():fill(0,0,256,256,vec(0,0,0))
      for id, f in pairs(fireworks) do
         f.pos = f.pos + f.vel
         f.vel.y = f.vel.y - 0.01
         f.fuse = f.fuse - 1
         local x, y = math.floor(f.pos.x - 1), math.floor(f.pos.y - 1)
         if x >= 0 and x < 256 and y >= 0 and y < 256 then
            local z = math.floor(f.pos.z)
            local view = views[z]
            if view then
                view:setPixel(x, y, f.color)
                local p = vec(x, y, z)
                fadeList[tostring(p)] = p
            end
         end
         if f.fuse < 0 then
            if f.explodes then
               for i = 1, 25, 1 do
                  newAsh(f.pos.x,f.pos.y,f.pos.z,math.random()-0.5,math.random()-0.5,(math.random()-0.5)*0.5,f.color)
               end
            end
            table.remove(fireworks,id)
         end
      end
   end)
end
