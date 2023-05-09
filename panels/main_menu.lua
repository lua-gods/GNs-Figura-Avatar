local dance = false
local tree = {
   selection = {
   {label="👕 Clothes Menu",onPress = function ()
      PANEL.loadScene("clothes_menu")
   end},
   {label="🪧 Toggle Nameplate",value=true,onPress = function (self)
      pings.nameplateV(not self.value)
      self.value = not self.value
   end},
   {label="⚙ Settings",value=true,onPress = function (self)
      PANEL.loadScene("settings_menu")
   end},
   {},
   {label="🔒 Hide Menu",onPress = function ()
      PANEL.enabled = false
      PANEL.update()
   end}}
}

function pings.dance(toggle)
   if toggle then
      animations.gn.dance2:play()
   else
      animations.gn.dance2:stop()
   end
end
return tree