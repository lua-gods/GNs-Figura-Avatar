local GNCL = require("libraries.GNClothingLib")

local everything = GNCL:newWardrobe(64,64)
everything:setDefaultTexture(textures["textures.skin.black_skin"])
everything:setTexturable{
   models.gn.base.Torso.Head.HClothing,
   models.gn.base.Torso.Body.Shirt.BClothing,
   models.gn.base.Torso.LeftArm.LAClothing,
   models.gn.base.Torso.RightArm.RAClothing,
   models.gn.base.LeftLeg.LLClothing,
   models.gn.base.RightLeg.RLClothing}
local hairGN = everything:newClothing("hairGN"):setTexture(textures["textures.hair.default"]):setLayer("hair")

local faceGN = everything:newClothing("faceGN"):setTexture(textures["textures.face.t_eyes"]):setLayer("eyes")

local whiteLongSleeves = everything:newClothing("whiteLongSleeves"):setTexture(textures["textures.shirt.white_long_sleeves"])
local blackSleeves = everything:newClothing("whiteLongSleeves"):setTexture(textures["textures.shirt.black_sleeves"])
local green_tie = everything:newClothing("tieGreen"):setTexture(textures["textures.shirt.green_buisness_tie"]):setLayer("tie")
local blackPants = everything:newClothing("blackPants"):setTexture(textures["textures.pants.black_pants"]):setLayer("pants")
local GNsword = everything:newClothing("GNsword"):setLayer("weapon"):setAccessories{
   models.gn.base.Torso.Body.sword
}
faceGN:equip()
whiteLongSleeves:equip()
--blackSleeves:equip()
hairGN:equip()

GNsword:equip()

green_tie:equip()
blackPants:equip()