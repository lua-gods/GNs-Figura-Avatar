local t2t = {}
local config = {
   mapping = "`1234567890-=~!@#$%^&*()_+qwertyuiop[]QWERTYUIOP{}asdfghjkl;'ASDFGHJKL:\"zxcvbnm,./ZXCVBNM<>?\\|",
   path = "grid.fontmap"
}
local fontmap = textures[config.path]
local characters = {}
local fontmap_size = fontmap:getDimensions()
local width = 0
local charID = 1
local char_font = {}
for scanX = 0, fontmap_size.x-1, 1 do
   width = width + 1
   local column = {}
   local gap = true
   for scanY = 0, fontmap_size.y-1, 1 do
      local p = fontmap:getPixel(scanX,scanY)
      if p.x > 0.5 then
         gap = false
         table.insert(char_font,vec(width,scanY))
      end
   end
   if gap then
      characters[config.mapping:sub(charID,charID)] = {data=char_font,width = width}
      width = 0
      charID = charID + 1
      char_font = {}
   end
   characters[config.mapping:sub(charID,charID)] = {}
end

characters["WHITESPACE"] = {data={},width=3}
characters["LINEBREAK"] = {data={},width=0,linebreak=true}

---@param text string
function t2t:text2pixels(text)
   local compound = {}
   for i = 1, text:len(), 1 do
      local char = text:sub(i,i)
      local c = characters[char]
      if c then
         table.insert(compound,c)
      elseif char == " " then
         table.insert(compound,characters.WHITESPACE)
      elseif char == "\n" then
         table.insert(compound,characters.LINEBREAK)
      end
   end
   return compound
end

return t2t