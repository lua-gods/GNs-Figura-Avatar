local dance = false

local grid = require("grid_core")

local tree = {
   selection = {
   {label="🟩 Toggle Grid",onPress = function (self)
      pings.settingSync(1,(not self.toggle))
      if self.toggle then
         self.label = "🟩".." Toggle Grid"
      else
         self.label = "🟥".." Toggle Grid"
      end
      
   end, 
   toggle = true,
   remote=function (self,arg)
      self.toggle = arg[1]
      grid.enabled = self.toggle
   end},
}}

function pings.settingSync(id,...)
   tree.selection[id].remote(tree.selection[id],{...})
end

table.insert(tree.selection,{label="🏠 Return to Menu",onPress = function ()
   PANEL.loadScene("main_menu")
end})

return tree
