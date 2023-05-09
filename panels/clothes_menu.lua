local config = {
   clothes_path = "wardrobes"
}

local wardrobes = {}
local current_clothes = {}

function pings.clothingApplyAll(...)
   local pack = {...}
   for i, value in pairs(wardrobes) do
      current_clothes[i] = pack[i]
      value:setSelected(pack[i])
      value:update()
   end
   if player:isLoaded() then
      sounds:playSound("minecraft:item.armor.equip_leather",player:getPos())
   end
end

local clothes_menu = {
   selection = {
      
   }
}

local clothes_list = {
   {"wardrobes.Hat","< 🎩 Hat >"},
   {"wardrobes.Head","< 💀 Head >"},
   {"wardrobes.Shirt","< 👕 Shirt >"},
   {"wardrobes.Pants","< 👖 Pants >"},
   {"wardrobes.Weapon","< 🔪 Weapon >"},
}

table.insert(clothes_menu.selection,{label=""})
table.insert(clothes_menu.selection,{})

for index, data in pairs(clothes_list) do
   local name = ""
   local s = require(data[1])
   --print(name,s,s.clothes)
   current_clothes[index] = s.selected
   wardrobes[index] = s
   table.insert(clothes_menu.selection,{
      label = data[2], onPress = function ()
         s:setSelected(s.selected + 1)
      end
   })
end

table.insert(clothes_menu.selection,{})
table.insert(clothes_menu.selection,{
   label="📨 Sync to Everyone",onPress=function ()
      local package = {}
      for i, value in pairs(wardrobes) do
         current_clothes[i] = value.selected
         package[i] = value.selected
      end
      pings.clothingApplyAll(table.unpack(package))
   end
})
table.insert(clothes_menu.selection,{label="🏠 Return to Menu",onPress = function ()
   PANEL.loadScene("main_menu")
   for i, value in pairs(current_clothes) do
      wardrobes[i]:setSelected(value)
   end
end})

return clothes_menu