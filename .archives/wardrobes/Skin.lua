local c = require"libraries.clothesLib"
local shirt = c.newWardrobe("shirt")

local fran = c.newClothes("Default"):setTexture(textures["clothes.default_skin_fran"]):setAccessories{models.gn.base.Torso.Head.FranHair}
local PS5 = c.newClothes("Default"):setTexture(textures["clothes.default_skin_4p5"])

HIDE_MOUTH = false
FEMINE_POSE = false

fran.EQUIPED_CHANGED:register(function (toggle)
   if toggle then
      EYE_OFFSET = -1
      EYE_OFFSET_CENTER = 0.25
      HIDE_MOUTH = true
      FEMINE_POSE = true
      models.gn.base.Torso.Head.FranGlasses:setVisible(true)
      models.gn.base.Torso.Head.HClothing.Mouth:setVisible(false)
      models.gn.base.Torso.Head.HClothing.eyeLashes:setPos(0,-1,0)
   else
      EYE_OFFSET = 0
      EYE_OFFSET_CENTER = 0
      FEMINE_POSE = false
      models.gn.base.Torso.Head.FranGlasses:setVisible(false)
      models.gn.base.Torso.Head.HClothing.Mouth:setVisible(true)
      models.gn.base.Torso.Head.HClothing.eyeLashes:setPos(0,0,0)
   end
end)

PS5.EQUIPED_CHANGED:register(function (toggle)
   if toggle then
      EYE_OFFSET = 1
      EYE_OFFSET_CENTER = 0.25
      HIDE_MOUTH = true
      FEMINE_POSE = true
      models.gn.base.Torso.Head.HClothing.Mouth:setVisible(false)
      models.gn.base.Torso.Head.HClothing.eyeLashes:setPos(0,-1,0)
   else
      EYE_OFFSET = 0
      EYE_OFFSET_CENTER = 0
      FEMINE_POSE = false
      models.gn.base.Torso.Head.HClothing.Mouth:setVisible(true)
      models.gn.base.Torso.Head.HClothing.eyeLashes:setPos(0,0,0)
   end
end)

shirt:setSelection{
   c.newClothes("Default"):setTexture(textures["clothes.default_skin"]),
   c.newClothes("Christmas"):setTexture(textures["clothes.christmas"]),
   c.newClothes("Grayscale"):setTexture(textures["clothes.BW"]),
   c.newClothes("Sensei"):setTexture(textures["clothes.sensei"]),
   fran,PS5
   
}:setTexturable{
   models.gn.base.Torso.Body.Shirt,
   models.gn.base.Torso.LeftArm.LAClothing,
   models.gn.base.Torso.RightArm.RAClothing,
   models.gn.base.Torso.Head.HClothing,
   models.gn.base.LeftLeg.LLClothing,
   models.gn.base.RightLeg.RLClothing
}:commit()
return shirt