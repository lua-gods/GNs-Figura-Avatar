local panel = require("libraries.panel")

local clothing_type = {
   --{"Hat",require("wardrobes.Hat")},
   --{"Head",require("wardrobes.Head")},
   --{"Shirt",require("wardrobes.Shirt")},
   --{"Pants",require("wardrobes.Pants")},
   {"General",require("wardrobes.Skin")},
}

local host_clothes = {}


function pings.GNSYNCCLOTHING(...)
   host_clothes = {...}
   for key, clothing in pairs(clothing_type) do
      clothing[2]:setSelected(host_clothes[key])
   end
end

if not host:isHost() then return end

local page = panel:newPage()
local items = {}

for i, data in pairs(clothing_type) do
   host_clothes[i] = 1
   local lol = page:newElement("dropdown")
   local list = {}
   for key, value in pairs(data[2].clothes) do
      list[key] = value.name
   end
   lol:setSelectionList(list)
   lol.ON_SLIDE:register(function (id)
      data[2]:setSelected(id)
      host_clothes[i] = id
   end)
end
page:newElement("button"):setText("Sync").ON_PRESS:register(function ()
   pings.GNSYNCCLOTHING(table.unpack(host_clothes))
end)
page:newElement("returnButton")
return page