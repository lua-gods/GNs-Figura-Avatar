local c = require"libraries.clothesLib"
local pants = c.newWardrobe("pants")
pants:setSelection{
   c.newClothes():setTexture(textures["clothes.default_skin"]),
   c.newClothes():setTexture(textures["clothes.christmas"]),
   c.newClothes():setTexture(textures["clothes.sensei"])
   :setAccessories{models.gn.base.LeftLeg.senseiL,models.gn.base.RightLeg.senseiR},
   c.newClothes():setTexture(textures["clothes.BW"]),
}:setTexturable{
   models.gn.base.LeftLeg.LLClothing,
   models.gn.base.RightLeg.RLClothing}:commit()
return pants
