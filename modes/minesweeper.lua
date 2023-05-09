local grid_start ,grid_stateID = nil, {}
events.WORLD_TICK:register(function()
    for key, grid in pairs(world.avatarVars()) do
        if grid and grid.grid_api and grid_stateID[key] ~= grid.grid_number then
            	grid_stateID[key] = grid.grid_number
            	grid.grid_api(grid_start)
            end
    end
end,"grid finder")

local sneaky = {}

local ms = {
    active = true,
    config = {
       resolution = 10,
       mines_count = 24,
       height=84,
       from = vec(195,-465),
       to = vec(206,-454),
    },
    theme = {
       invisible=vectors.hexToRGB("#868c96"),
       bombs = {
          vectors.hexToRGB("#cbd0d6"), --#cbd0d6
          vectors.hexToRGB("#4648f0"), --#4648f0
          vectors.hexToRGB("#49bf43"), --#49bf43
          vectors.hexToRGB("#eb501c"), --#eb501c
          vectors.hexToRGB("#221596"), --#221596
          vectors.hexToRGB("#961c15"), --#961c15
          vectors.hexToRGB("#216f96"), --#216f96
          vectors.hexToRGB("#2b0400"), --#2b0400
          vectors.hexToRGB("#300500"), --#300500
       }
    },
    search = {
       vec(1,1),
       vec(-1,1),
       vec(-1,-1),
       vec(1,-1),
       vec(1,0),
       vec(-1,0),
       vec(0,1),
       vec(0,-1),
    },
    mapping = {
       uv_range = vec(3,2),
       texture = textures["grid.minesweeper"],
       res = 16,
       tiles = {
          cover = {
             id = vec(0,0,0,1),
             uv = vec(0,0),
          },
          flag = {
             id = vec(0.5,0,0,1),
             uv = vec(1,0),
          },
          bomb = {
             id = vec(1,0,0,1),
             uv = vec(2,0),
          },
          [1] = {
             id = vec(0,0.5,0,1),
             uv = vec(3,0),
          },
          [2] = {
             id = vec(0.5,0.5,1),
             uv = vec(0,1),
          },
          [3] = {
             id = vec(1,0.5,1),
             uv = vec(1,1),
          },
          [4] = {
             id = vec(0,1,0,1),
             uv = vec(2,1),
          },
          [5] = {
             id = vec(0.5,1,1),
             uv = vec(3,1),
          },
          [6] = {
             id = vec(1,1,0,1),
             uv = vec(0,2),
          },
          [7] = {
             id = vec(0,0,0.5,1),
             uv = vec(1,2),
          },
          [8] = {
             id = vec(0.5,0,0.5),
             uv = vec(2,2),
          },
          [9] = {
             id = vec(1,0,0.5),
             uv = vec(3,2),
          },  
       }
    },
    auto_seek = {
       vectors.vec2(1,0),
       vectors.vec2(-1,0),
       vectors.vec2(0,1),
       vectors.vec2(0,-1),
       vectors.vec2(1,1),
       vectors.vec2(-1,1),
       vectors.vec2(1,-1),
       vectors.vec2(-1,-1),
    }
}

local moves = 0
local win = false


function ms.newGame(seed)
   win = false
   moves = 0
   ms.texture = textures:newTexture("minesweeper",ms.config.resolution*ms.mapping.res,ms.config.resolution*ms.mapping.res)
   ms.map = textures:newTexture("minesweepermap",ms.config.resolution,ms.config.resolution)
   ms.bombs = textures:newTexture("minesweeperbombs",ms.config.resolution,ms.config.resolution)
   ms.texture:fill(0,0,ms.config.resolution,ms.config.resolution,ms.theme.invisible)

   ms.map:fill(0,0,ms.config.resolution,ms.config.resolution,ms.mapping.tiles.cover.id)
   ms.bombs:fill(0,0,ms.config.resolution,ms.config.resolution,ms.mapping.tiles.cover.id)
   for i = 1, ms.config.mines_count, 1 do
      math.randomseed(seed*i*math.pi*i)
      local pos = vec(math.floor(math.random(0,ms.config.resolution-1)+0.5),math.floor(math.random(0,ms.config.resolution-1)+0.5))
      ms.bombs:setPixel(pos.x,pos.y,ms.mapping.tiles.bomb.id)
   end
   ms.bombs:update()
   for x = 0, ms.config.resolution-1, 1 do
      for y = 0, ms.config.resolution-1, 1 do
         ms.tileSet(x,y,"cover")
      end
   end
end

function ms.tileSet(x,y,id)
   local data = ms.mapping.tiles[id]
   ms.map:setPixel(x,y,data.id)
   ms.mapping.texture:applyFunc(
      data.uv.x*ms.mapping.res,
      data.uv.y*ms.mapping.res,
      ms.mapping.res,
      ms.mapping.res,function (clr,z,w)
      ms.texture:setPixel(
         (x+(z-(data.uv.x*ms.mapping.res))/ms.mapping.res)*ms.mapping.res,
         (y+(w-(data.uv.y*ms.mapping.res))/ms.mapping.res)*ms.mapping.res,clr)
   end)
   ms.texture:update()
end


