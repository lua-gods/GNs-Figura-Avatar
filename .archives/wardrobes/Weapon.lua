local c = require"libraries.clothesLib"
local weapon = c.newWardrobe("weapon")

local sword = c.newClothes()
local staff = c.newClothes()
sword.EQUIPED_CHANGED:register(function (equiped)require("weapons.sword").toggleSword(equiped)end)
staff.EQUIPED_CHANGED:register(function (equiped)require("weapons.staff").toggleStaff(equiped)end)
weapon:setSelection{
   sword,
   staff,
   c.newClothes(),
}:commit()
return weapon