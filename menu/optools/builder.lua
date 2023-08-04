local panel = require("libraries.panel")
local lineLib = require("libraries.GNLineLib")
local vecp = require("libraries.GNVecPlus")

local A, B,Size = vectors.vec3(),vectors.vec3(),vectors.vec3()
local A_normal
local From, To = vectors.vec3(),vectors.vec3()
local last_selected_face,selected_face

-->==========[ Flags ]==========<--
local on_top = false
local flat_top = true
local always_on_top = false

local face_lookp = {
   north = vectors.vec3(0,0,-1),
   south = vectors.vec3(0,0,1),
   west = vectors.vec3(-1,0,0),
   east = vectors.vec3(1,0,0),
   up = vectors.vec3(0,1,0),
   down = vectors.vec3(0,-1,0),
}

---@param x number|Vector3
---@param y number?
---@param z number?
local function setA(x,y,z)
   local v 
   if type(x) == "Vector3" then v = x:copy()
   else
      v = vectors.vec3(x,y,z)
   end
   A = v
   local highest = vectors.vec3(
      math.max(A.x,B.x),
      math.max(A.y,B.y),
      math.max(A.z,B.z)
   )
   local lowest = vectors.vec3(
      math.min(A.x,B.x),
      math.min(A.y,B.y),
      math.min(A.z,B.z)
   )
   From = lowest
   To = highest
   Size = To-From
end

---@param x number|Vector3
---@param y number?
---@param z number?
local function setB(x,y,z) 
   local v 
   if type(x) == "Vector3" then v = x:copy()
   else
      v = vectors.vec3(x,y,z)
   end
   B = v
   local highest = vectors.vec3(
      math.max(A.x,B.x),
      math.max(A.y,B.y),
      math.max(A.z,B.z)
   )
   local lowest = vectors.vec3(
      math.min(A.x,B.x),
      math.min(A.y,B.y),
      math.min(A.z,B.z)
   )
   From = lowest
   To = highest
   Size = To-From
end

local cube_points = {
   vectors.vec3(0, 0, 0),
   vectors.vec3(1, 0, 0),
   vectors.vec3(0, 1, 0),
   vectors.vec3(1, 1, 0),

   vectors.vec3(0, 0, 1),
   vectors.vec3(1, 0, 1),
   vectors.vec3(0, 1, 1),
   vectors.vec3(1, 1, 1)
}

local connection_points = {
   {1, 2},{3, 4},{1, 3},{2, 4},
   {5, 6},{7, 8},{5, 7},{6, 8},
   {1, 5},{2, 6},{3, 7},{4, 8}
}
local selection_lines = {}
local selection_faces = {}

local function b2n(boolean)
   return boolean and 1 or 0
end
 
local function updateTransform()
   To:add(1,1,1)
   Size:add(1,1,1)
   local depth = 0.99
   if always_on_top then
      depth = 0.1
   end
   for key, line in pairs(selection_lines) do
      local value = connection_points[key]
      line:from(math.lerp(From,To,cube_points[value[1]])):to(math.lerp(From,To,cube_points[value[2]])):depth(depth - 1):width(0.1)
   end
   selection_faces.north:setMatrix(matrices.mat4():scale(-Size.x,Size.y,0):translate(To:copy():sub(Size.x,0))*depth)
   selection_faces.south:setMatrix(matrices.mat4():scale(-Size.x,-Size.y,0):translate(From) * depth)
   selection_faces.west:setMatrix(matrices.mat4():scale(-Size.z,Size.y,0):rotate(0,90):translate(To) * depth)
   selection_faces.east:setMatrix(matrices.mat4():scale(-Size.z,Size.y,0):rotate(0,-90):translate(To:copy():sub(Size.x,0,Size.z)) * depth)
   selection_faces.up:setMatrix(matrices.mat4():scale(-Size.x,-Size.z,0):rotate(90,0):translate(To:copy():sub(Size.x,0,Size.z)) * depth)
   selection_faces.down:setMatrix(matrices.mat4():scale(-Size.x,-Size.z,0):rotate(-90,0):translate(To:copy():sub(Size.x,Size.y,0)) * depth)
   To:sub(1,1,1)
   Size:sub(1,1,1)
end

