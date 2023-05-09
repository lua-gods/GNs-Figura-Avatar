local c = require"libraries.clothesLib"
--local eye = require("libraries.eyesLib")
local head = c.newWardrobe("head")
---@param self Wardrobe
head.ON_CHANGE:register(function (new,old)
   local current_clothes = head.clothes[new]
   --if current_clothes.custom_properties.leftEyeOffset then
   --   local p = current_clothes.custom_properties
   --   eye:setPreset(p.leftEyeClamp,p.leftEyeOffset,p.leftEyeMultiply,p.rightEyeClamp,p.rightEyeOffset,p.rightEyeMultiply,p.eyelashesOffset,p.offset)
   --end
end)
head:setSelection{
   c.newClothes():setTexture(textures["clothes.default_skin"]):set("offset",vec(0,0)):set("eyelashesOffset",vec(0,0))
   :set("leftEyeClamp",vec(-1,1,0,0)):set("leftEyeOffset",vec(0.5,0)):set("leftEyeMultiply",vec(1,0.5)):
   set("rightEyeClamp",vec(-1,1,0,0)):set("rightEyeOffset",vec(-0.5,0)):set("rightEyeMultiply",vec(1,0.5)),

   c.newClothes():setTexture(textures["clothes.christmas"]):set("offset",vec(0,0)),
   c.newClothes():setTexture(textures["clothes.sensei"]),
   c.newClothes():setTexture(textures["clothes.BW"]),
}:setTexturable{
   models.gn.base.Torso.Head.HClothing
}:commit()
--c.newClothes():setTexture(textures["clothes.default_skin"]):setCustomProperty("eyes",{vec(-1,1,-1,1),vec(0.5,0),vec(1,0.5),vec(-1,1,-1,1),vec(-0.5,0),vec(1,0.5)}),
--c.newClothes():setTexture(textures["clothes.christmas"]):setCustomProperty("eyes",{vec(-1,1,-1,1),vec(0.5,0),vec(1,0.5),vec(-1,1,-1,1),vec(-0.5,0),vec(1,0.5)}),
--c.newClothes():setTexture(textures["clothes.luiji"]):setCustomProperty("eyes",{vec(0,1,-1,1),vec(0,1),vec(2,1),vec(-1,0,-1,1),vec(0,1),vec(2,1)}),
--c.newClothes():setTexture(textures["clothes.snake"]):setCustomProperty("eyes",{vec(0,1,-1,1),vec(0,1),vec(2,0),vec(-1,0,-1,1),vec(0,1),vec(2,0)}),
--c.newClothes():setTexture(textures["clothes.link"]):setCustomProperty("eyes",{vec(0,1,-1,1),vec(0,0),vec(2,0),vec(-1,0,-1,1),vec(0,0),vec(2,0)}),
--c.newClothes():setTexture(textures["clothes.jesse"]):setCustomProperty("eyes",{vec(0,1,-1,1),vec(0,3),vec(2,0),vec(-1,0,-1,1),vec(0,3),vec(2,0)}),
return head