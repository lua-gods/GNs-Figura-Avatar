local config = {
   hud = models.menu
}

local lib = {}

---@alias ScalingMethod string
---| "FIT_CONTENT"
---| "FIXED"

---@class Label
---@field _pos Vector2
---@field _size Vector2
---@field _anchor Vector2
---@field _scaling_method ScalingMethod
local Label = {}
Label.__index = Label

function lib:newLabel()
   local compose = {
      _pos = vectors.vec2(0,0),
      _size = vectors.vec2(16,16),
      _anchor = vectors.vec2(0,0),
      _text = "Sample Text",
   }
   setmetatable(compose,Label)
   return compose
end

function Label:pos(x,y)
   self._pos = vectors.vec2(x,y)
   return self
end

function Label:anchor(x,y)
   self._anchor = vectors.vec2(x,y)
   return self
end

---@param type ScalingMethod
---@return Label
function Label:scalingMethod(type)
   self._scaling_method = type
   return self
end

return lib