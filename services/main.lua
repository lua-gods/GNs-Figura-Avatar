
vanilla_model.ARMOR:setVisible(false)
vanilla_model.PLAYER:setVisible(false)
vanilla_model.HELMET_ITEM:setVisible(true)
vanilla_model.ELYTRA:setVisible(false)
models.gn:setPrimaryRenderType("CUTOUT_CULL")
avatar:store("color",vectors.hexToRGB("#008d52"))
avatar:store("version","4.3.1")
avatar:store("type","gncosmetutil2")
renderer:setShadowRadius(0)

--local panel = require("libraries.panelLib")
--
--local myPanel = panel:newPanel()
--local myPage = myPanel:newPage()
--myPage:newButton():text("I am a text, HELLO")
--myPage:newButton():text("Hello")
--myPage:newButton():text("Hello")
--myPage:newButton():text("Hello")
--myPage:newButton():text("Hello")
--myPage:newButton():text("Hello")
--myPage:newButton():text("Hello")
--myPage:newButton():text("Hello")
--myPage:newButton():text("Hello")
--myPage:newButton():text("Hello")
--myPage:newButton():text("Hello")
--myPage:newButton():text("Hello")
--myPage:newButton():text("Hello")
--myPage:newButton():text("Hello")
--myPage:newButton():text("Hello")
--myPage:newButton():text("Hello")
--local t = 0
--
--events.RENDER:register(function ()
--   t = t + 0.01
--   myPanel:setAnchor(math.cos(t)*0.5,math.sin(t)*0.2)
--   --myPanel:setAnchor(1,0.5)
--   myPanel:setPos(0,0)
--   myPage:update()
--end)
----local pos = client:getWindowSize()/client:getGuiScale()/2
----pos = pos * -1
----pos.x = pos.x + myPanel.Dimensions.x
----pos.y = pos.y - myPanel.Dimensions.y
----myPanel:setPos(pos.x,pos.y)

--local gnui = require("libraries.GNUILib")
--local myPatch = gnui:newNinepatchTexture()
--myPatch:setAnchor(0,0,1,1)
--myPatch:setRect(0,0,0,0)
--myPatch:setMargin(16,16,16,16)
--local i = 0
--events.RENDER:register(function ()
--   i = i + DELTA*0.5
--   --myPatch:setFrom(math.sin(i+124)*16,math.cos(i+351)*16)
--   --myPatch:setTo(128+math.sin(i)*16,128+math.cos(i)*16)
--   --myPatch:setMargin(16+math.sin(i)*8,16+math.cos(i)*8,16,16)
--   --myPatch:setMargin(16+math.sin(i)*8,16+math.cos(i)*8,16,16)
--end)

---@type VectorAPI|string|MatricesAPI|Action
local dog = ""

--TODO Separate the ninepatch elements into separate metatables for reusing values