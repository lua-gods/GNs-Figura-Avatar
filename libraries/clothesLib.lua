local c = {}
local katt = require("libraries.KattEventsAPI")

---A Selection Handler of what you can wear
---@class Wardrobe
---@field clothes table # a bunch of clothes you can wear
---@field texturable table # parts that rely on texture based clothing
---@field selected integer # an index of what youre currently wearing
---@field lastSelected integer # an index of what youre last wearing
---@field ON_CHANGE KattEvent
local Wardrobe = {}
Wardrobe.__index = Wardrobe

---@param name string
---@return Wardrobe
function c.newWardrobe(name)
   ---@type Wardrobe
   local compose = {
      name = name,
      clothes = {},
      texturable = {},
      lastSelected = 1,
      selected = 1,
      ON_CHANGE=katt.newEvent()
   }
   setmetatable(compose,Wardrobe)
   return compose
end

---@param index integer
---@return Wardrobe
function Wardrobe:setSelected(index)
   self.selected = (index - 1) % (#self.clothes) + 1
   if self.lastSelected ~= self.selected then
      self:update()
      self.lastSelected = self.selected
   end
   
   return self
end

function Wardrobe:getSelected()
   return self.clothes[self.selected]
end

---Updates the Wardrobe. use this when the Clothes arent doing what you want
---@return Wardrobe
function Wardrobe:update()
   if #self.clothes > 0 then
      self.clothes[self.lastSelected]:use(false)
      self.clothes[self.selected]:use(true)
      if self.clothes[self.selected].texture then
         for key, value in pairs(self.texturable) do
            value:setPrimaryTexture("CUSTOM",self.clothes[self.selected].texture)
         end
      end
   end
   self.ON_CHANGE:invoke(self.lastSelected,self.selected)
   return self
end

---@param tbl table
---@return Wardrobe
function Wardrobe:setSelection(tbl)
   self.clothes = tbl
   self:update()
   return self
end

---@param tbl table
---@return Wardrobe
function Wardrobe:setTexturable(tbl)
   self.texturable = tbl
   return self
end

---Trigger this once youve added all the clothes
---@param default integer|nil
---@return Wardrobe
function Wardrobe:commit(default)
   if not default then default = 1 end
   for key, value in pairs(self.clothes) do
      if key ~= default then
         value:use(false)
      end
   end
   if self.clothes[default] then
      self.clothes[default]:use(true)
   end
   return self
end

---A piece of what you can wear
---@class Clothes 
---@field name string|nil
---@field texture Texture # a texture for texture based clothing parts for the Wardrobe
---@field accessories table # a table of GroupParts thats part of the Clothes
---@field custom_properties table # custom duh 
---@field EQUIPED_CHANGED KattEvent
local Clothes = {}
Clothes.__index = Clothes

---@param name string|nil
---@return Clothes
function c.newClothes(name)
   ---@type Clothes
   local compose = {
      name = name,
      texture = nil,
      accessories = {},
      custom_properties = {},
      EQUIPED_CHANGED=katt:newEvent(),
   }
   setmetatable(compose,Clothes)
   return compose
end

---Sets the texture for the Wardrobe's texture based clothing
---@param texture Texture
---@return Clothes
function Clothes:setTexture(texture)
   if type(texture) == "nil" then
      error("Given Texture is invalid (nil)")
   end
   self.texture = texture
   return self
end

---Sets the ModelParts the Clothes is a part of
---@param tbl table
---@return Clothes
function Clothes:setAccessories(tbl)
   if type(tbl) ~= "table" then
      self.accessories = {tbl}
   else
      self.accessories = tbl
   end
   return self
end

---@param property any
---@param data any
---@return Clothes
function Clothes:set(property,data)
   self.custom_properties[property] = data
   return self
end

---@param toggle boolean
---@return Clothes
function Clothes:use(toggle)
   if self.accessories then
      for key, value in pairs(self.accessories) do
         if type(value) == "function" then
            value(toggle)
         else
            value:setVisible(toggle)
         end
      end
      self.EQUIPED_CHANGED:invoke(toggle)
   end
   return self
end

return c