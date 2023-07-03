local toggle

local pos
local lpos
local points = 0
local rpos
local distance = 4

local update_timer = 0

local draw_queue = {}

local strokes = {}
local decay_strokes = {}

function pings.PENSETORIGIN(x,y,z)
   rpos = vectors.vec3(x,y,z)
   table.insert(draw_queue,rpos:copy())
end

function pings.PENOFFSET(x,y,z)
   rpos:add(x,y,z)
   table.insert(draw_queue,rpos:copy())
end

function pings.PENCLOSE()
   draw_queue = {}
end

function pings.PENCLEAR()
   for key, stroke in pairs(strokes) do
      for key, p in pairs(stroke.particles) do
         p:remove()
      end
   end
   strokes = {}
end



-- mouse to world space (ty GN <3, and now also by Auria <3)
local function screenToWorldSpace(distance, pos, fov, fovErr)
   local mat = matrices.mat4()
   local rot = client:getCameraRot()
   local win_size = client:getWindowSize()
   local mpos = (pos / win_size - vec(0.5, 0.5)) * vec(win_size.x/win_size.y,1)
   local fov = math.tan(math.rad(fov/2))*2 * fovErr
   if renderer:getCameraMatrix() then mat:multiply(renderer:getCameraMatrix()) end
   mat:translate(mpos.x*-fov*distance,mpos.y*-fov*distance,0)
   mat:rotate(rot.x, -rot.y, rot.z)
   mat:translate(client:getCameraPos())
   local pos = (mat * vectors.vec4(0, 0, distance, 1)).xyz
   return pos
end

local function mouseToWorldSpace(dist)
   local fov = client.getFOV()

   local mousePos = client:getMousePos()
   local win = client:getWindowSize()
   local pos = vectors.worldToScreenSpace(screenToWorldSpace(dist, mousePos, fov, 1)).xy
   local mousePos2 = (mousePos / win * 2 - 1)
   local fovErr =  mousePos2:length() / pos:length()

   return screenToWorldSpace(dist, mousePos, fov, fovErr)
end



local draw = keybinds:newKeybind("GNPenDraw","key.mouse.left",true):onPress(function ()
   lpos = nil
   points = 0
end):onRelease(function ()
   pings.PENCLOSE()
end)

local ctrl = keybinds:newKeybind("PEN UNDO","key.keyboard.left.control")
local z = keybinds:newKeybind("PEN UNDO","key.keyboard.z"):onPress(function ()
   if ctrl:isPressed() then
      pings.PENCLEAR()
   end
end)

local compose_id = 0
---@param from Vector3
---@param to Vector3
local function drawLine(from,to)
   local stroke = {
      id = compose_id,
      from = from,
      to = to,
      particles = {}
   }
   local distance = math.ceil((from-to):length() * 10)
   for i = 1, distance, 1 do
      stroke.particles[i] = particles:newParticle("minecraft:end_rod",math.lerp(from,to,i/distance)):setLifetime(100000000):gravity(0):setColor(0.5,1,0.5)
   end
   table.insert(strokes,stroke)
end

local function c(f)
   return math.floor(f * 100) / 100
end

if host:isHost() then
   events.WORLD_TICK:register(function ()
      if toggle and toggle.toggle then
         if host:isChatOpen() then
            update_timer = update_timer + 1
            renderer.renderHUD = false
            if draw:isPressed()  then
               if update_timer >= 1 then
                  update_timer = 0
                  
                  points = points + 1
                  pos = mouseToWorldSpace(distance)
                  if points == 1 then
                     pings.PENSETORIGIN(c(pos.x),c(pos.y),c(pos.z))
                  else
                     pings.PENOFFSET(c(pos.x-lpos.x),c(pos.y-lpos.y),c(pos.z-lpos.z))
                  end
                  if points > 20 then
                     points = 0
                  end
                  lpos = pos:copy()
               end
            end
         else
            renderer.renderHUD = true
         end
      end
   end)
end

config:setName("just GN")
local state = (config:load("pen") == true)

events.WORLD_TICK:register(function ()
   if #draw_queue > 1 then
      drawLine(draw_queue[1],draw_queue[2])
      table.remove(draw_queue,1)
   end
end)

---@param page PanelPage
return function (page)
   toggle = page:newElement("toggleButton"):setText("Pen")
   page:newElement("slider"):setItemCount(20).ON_SLIDE:register(function (value)
      distance = value
   end)
   toggle:setToggle(state,true)
   toggle.ON_TOGGLE:register(function (toggle)
      config:setName("just GN")
      config:save("pen",toggle)
      if not toggle then
         renderer.renderHUD = true
      end
   end)
end