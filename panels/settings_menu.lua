local dance = false

local tree = {
   selection = {
   {label="👕 Clothes Menu",onPress = function ()
      PANEL.loadScene("clothes_menu")
   end},
}}


table.insert(tree.selection,{label="🏠 Return to Menu",onPress = function ()
   PANEL.loadScene("main_menu")
end})

return tree
