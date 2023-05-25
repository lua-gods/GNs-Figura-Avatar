local grid_start ,grid_stateID = nil, {}
events.WORLD_TICK:register(function()
    for key, grid in pairs(world.avatarVars()) do
        if grid and grid.grid_api and grid_stateID[key] ~= grid.grid_number then
            	grid_stateID[key] = grid.grid_number
            	grid.grid_api(grid_start)
            end
    end
end,"grid finder")

local config = {
   subdivision = 11,
   max_itterations = 80,
   map = vec(-2,2),
   pos = vec(-0.75,0),
   zoom = 0.6,
}
local current_subdivision = 1
local x = 0
local y = 0

function grid_start(grid)
    ---@type gridMode
	local myMode = grid.newMode("demo:mandelbrot")
   local res = 2^config.subdivision
   local view = textures:newTexture("mandelbrotset",res,res)
   myMode.INIT:register(function()
      x = -1
      y = 0
      myMode:setLayerCount(1)
      myMode:setLayerTexture(view,1)
      myMode:setLayerDepth(0,1)
   end)
   
   local enabled = true
   local current_res = 2
   local last_steps = 1
   local ignore = true
   myMode.TICK:register(function ()
      if enabled then
         for _ = 1, 100, 1 do
            x = x + 1
            if x >= current_res then
               x = 0
               y = y + 1
               if y >= current_res then
                  x = 0
                  y = 0
                  if config.subdivision > current_subdivision then
                     current_subdivision = current_subdivision + 1
                  else
                     enabled = false
                     sounds:playSound("minecraft:block.note_block.bell",myMode:getPos()+vectors.vec3(myMode:getGridSize()*0.5,0,myMode:getGridSize()*0.5))
                  end
                  current_res = 2^current_subdivision
               end
               ignore = 0
            end
            ignore = false
            if math.floor(y/2) == y/2 and math.floor(x/2) == x/2 then -- ignore top left pixel cuz its already rendered by the last frame
               ignore = true
            end
            if not ignore then
               local vPos = vec(
                  math.map(x,0,current_res,config.map.x,config.map.y),
                  math.map(y,0,current_res,config.map.x,config.map.y)
               )
               local r = 1;
               local ratio = res/current_res
               local c = config.pos + vPos * config.zoom * r
               local z = c:copy()
               local n = 0.0;
               for i = config.max_itterations, 0, -1 do
                  if(z.x*z.x+z.y*z.y > 4.0) then
                     n = i/config.max_itterations;
                     last_steps = n
                     break
                  end
                   z = vectors.vec2(z.x*z.x-z.y*z.y, 2.0*z.x*z.y) + c;
               end
               local clr = n
               
               --print(x*ratio,y*ratio,x*ratio,y*ratio)
               view:update()
               view:fill(x*ratio,y*ratio,ratio,ratio,vec(clr,clr,clr,1))
            end
            --view:setPixel(x,y,n,n,n)
         end
      end
   end)
      myMode.RENDER:register(function (delta)
   end)
end

--avatar:store("force_grid_mode", "demo:mandelbrot")