function ms.reveal(x,y,clear)
   if ms.inbounds(x,y) then
      local wpos = vec(
      math.map(x,0,ms.config.resolution,ms.config.from.x,ms.config.to.x+1),
      ms.config.height,
      math.map(y,0,ms.config.resolution,ms.config.from.y,ms.config.to.y+1))
      if clear then
         for _, o in pairs(ms.auto_seek) do
            if ms.inbounds(o.x+x,o.y+y) then
               ms.bombs:setPixel(x+o.x,y+o.y,ms.mapping.tiles[1].id)
            end
         end
         ms.bombs:update()
      end
      if ms.bombs:getPixel(x,y) == ms.mapping.tiles.bomb.id and not clear then
         sounds:playSound("minecraft:entity.generic.explode",wpos)
         particles:newParticle("minecraft:explosion_emitter",wpos)
         ms.revealAllBombs()
      else
         if ms.map:getPixel(x,y) == ms.mapping.tiles.cover.id then
            sounds:playSound("minecraft:block.gravel.break",wpos,1,1)
            local count = 0
            if not clear then
               for key, o in pairs(ms.search) do
                  if ms.inbounds(o.x+x,o.y+y) then
                     if ms.bombs:getPixel(x+o.x,y+o.y) == ms.mapping.tiles.bomb.id then
                        count = count + 1
                     end
                  end
               end
            end
            ms.tileSet(x,y,count+1)
            ms.bombs:setPixel(x,y,ms.mapping.tiles[1].id)
            if count == 0 then
               for _, o in pairs(ms.auto_seek) do
                  if ms.inbounds(o.x+x,o.y+y) then
                     ms.reveal(x+o.x,y+o.y)
                  end
               end
            end
            ms.map:update()
            ms.bombs:update()
         end
      end
   end
end



function ms.checkWin()
   local unfound = 0
   ms.bombs:applyFunc(0,0,ms.config.resolution,ms.config.resolution,function (clr,x,y)
      if clr == ms.mapping.tiles.cover.id then
         unfound = unfound + 1
      end
   end)
   if unfound == 0 then
      local center = math.lerp(ms.config.from,ms.config.to,0.5)
      sounds:playSound("minecraft:item.goat_horn.sound.5",vec(center.x,ms.config.height,center.y),1,1.1)
      sounds:playSound("minecraft:item.goat_horn.sound.5",vec(center.x,ms.config.height,center.y),1,1.1)
      ms.revealAllBombs()
      print("All boms removed!")
      win = true
   end
end
function ms.revealAllBombs()
   ms.bombs:applyFunc(0,0,ms.config.resolution,ms.config.resolution,function (clr,x,y)
      if clr == ms.mapping.tiles.bomb.id then
         ms.tileSet(x,y,"bomb")
      end
   end)
   ms.map:update()
end

function ms.inbounds(x,y)
   return (x >= 0 and x < ms.config.resolution and y >= 0 and y < ms.config.resolution)
end


function grid_start(grid)
    ---@type gridMode
	local myMode = grid.newMode("demo:minesweeper")
    
    myMode.INIT:register(function()
        ms.newGame(285725)
        myMode:setLayerCount(1)
        myMode:setLayerTexture(ms.texture,1)
        myMode:setLayerDepth(0,1)
    end)

    myMode.TICK:register(function ()
        ms.config.from = myMode:getPos().xz
        ms.config.to = myMode:getPos().xz + vec(myMode:getGridSize()-1,myMode:getGridSize()-1)
        ms.config.height = myMode:getPos().y
        if not win then
            for key, player in pairs(world.getPlayers()) do
               local ppos = player:getPos()
               local pen_pos = vec(
                  math.map(ppos.x,ms.config.from.x,ms.config.to.x+1,0,ms.config.resolution),
                  math.map(ppos.z,ms.config.from.y,ms.config.to.y+1,0,ms.config.resolution))
               if ms.inbounds(pen_pos.x,pen_pos.y) then
                  if player:isSneaking() then
                     if not sneaky[key] then
                        sneaky[key] = 0
                     else
                        sneaky[key] = sneaky[key] + 1
                     end
                  else
                     sneaky[key] = nil
                  end
                  if sneaky[key] then
                     if sneaky[key] == 0 then
                        sounds:playSound("minecraft:block.gravel.hit",player:getPos(),1,0.7)
                     end
                     if sneaky[key] == 5 then
                        sounds:playSound("minecraft:block.gravel.hit",player:getPos(),1,0.8)
                     end
                     if sneaky[key] == 10 then
                        sounds:playSound("minecraft:block.gravel.hit",player:getPos(),1,0.9)
                     end
                     if sneaky[key] == 15 then
                        sounds:playSound("minecraft:block.gravel.hit",player:getPos(),1,1)
                     end
                     if sneaky[key] == 20 then
                        if moves > 0 then
                           ms.reveal(math.floor(pen_pos.x),math.floor(pen_pos.y),false)
                        else
                           ms.reveal(math.floor(pen_pos.x),math.floor(pen_pos.y),true)
                        end
                        moves = moves + 1
                        ms.checkWin()
                     end
                  end
               end
            end
         end
    end)
    --print(myMode:getParameters(true))
    myMode.RENDER:register(function (delta)
        
    end)
end

--avatar:store("force_grid_mode", "demo:minesweeper")