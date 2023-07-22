--[[______   __
  / ____/ | / /
 / / __/  |/ /
/ /_/ / /|  /
\____/_/ |_/ ]]
local lib = {}
local wardrobes = {}
local someone_updated = false
local katt = require("libraries.KattEventsAPI")

---@class Clothing
---@field accessories table<any,ModelPart>
---@field texture Texture?
---@field name string
---@field parent Wardrobe
---@field equipLayer integer
---@field metadata table
---@field TOGGLED KattEvent
local Clothing = {}
Clothing.__index = Clothing
Clothing.__type = "clothing"

---Sets the texture of the clothing.
---@param texture Texture
function Clothing:setTexture(texture)
   self.texture = texture
   self.parent:forceUpdate()
   return self
end

---Sets the modelparts thats gonna be visible when the clothing is equiped
---@param tbl any
---@return Clothing
function Clothing:setAccessories(tbl)
   self.accessories = tbl
   if self.equipLayer then
      for key, value in pairs(tbl) do
         value:setVisible(true)
      end
   else
      for key, value in pairs(tbl) do
         value:setVisible(false)
      end
   end
   return self
end

function Clothing:equip()
   local found = false
   if self.layerName then
      for i, viewing in pairs(self.parent.equiped) do
         if viewing.layerName == self.layerName then
            self.parent.equiped[i]:unequip()
            self.parent.equiped[i] = self
            found = true
         end
      end
   end
   if not found then
      local layer = #self.parent.equiped + 1
      self.parent.equiped[layer] = self
      self.equipLayer = layer
   end
   self.parent:forceUpdate()
   self.TOGGLED:invoke(true)
   for key, value in pairs(self.accessories) do
      value:setVisible(true)
   end
   return self
end

function Clothing:unequip()
   self.parent.equiped[self.equipLayer] = nil
   self.equipLayer = nil
   self.parent:forceUpdate()
   for key, value in pairs(self.accessories) do
      value:setVisible(false)
   end
   self.TOGGLED:invoke(false)
   return self
end

---Sets the layer of this clothing when equiped.  
---* if an existing clothing is equiped with the same layer, that clothing will be disabled and replaced with this.
---* this is useful for only allowing one clothing to be worn at a time.
---@param layer_name string?
function Clothing:setLayer(layer_name)
   self.layerName = layer_name
   return self
end

---sets a metadata
---@param tbl table
function Clothing:appendMetadata(tbl)
   for key, value in pairs(tbl) do
      self.metadata[key] = value
   end
   return self
end

---@class Wardrobe
---@field clothings table<any,Clothing>
---@field bakeTexture Texture?
---@field defaultTexture Texture?
---@field bakeTextureSize Vector2
---@field defaut_texture Texture
---@field texturables table<any,ModelPart>
---@field equiped table<integer,integer>
---@field EQUIPED_CHANGED KattEvent
local Wardrobe = {}
Wardrobe.__index = Wardrobe
Wardrobe.__type = "wardrobe"

local clothing_id = 0
function Wardrobe:newClothing(name)
   clothing_id = clothing_id + 1
   ---@type Clothing
   local compose = {
      accessories = {},
      texture = nil,
      metadata = {},
      parent = self,
      TOGGLED = katt.newEvent(),
   }
   if name then
      compose.name = name
   else
      compose.name = "unnamed_clothing#" .. clothing_id
   end
   setmetatable(compose,Clothing)
   self.clothings[compose.name] = compose
   return compose
end

-->====================[ Wardobe ]====================<--

---Generates an empty Wardrobe.
---@param bake_size_x integer
---@param bake_size_y integer
---@return Wardrobe
function lib:newWardrobe(bake_size_x,bake_size_y)
   local id = #wardrobes + 1
   ---@type Wardrobe
   local compose = {
      clothings = {},
      bakeTexture = textures:newTexture("GNCLOTHINGSYSTEMWARDOBE" .. id,bake_size_x,bake_size_y),
      bakeTextureSize = vectors.vec2(bake_size_x,bake_size_y),
      equiped = {},
      texturables = {},
      EQUIPED_CHANGED = katt.newEvent(),
      update = false,
      id = id,
   }
   compose.bakeTexture:applyFunc(0,0,64,64,function (clr,x,y)
      return textures["clothes.default_skin"]:getPixel(x,y)
   end)
   setmetatable(compose,Wardrobe)
   wardrobes[id] = compose
   return compose
end

---@param default_texture Texture
function Wardrobe:setDefaultTexture(default_texture)
   self.defaultTexture = default_texture
   self:forceUpdate()
end

---@param tbl table<any,ModelPart>
function Wardrobe:setTexturable(tbl)
   for key, value in pairs(tbl) do
      value:setPrimaryTexture("CUSTOM",self.bakeTexture)
   end
   self.texturables = tbl
   return self
end

function Wardrobe:forceUpdate()
   self.update = true
   someone_updated = true
   return self
end

-->====================[ Rendering ]====================<--

events.RENDER:register(function (delta, context)
   if someone_updated then
      ---@type integer, Wardrobe

      for key, w in pairs(wardrobes) do
         if w.update then
            w.update = false
            w.EQUIPED_CHANGED:invoke()
            w.bakeTexture:applyFunc(0,0,w.bakeTextureSize.x,w.bakeTextureSize.y,function (clr,x,y)
               return w.defaultTexture:getPixel(x,y)
            end)
            for i, clothing in pairs(w.equiped) do
               if clothing.texture then    
                  local dim = clothing.texture:getDimensions()
                  if dim == w.bakeTextureSize then
                     w.bakeTexture:applyFunc(0,0,w.bakeTextureSize.x,w.bakeTextureSize.y,function (clr,x,y)
                        local sample = clothing.texture:getPixel(x,y)
                        return math.lerp(clr,sample.xyz:augmented(),sample.w)
                     end)
                  end
               end
            end
            w.bakeTexture:update()
         end
      end
      someone_updated = false
   end
end)

return lib