for key, value in pairs(connection_points) do
   selection_lines[#selection_lines + 1] = lineLib:newLine()
   local m = lineLib.config.model_path
   selection_faces.north = m:newSprite("BuilderSelectionFaceNorth")
   selection_faces.east = m:newSprite("BuilderSelectionFaceEast")
   selection_faces.west = m:newSprite("BuilderSelectionFaceWest")
   selection_faces.south = m:newSprite("BuilderSelectionFaceSouth")
   selection_faces.up = m:newSprite("BuilderSelectionFaceUp")
   selection_faces.down = m:newSprite("BuilderSelectionFaceDown")
end

for key, value in pairs(selection_faces) do
   value:texture(lineLib.config.white_texture):renderType("EMISSIVE"):color(0.5,0.5,0.5)
end

updateTransform()

function pings.buildSetA(pos)
   setA(pos)
   if not host:isHost() then
      updateTransform()
   end
end

function pings.buildSetB(pos)
   setB(pos)
   if not host:isHost() then
      updateTransform()
   end
end

function pings.setOnTop(toggle)
   always_on_top = toggle
   updateTransform() 
end

if not host:isHost() then return end
local page = panel:newPage()

page:newElement("toggleButton"):setText("on Top").ON_TOGGLE:register(function (toggle)on_top = toggle end)
page:newElement("toggleButton"):setText("Render on Top").ON_TOGGLE:register(function (toggle) pings.setOnTop(not always_on_top)end)
page:newElement("dropdown"):setText("Mode"):setSelectionList{"Select","Select Extrude","Move"}
page:newElement("returnButton")

local input = keybinds:fromVanilla("key.use")

input.press = function ()
   local selected,_,dir = player:getTargetedBlock()
   local pos = selected:getPos()
   A_normal = face_lookp[dir]:copy()
   if on_top then
      pos:add(face_lookp[dir])
   end
   if page.is_active then
      pings.buildSetA(pos)
   end
end

input.release = function ()
   pings.buildSetB(B)
end

events.TICK:register(function ()
   local cpos = client:getCameraPos()
   local cdir = vecp.toDir(client:getCameraRot())
   if page.is_active or (not host:isHost()) then
      if input:isPressed() then
         local selected,_,dir = player:getTargetedBlock()
         local pos = selected:getPos()
         if on_top then
            pos:add(face_lookp[dir])
         end
         local offset = vectors.vec3(math.max(A_normal.x,0),math.max(A_normal.y,0),math.max(A_normal.z,0))
         local r = vecp.ray2Plane(cpos,cdir,A_normal,A+offset)
         if r then
            pos = r-offset*0.9
            pos = vecp.applyfunc(pos,math.floor)
         else
            pos = A:copy()
         end
         setB(pos)
         updateTransform()
      end
      To:add(1,1,1)

      local depth_cap = math.huge
      if not always_on_top then
         depth_cap = (cpos-({player:getTargetedBlock()})[2]):length()+0.1
      end
      local sf
      local up_plane = vecp.ray2Plane(cpos,cdir,face_lookp.up,math.lerp(From,To,math.map(face_lookp.up,-1,1,0,1)))
      if up_plane and cdir.y < 0 and depth_cap >= (up_plane-cpos):length() and up_plane >= From and up_plane <= To then
         sf = "up"
      end
      local down_plane = vecp.ray2Plane(cpos,cdir,face_lookp.down,math.lerp(From,To,math.map(face_lookp.down,-1,1,0,1)))
      if down_plane and cdir.y > 0 and depth_cap >= (down_plane-cpos):length() and down_plane >= From and down_plane <= To then
         sf = "down"
      end
      local north_plane = vecp.ray2Plane(cpos,cdir,face_lookp.north,math.lerp(From,To,math.map(face_lookp.north,1,-1,0,1)))
      if north_plane and cdir.z < 0 and depth_cap >= (north_plane-cpos):length() and north_plane >= From and north_plane <= To then
         sf = "north"
      end

      local south_plane = vecp.ray2Plane(cpos,cdir,face_lookp.south,math.lerp(From,To,math.map(face_lookp.south,1,-1,0,1)))
      if south_plane and cdir.z > 0 and depth_cap >= (south_plane-cpos):length() and south_plane >= From and south_plane <= To then
         sf = "south"
      end

      local east_plane = vecp.ray2Plane(cpos,cdir,face_lookp.east,math.lerp(From,To,math.map(face_lookp.east,1,-1,0,1)))
      if east_plane and cdir.x > 0 and depth_cap >= (east_plane-cpos):length() and east_plane >= From and east_plane <= To then
         sf = "east"
      end

      local west_plane = vecp.ray2Plane(cpos,cdir,face_lookp.west,math.lerp(From,To,math.map(face_lookp.west,1,-1,0,1)))
      if west_plane and cdir.x < 0 and depth_cap >= (west_plane-cpos):length() and west_plane >= From and west_plane <= To then
         sf = "west"
      end
      if sf ~= selected_face then
         last_selected_face = selected_face
         selected_face = sf
         if last_selected_face then
            selection_faces[last_selected_face]:color(0.3,0.3,0.3)
         end
         if selected_face then
            selection_faces[selected_face]:color(0.5,0.5,0.5)
         end
      end
      To:sub(1,1,1)
   end
end)

return page
