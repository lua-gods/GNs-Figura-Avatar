local v = {}


---@param offset Vector3
---@return Vector3
function v.toAngle(offset)
   local y = math.atan(offset.x,offset.z)
   local result = vectors.vec3(math.atan((math.sin(y)*offset.x)+(math.cos(y)*offset.z),offset.y),y)
   result = vectors.vec3(result.x,result.y,0)
   result = (result / 3.14159) * 180
   return result
end

---@param x number
---@param y number
---@param z number
---@return Vector3
function v.toAngleUnpacked(x,y,z)
   local yrot = math.atan(x,z)
   local result = vectors.vec3(math.atan((math.sin(yrot)*x)+(math.cos(yrot)*z),y),yrot)
   result = vectors.vec3(result.x,result.y,0)
   result = (result / 3.14159) * 180
   return result
end


---@param rot Vector3
---@return Vector3
function v.toDir(rot)
   local mat = matrices.mat4()
   mat:rotate(rot)
   return mat.c3.xyz
end

---@param x number
---@param y number
---@param z number
---@return Vector3
function v.toDirUnpacked(x,y,z)
   local mat = matrices.mat4()
   mat:rotate(x,y,z)
   return mat.c3.xyz
end

---@param vector Vector
---@param step number
---@return Vector2|Vector3|Vector4|Vector5|Vector6
function v.snap(vector,step)
   local pack = {vector:unpack()}
   for i, val in pairs(pack) do
      pack[i] = math.floor(val/step+0.5)*step
   end
   return vec(table.unpack(pack))
end

return v