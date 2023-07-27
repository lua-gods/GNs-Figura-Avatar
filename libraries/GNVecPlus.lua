local v = {}


---comment
---@param dir Vector3
---@return unknown
function v.toAngle(dir)
   local x = math.atan2(dir.y, dir.x)
   local y = math.atan2(-dir.z, math.sqrt(dir.x * dir.x + dir.y * dir.y))
   
   return vectors.vec3(math.deg(x), math.deg(y), 0)
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


---@param vector Vector3
---@param normal Vector3
---@return Vector3
function v.flattenVector3ToNormal(vector, normal)
   -- Normalize the input normal vector
   local normalizedNormal = normal:normalize()
   
   -- Calculate the projection of the input vector onto the normal
   local projectionMagnitude = vector:dot(normalizedNormal)
   local projection = normalizedNormal * projectionMagnitude
   
   -- Subtract the projection from the original vector to get the flattened vector
   local flattenedVector = vector - projection
   
   return flattenedVector
end

function v.ray2Plane(position, direction, planeNormal, planeOrigin)
   -- Make sure the direction and plane normal are normalized
   local normalizedDirection = direction:normalized()
   local normalizedPlaneNormal = planeNormal:normalized()

   -- Calculate the dot product of the direction with the plane normal
   local dotProduct = normalizedDirection:dot(normalizedPlaneNormal)

   -- Check if the line is parallel to the plane
   if math.abs(dotProduct) < 1e-6 then
       return nil -- No intersection, the line is parallel to the plane
   end

   -- Calculate the distance from the position to the plane along the direction vector
   local distanceToPlane = normalizedPlaneNormal:dot(planeOrigin - position) / dotProduct

   -- Calculate the intersection point
   local intersectionPoint = position + normalizedDirection * distanceToPlane

   return intersectionPoint
end



---@param rot Vector3|Vector2
---@return Vector3
function v.toDir(rot)
   local mat = matrices.mat4()
   mat:rotateX(rot.x):rotateY(-rot.y)
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

---@param vec Vector2|Vector3|Vector4|
function v.applyfunc(vector,func)
   local new = {}
   for i, value in ipairs{vector:unpack()} do
      new[i] = func(value)
   end
   return vec(table.unpack(new))
end

return v