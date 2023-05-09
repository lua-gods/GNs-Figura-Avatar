local c = require"libraries.clothesLib"
local shirt = c.newWardrobe("hat")
shirt:setSelection{
   c.newClothes():setAccessories{},
   c.newClothes():setAccessories{nil,models.gn.base.Torso.Head.ChristmasHat},
   c.newClothes():setAccessories{nil,models.gn.base.Torso.Head.topHat},
   c.newClothes():setAccessories{nil,models.gn.base.Torso.Head.senseiHat},
}:commit()

return shirt