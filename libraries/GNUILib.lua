--[[______   __                _                 __
  / ____/ | / /___ _____ ___  (_)___ ___  ____ _/ /____  _____
 / / __/  |/ / __ `/ __ `__ \/ / __ `__ \/ __ `/ __/ _ \/ ___/
/ /_/ / /|  / /_/ / / / / / / / / / / / / /_/ / /_/  __(__  )
\____/_/ |_/\__,_/_/ /_/ /_/_/_/ /_/ /_/\__,_/\__/\___/____]]

local cfg = {
   model = models.menu,
   default_texture = textures.default
}
local katt = require("libraries.KattEventsAPI")
local ui = {
   WINDOW_SIZE_CHANGED = katt:newEvent(),
   GUI_SCALE_CHANGED = katt:newEvent(),
}
cfg.model:setParentType("HUD")
----------------------------------------------------------------| Utilities
local util = {}

function util.anchorToPos(x,y,ox,oy)
   local pos = client:getWindowSize()/client:getGuiScale()/2
   pos.y = pos.y * math.map(y,-1,1,0,-2) + oy
   pos.x = pos.x * math.map(x,-1,1,0,-2) + ox
   return pos
end

local function makeProxy(...)
   -- create a list of underlying tables with their own metatables
   local tables = {...}
   local metatables = {}
   for i, t in ipairs(tables) do
      metatables[i] = getmetatable(t) or {}
   end

   -- define the proxy table's metatable
   local proxy_table = {
      __index = function(_, k)
         -- find the first underlying table that has the key
         for i, t in ipairs(tables) do
             if rawget(t, k) ~= nil then
                 return rawget(t, k)
             end
         end
         -- none of the underlying tables has the key, use the first metatable
         return metatables[1].__index and metatables[1].__index(_, k)
      end,
      __newindex = function(_, k, v)
         -- find the first underlying table that has the key
         for i, t in ipairs(tables) do
            if rawget(t, k) ~= nil then
               rawset(t, k, v)
               return
            end
         end
         -- none of the underlying tables has the key, use the first metatable
         if metatables[1].__newindex then
            metatables[1].__newindex(_, k, v)
         else
            rawset(tables[1], k, v)
         end
      end,
      -- use the first metatable for all other operations
      __metatable = metatables[1]
   }
   return proxy_table
end   

---Only Clones the table, not the metatables
---@param tbl any
function util.lightCloneTable(tbl)
   local new = {}
   for key, value in pairs(tbl) do
      new[key] = value
   end
   return new
end

local function deepCopy(original)
   local copy = {}
   for k, v in pairs(original) do
      if type(v) == "table" then
         v = deepCopy(v)
      end
      copy[k] = v
   end
   return copy
end

local resource = {}
--------------------------------------| Rect Property |--------------------------------------

---@class GNUI.Properties.Rect
---@field rect Vector4
---@field RECT_CHANGED KattEvent
local rect = {
   rect = vectors.vec4(),
   RECT_CHANGED = katt:newEvent()
}
local rectMetafunc = {}
rect.__index = rectMetafunc

function resource:appendRectProperties(compose)
   ---@type GNUI.Properties.Rect
   if not compose then
      compose = {}
   end
   compose.rect = vectors.vec4()
   compose.RECT_CHANGED = katt:newEvent()
   
   setmetatable(compose,rectMetafunc)
   return compose
end



---Sets the top left and the bottom right corners of the element.
---@param x number
---@param y number
---@param z number
---@param w number
function rectMetafunc:setRect(x,y,z,w)
   if self.rect.x ~= x or self.rect.y ~= y or self.rect.y ~= y or self.rect.w ~= w then
      self.rect.x = x self.rect.y = y self.rect.z = z self.rect.w = w
      self.RECT_CHANGED:invoke(
         self.rect.x,self.rect.y,
         self.rect.z,self.rect.w)
   end
   return self
end

---Sets the top left corner offset based off of the anchor position.
---@param x number
---@param y number
---@return GNUI.Properties.Rect
function rectMetafunc:setFrom(x,y)
   if self.rect.x ~= x or self.rect.y ~= y then
      self.rect.x = x
      self.rect.y = y
      self.RECT_CHANGED:invoke(
         self.rect.x,self.rect.y,
         self.rect.z,self.rect.w)
   end
   return self
end

