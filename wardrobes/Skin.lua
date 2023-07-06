local c = require"libraries.clothesLib"
local shirt = c.newWardrobe("shirt")
shirt:setSelection{
   c.newClothes("Default"):setTexture(textures["clothes.default_skin"]),
   c.newClothes("Christmas"):setTexture(textures["clothes.christmas"]),
   c.newClothes("Grayscale"):setTexture(textures["clothes.BW"]),
   c.newClothes("Sensei"):setTexture(textures["clothes.sensei"]),
}:setTexturable{
   models.gn.base.Torso.Body.Shirt,
   models.gn.base.Torso.LeftArm.LAClothing,
   models.gn.base.Torso.RightArm.RAClothing,
   models.gn.base.Torso.Head.HClothing,
   models.gn.base.LeftLeg.LLClothing,
   models.gn.base.RightLeg.RLClothing
}:commit()
return shirt