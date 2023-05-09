local c = require"libraries.clothesLib"
local shirt = c.newWardrobe("shirt")
shirt:setSelection{
   c.newClothes():setTexture(textures["clothes.default_skin"]):setAccessories{models.gn.base.Torso.Body.Shirt.BClothing.Tie},
   c.newClothes():setTexture(textures["clothes.christmas"]),
   c.newClothes():setTexture(textures["clothes.BW"]):setAccessories{models.gn.base.Torso.Body.Shirt.BClothing.Tie},
   c.newClothes():setTexture(textures["clothes.sensei"]),
}:setTexturable{
   models.gn.base.Torso.Body.Shirt,
   models.gn.base.Torso.LeftArm.LAClothing,
   models.gn.base.Torso.RightArm.RAClothing
}:commit()
return shirt