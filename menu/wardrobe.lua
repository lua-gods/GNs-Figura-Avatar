local GNCL = require("libraries.GNClothingLib")

local margin = "---------------------"

local everything = GNCL:newWardrobe(64,64)
everything:setDefaultTexture(textures["textures.skin.black_skin"])
everything:setTexturable{
   models.gn.base.Torso.Head.HClothing,
   models.gn.base.Torso.Body.Shirt.BClothing,
   models.gn.base.Torso.LeftArm.LAClothing,
   models.gn.base.Torso.RightArm.RAClothing,
   models.gn.base.LeftLeg.LLClothing,
   models.gn.base.RightLeg.RLClothing}
local hairGN = everything:newClothing("Hair GN"):setTexture(textures["textures.hair.default"]):setLayer("hair")
local hairScarlet = everything:newClothing("Hair Scarlet"):setTexture(textures["textures.hair.scarlet"])

local faceGN = everything:newClothing("Face Male"):setTexture(textures["textures.face.t_eyes"]):setLayer("eyes")

local whiteLongSleeves = everything:newClothing("Long Sleeves White"):setTexture(textures["textures.shirt.white_long_sleeves"])
local blackSleeves = everything:newClothing("Black Jacket"):setTexture(textures["textures.shirt.black_sleeves"])
local green_tie = everything:newClothing("Tie Green"):setTexture(textures["textures.shirt.green_buisness_tie"]):setLayer("tie")
local blackPants = everything:newClothing("Pants Black"):setTexture(textures["textures.pants.black_pants"]):setLayer("pants")
local GNsword = everything:newClothing("Sword GN"):setLayer("weapon"):setAccessories{
   models.gn.base.Torso.Body.sword
}

faceGN:equip()
whiteLongSleeves:equip()
--blackSleeves:equip()
hairGN:equip()
GNsword:equip()

green_tie:equip()
blackPants:equip()

local id = {}
local reverse_id = {}

do
   local i = 0
   for key, value in pairs(everything.clothings) do
      i = i + 1
      id[i] = {id = key, obj = value}
      reverse_id[key] = i
   end
end

local selection = {}

local function rebuildClothing(zip)
   for key, value in pairs(everything.clothings) do
      value:unequip()
   end
   for key, value in pairs(zip) do
      id[value].obj:equip()
   end
end

function pings.GNWARDROBESYNC(...)
   rebuildClothing{...}
end

if not IS_HOST then return end

local panel = require("libraries.panel")
local page = panel:newPage()
local appendButton

local function appendClothing(name)
   local value = everything.clothings[name]
   local new = page:newElement("button",1):setText(value.name)
   new.ON_RELEASE:register(function (self)
      new:setColorRGB()
      if #page.elements - panel.selected_index < 4 then
         self:clearTasks()
         table.remove(page.elements,panel.selected_index)
      end
      panel:rebuild()
   end)
   new.ON_PRESS:register(function ()
      new:setColorRGB(1,1,1)
   end)
end

for key, value in pairs(everything.clothings) do
   if value.equipLayer then
      appendClothing(value.name)
   end
end

local function updateAppendable()
   selection = {}
   for key, value in pairs(everything.clothings) do
      if not value.equipLayer then
         selection[#selection+1] = value.name
      end
   end
   appendButton:setSelectionList(selection)
end

local function getEquiped()
   local zip = {}
   for i = 1, #page.elements-4, 1 do
      zip[#zip+1] = reverse_id[page.elements[i].text]
   end
   updateAppendable()
   return zip
end

local function sync()
   pings.GNWARDROBESYNC(table.unpack(getEquiped()))
end



events.MOUSE_SCROLL:register(function (dir)
   if page.is_active and panel.is_pressed and page.elements[panel.selected_index].text ~= margin then
      local s = panel.selected_index
      local current = page.elements[panel.selected_index]
      local d = -math.sign(dir)
      if type(current) == "panelbutton" and type(page.elements[s + d]) == "panelbutton" then
         panel.selected_index = panel.selected_index + d
         if #page.elements - panel.selected_index < 4 then
            current:setColorRGB(1,0,0)
         else
            current:setColorRGB(1,1,1)
         end
         page.elements[s + d],page.elements[s] = page.elements[s],page.elements[s + d]
         panel:rebuild()
         rebuildClothing(getEquiped())
      end
   end
end)


page:newElement("button"):setText(margin)
appendButton = page:newElement("dropdown"):setText("Insert Clothing"):setSelectionList(selection)
appendButton.ON_PRESS:register(function ()
   updateAppendable()
end)
appendButton.ON_CONFIRM:register(function (something)
   if #appendButton.selection > 0 then
      appendClothing(appendButton.selection[appendButton.selected])
      appendButton.selected = 1
      updateAppendable()
      rebuildClothing(getEquiped())
   end
end)
updateAppendable()
page:newElement("button"):setText("Sync").ON_PRESS:register(function ()
   sync()
end)
page:newElement("returnButton")

rebuildClothing(getEquiped())

return page