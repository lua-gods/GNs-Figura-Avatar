local panel = require("libraries.panel")

local clothing_type = {
   {"Hat",require("wardrobes.Hat")},
   {"Head",require("wardrobes.Head")},
   {"Shirt",require("wardrobes.Shirt")},
   {"Pants",require("wardrobes.Pants")},
}

local host_clothes = {}


function pings.GNSYNCCLOTHING(...)
   host_clothes = {...}
   for key, clothing in pairs(clothing_type) do
      clothing[2]:setSelected(host_clothes[key])
   end
end

if not host:isHost() then return end

local button = panel.elements.button.new(panel)
button:setText("Sync").ON_PRESS:register(function ()
   pings.GNSYNCCLOTHING(table.unpack(host_clothes))
end)

local menu = panel:newPage()
local items = {
}
for i, data in pairs(clothing_type) do
   local e = panel.elements.slider.new(panel)
   host_clothes[i] = 1
   e:setItemCount(#data[2].clothes):setText(data[1]).ON_SLIDE:register(function (slide)
      data[2]:setSelected(slide)
      host_clothes[i] = slide
   end)
   table.insert(items,e)
end


table.insert(items,button)

menu:appendElements(items)
menu:newElement("returnButton")
return menu