---Sets the bottom right corner offset based off of the anchor position.
---@param x number
---@param y number
---@return GNUI.Properties.Rect
function rectMetafunc:setTo(x,y)
   if self.rect.z ~= x or self.rect.w ~= y then
      self.rect.z = x
      self.rect.w = y
      self.RECT_CHANGED:invoke(
         self.rect.x,self.rect.y,
         self.rect.z,self.rect.w)
   end
   return self
end

---Sets the Position of the element.  
---Note: this sets the "To" position as well, making it easy to move elements. 
---@param x number
---@param y number
---@return GNUI.Properties.Rect
function rectMetafunc:setPos(x,y)
   if self.rect.x ~= x or self.rect.y ~= y then
      self.rect.z = x - self.rect.x
      self.rect.w = y - self.rect.y
      self.rect.x = x
      self.rect.y = y
      self.RECT_CHANGED:invoke(
         self.rect.x,self.rect.y,
         self.rect.z,self.rect.w)
   end
   return self
end

--------------------------------| Ninepatch Element |--------------------------------

---@class GNUI.Element.NinepatchTexture
---@field texture Texture
---@field rect Vector4
---@field rect_anchor Vector4
---@field patch_margin Vector4
---@field tasks table`
---@field id integer
---@field depth number
---@field TEXTURE_CHANGED KattEvent
---@field RECT_CHANGED KattEvent
---@field MARGIN_CHANGED KattEvent
---@field ANCHOR_CHANGED KattEvent
local Ninepatch = {}
Ninepatch.__index = Ninepatch
local ninepatchID = 0

function ui:newNinepatchTexture()
   ---@type GNUI.Element.NinepatchTexture
   local compose = {
      texture = nil,
      rect = vectors.vec4(0,0,128,64),
      rect_anchor = vectors.vec4(0,0,0,0),
      patch_margin = vectors.vec4(16,16,32,32),
      tasks = {},
      id = ninepatchID,
      TEXTURE_CHANGED = katt:newEvent(),
      RECT_CHANGED = katt:newEvent(),
      MARGIN_CHANGED = katt:newEvent(),
      ANCHOR_CHANGED = katt:newEvent(),
      depth = 0,
   }
   setmetatable(compose,Ninepatch)
   ninepatchID = ninepatchID + 1
   ui.WINDOW_SIZE_CHANGED:register(function ()compose:refreshTasks()end)
   compose:refreshTasks()
   return compose 
end

--------------------------------| Ninepatch Rendering Handlers |--------------------------------

function Ninepatch:refreshTasks()
   for name, task in pairs(self.tasks) do
      cfg.model:removeTask(name)
   end
   self.tasks = {}
   for i = 1, 9, 1 do
      local taskName = "gnuielementninepatch"..self.id.."partch"..i
      self.tasks[taskName] = cfg.model:newSprite(taskName):texture(cfg.default_texture):setRenderType("BLURRY")
   end
   self:updateTasks()
   return self
end

function Ninepatch:updateTasks()
   local i = 0
   for id, task in pairs(self.tasks) do
      local dim = task:getDimensions()
      local A = util.anchorToPos(self.rect_anchor.x,self.rect_anchor.y,self.rect.x,self.rect.y)
      local B = -util.anchorToPos(self.rect_anchor.z,self.rect_anchor.w,self.rect.z,self.rect.w)
      i = i + 1
         if i == 1 then task -- top left
            :pos(
               A.x,
               A.y,self.depth)
            :scale(
               self.patch_margin.x/dim.x,
               self.patch_margin.y/dim.y,0)
            elseif i == 2 then task -- top middle
            :pos(
               A.x-self.patch_margin.x,
               A.y,self.depth)
            :scale(
               (B.x+A.x-self.patch_margin.x-self.patch_margin.z)/dim.x,
               self.patch_margin.y/dim.y,0)
            elseif i == 3 then task -- top right
            :pos(
               -B.x+self.patch_margin.z,
               A.y,self.depth)
            :scale(
               self.patch_margin.z/dim.x,
               self.patch_margin.y/dim.y,0)
            elseif i == 4 then task -- left
            :pos(
               A.x,
               A.y-self.patch_margin.y,self.depth)
            :scale(
               self.patch_margin.x/dim.x,
               (B.y+A.y-self.patch_margin.y-self.patch_margin.w)/dim.y,0)
            elseif i == 5 then task -- Middle
            :pos(
               A.x-self.patch_margin.x,
               A.y-self.patch_margin.y,self.depth)
            :scale(
               (B.x+A.x-self.patch_margin.x-self.patch_margin.z)/dim.x,
               (B.y+A.y-self.patch_margin.y-self.patch_margin.w)/dim.y,0)
            elseif i == 6 then task -- right
            :pos(
               self.patch_margin.z-B.x,
               A.y-self.patch_margin.y,self.depth)
            :scale(
               self.patch_margin.z/dim.x,
               (B.y+A.y-self.patch_margin.y-self.patch_margin.w)/dim.y,0)
            elseif i == 7 then task -- bottom left
            :pos(
               A.x,
               self.patch_margin.w-B.y,self.depth)
            :scale(
               self.patch_margin.x/dim.x,
               self.patch_margin.w/dim.y,0)
            elseif i == 8 then task -- bottom middle
            :pos(
               A.x-self.patch_margin.x,
               self.patch_margin.w-B.y,self.depth)
            :scale(
               (B.x+A.x-self.patch_margin.x-self.patch_margin.z)/dim.x,
               self.patch_margin.w/dim.y,0)
            elseif i == 9 then task -- bottom right
            :pos(
               self.patch_margin.z-B.x,
               self.patch_margin.w-B.y,self.depth)
            :scale(
               self.patch_margin.z/dim.x,
               self.patch_margin.w/dim.y,0)
         else
            task:pos(9999,999,99)
      end
   end
   return self
end

--------------------------------| Ninepatch API |--------------------------------

---@param newTexture Texture
function Ninepatch:setTexture(newTexture)
   if self.texture ~= newTexture then
      self.texture = newTexture
      self:updateTasks()
      self.TEXTURE_CHANGED:invoke()
   end
   return self
end

function Ninepatch:setDepth(depth)
   if self.depth ~= depth then
      self.depth = depth
      self.RECT_CHANGED:invoke(
         self.rect.x,self.rect.y,
         self.rect.z,self.rect.w)
   end
   return self
end

----------------------| Ninepatch Rect API |----------------------



----------------------| Ninepatch Mergin API |----------------------

---Sets the Margins for all the edges.
---@param up number
---@param down number
---@param left number
---@param right number
---@return GNUI.Element.NinepatchTexture
function Ninepatch:setMargin(left,up,right,down)
   if self.patch_margin.x ~= left or
      self.patch_margin.y ~= up or
      self.patch_margin.z ~= right or
      self.patch_margin.w ~= down then
         self.patch_margin.x = left
         self.patch_margin.y = up
         self.patch_margin.z = right
         self.patch_margin.w = down
         self.MARGIN_CHANGED:invoke(
            self.patch_margin.x,self.patch_margin.y,
            self.patch_margin.z,self.patch_margin.w)
      self:refreshTasks()
   end
   return self
end

---Sets the Margins for the left edge.
---@param left number
---@return GNUI.Element.NinepatchTexture
function Ninepatch:setMarginLeft(left)
   if self.patch_margin.x ~= left then
         self.patch_margin.x = left
         self.MARGIN_CHANGED:invoke(
            self.patch_margin.x,self.patch_margin.y,
            self.patch_margin.z,self.patch_margin.w)
         self:refreshTasks()
      end
   return self
end

---Sets the Margins for the top edge.
---@param up number
---@return GNUI.Element.NinepatchTexture
function Ninepatch:setMarginUp(up)
   if self.patch_margin.y ~= up then
         self.patch_margin.y = up
         self.MARGIN_CHANGED:invoke(
            self.patch_margin.x,self.patch_margin.y,
            self.patch_margin.z,self.patch_margin.w)
         self:refreshTasks()
      end
   return self
end

---Sets the Margins for the right edge.
---@param right number
---@return GNUI.Element.NinepatchTexture
function Ninepatch:setMarginRight(right)
   if self.patch_margin.z ~= right then
         self.patch_margin.z = right
         self.MARGIN_CHANGED:invoke(
            self.patch_margin.x,self.patch_margin.y,
            self.patch_margin.z,self.patch_margin.w)
         self:refreshTasks()
      end
   return self
end

---Sets the Margins for the bottom edge.
---@param down number
---@return GNUI.Element.NinepatchTexture
function Ninepatch:setMarginDown(down)
   if self.patch_margin.z ~= down then
         self.patch_margin.z = down
         self.MARGIN_CHANGED:invoke(
            self.patch_margin.x,self.patch_margin.y,
            self.patch_margin.z,self.patch_margin.w)
         self:refreshTasks()
      end
   return self
end

----------------------| Ninepatch Anchor API |----------------------

---Sets the Margins for all the edges.
---@param Ax number
---@param Ay number
---@param Bx number
---@param By number
---@return GNUI.Element.NinepatchTexture
function Ninepatch:setAnchor(Ax,Ay,Bx,By)
   if self.rect_anchor.x ~= Ax or
      self.rect_anchor.y ~= Ay or
      self.rect_anchor.z ~= Bx or
      self.rect_anchor.w ~= By then
         self.rect_anchor.x = Ax
         self.rect_anchor.y = Ay
         self.rect_anchor.z = Bx
         self.rect_anchor.w = By
         self.MARGIN_CHANGED:invoke(
            self.rect_anchor.x,self.rect_anchor.y,
            self.rect_anchor.z,self.rect_anchor.w)
      self:refreshTasks()
   end
   return self
end

---Sets the Margins for the left edge.
---@param value number
---@return GNUI.Element.NinepatchTexture
function Ninepatch:setAnchorFromX(value)
   if self.rect_anchor.x ~= value then
         self.rect_anchor.x = value
         self.MARGIN_CHANGED:invoke(
            self.rect_anchor.x,self.rect_anchor.y,
            self.rect_anchor.z,self.rect_anchor.w)
         self:refreshTasks()
      end
   return self
end

---Sets the Margins for the top edge.
---@param value number
---@return GNUI.Element.NinepatchTexture
function Ninepatch:setAnchorFromY(value)
   if self.rect_anchor.y ~= value then
         self.rect_anchor.y = value
         self.MARGIN_CHANGED:invoke(
            self.rect_anchor.x,self.rect_anchor.y,
            self.rect_anchor.z,self.rect_anchor.w)
         self:refreshTasks()
      end
   return self
end

---Sets the Margins for the right edge.
---@param value number
---@return GNUI.Element.NinepatchTexture
function Ninepatch:setAnchorToX(value)
   if self.rect_anchor.z ~= value then
         self.rect_anchor.z = value
         self.MARGIN_CHANGED:invoke(
            self.rect_anchor.x,self.rect_anchor.y,
            self.rect_anchor.z,self.rect_anchor.w)
         self:refreshTasks()
      end
   return self
end

---Sets the Margins for the bottom edge.
---@param down number
---@return GNUI.Element.NinepatchTexture
function Ninepatch:setAnchorToY(down)
   if self.rect_anchor.w ~= down then
         self.rect_anchor.w = down
         self.MARGIN_CHANGED:invoke(
            self.rect_anchor.x,self.rect_anchor.y,
            self.rect_anchor.z,self.rect_anchor.w)
         self:refreshTasks()
      end
   return self
end

------------------------------------------------------| Button |------------------------------------------------------

----------------------------------------------------------------| Generic Container Class
---@class GNUI.Container.Generic
---@field rect Vector4 # from offset, to offset
---@field rect_anchor Vector4 # fromt anchor, to anchor
---@field depth integer # z index, parent z offset + depth = final
---@field children table


---@class GNUI.Element.Generic
---@field rect Vector4 # from offset, to offset
---@field rect_anchor Vector4 # fromt anchor, to anchor
---@field depth integer # z index, parent z offset + depth = final


---@class GNUI.Element.Button
---@field rect Vector4 # from offset, to offset 
---@field rect_anchor Vector4 # fromt anchor, to anchor
---@field depth integer # z index, parent z offset + depth = final
---@field text string # label
---@field texture nil|Texture|GNUI.Element.NinepatchTexture

--local astUIScale = vectors.vec2()
local lastWindowSize = vectors.vec2()

events.RENDER:register(function (delta, context)
   --local scale = client:getGuiScale()
   --if astUIScale ~= scale then
   --   local ratio = 1/scale
   --   astUIScale = scale
   --   cfg.model:setScale(ratio,ratio)
   --   ui.GUI_SCALE_CHANGED:invoke(scale)
   --end
   local windowSize = client:getWindowSize()
   if lastWindowSize ~= windowSize then
      ui.WINDOW_SIZE_CHANGED:invoke(windowSize)
      lastWindowSize = windowSize
   end
end)

return ui