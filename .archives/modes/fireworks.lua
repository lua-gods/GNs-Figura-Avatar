local grid_start ,grid_stateID = nil, {}
events.WORLD_TICK:register(function()
    for key, grid in pairs(world.avatarVars()) do
        if grid and grid.grid_api and grid_stateID[key] ~= grid.grid_number then
            	grid_stateID[key] = grid.grid_number
            	grid.grid_api(grid_start)
            end
    end
end,"grid finder")
-- avatar:store("force_grid_mode", "demo:fireworksZ")
function grid_start(grid)
   local fireworks = {}
   local fadeList = {}
	local myMode = grid.newMode("demo:fireworks")
   local view = textures:newTexture("demofireworksfinalpass",256,256):fill(0,0,256,256,vec(0,0,0))
   myMode.INIT:register(function()
      myMode:setLayerCount(1)
      myMode:setLayerTexture(view,1)
      myMode:setLayerDepth(0,1)
   end)
   
   local function newFirework(pos,velx,vely)
      table.insert(fireworks,{
         pos=vectors.vec2(pos,0),
         vel=vectors.vec2(velx,vely),
         fuse = vely*100 + 20,
         explodes = true,
         color = vec(math.random(),math.random(),math.random())
      })
   end

   local function newAsh(posx,posy,velx,vely,clr)
      table.insert(fireworks,{
         pos=vectors.vec2(posx,posy),
         vel=vectors.vec2(velx,vely),
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
         newFirework(math.random(0,256),math.random()-0.5,math.random()*1.5)
      end
      view:update()
      local fade = 0.9
      local fadeLimit = 0.05 ^ 2
      for i, p in pairs(fadeList) do
        local c = view:getPixel(p.x, p.y).rgb * fade
        if c:lengthSquared() < fadeLimit then
            fadeList[i] = nil
            view:setPixel(p.x, p.y, 0, 0, 0, 1)
        else
            view:setPixel(p.x, p.y, c)
        end
      end
    --   view:update():fill(0,0,256,256,vec(0,0,0))
      for id, f in pairs(fireworks) do
         f.pos = f.pos + f.vel
         f.vel.y = f.vel.y - 0.01
         f.fuse = f.fuse - 1
         if f.pos.x > 0 and f.pos.x < 256 and f.pos.y > 0 and f.pos.y < 256 then
            view:setPixel(f.pos.x-1,f.pos.y-1,f.color)
            fadeList[tostring(f.pos:copy():floor())] = f.pos - 1
         end
         if f.fuse < 0 then
            if f.explodes then
               for i = 1, 10, 1 do
                  newAsh(f.pos.x,f.pos.y,math.random()-0.5,math.random()-0.5,f.color)
               end
            end
            table.remove(fireworks,id)
         end
      end
   end)
      myMode.RENDER:register(function (delta)
   end)
end