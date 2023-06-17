local panel = require("libraries.panel")

local selected
local hovering
local UUID
local nbt

local nbtPage

local waiting_chat_data = false

local menu = panel:newPage()
menu:newElement("button"):setText("Commit Changes")
menu:newElement("button"):setText("View Changes")
menu:newElement("margin")
local btnGetData = menu:newElement("button"):setText("Pull NBT")
btnGetData.ON_PRESS:register(function ()
    if selected then
        host:sendChatCommand("/data get entity "..UUID)
        waiting_chat_data = true
    end
end)
menu:newElement("button"):setText("NBT Viewer").ON_PRESS:register(function ()
    if nbtPage then
        panel:setPage(nbtPage)
    end
end)
-->==========================================[]==========================================<--

local function table2page(tbl)
    local page = panel:newPage()
    for key, value in pairs(tbl) do
        local button = page:newElement("button"):setText(tostring(value) .. " : " .. key)
        local type = type(value)
        if type == "table" then
            button.ON_RELEASE:register(function ()
                panel:setPage(table2page(value))
            end)
        end
    end
    page:newElement("returnButton")
    return page
end


local function NBT_CHANGED()
    nbtPage = table2page(nbt)
end

-->==========================================[]==========================================<--

menu:newElement("margin")

local btnSelected = menu:newElement("button"):setText("Entity")
local btnUUID = menu:newElement("button"):setText("UUID")
local btnSelector = menu:newElement("button"):setText("waiting...")
btnSelector.ON_PRESS:register(function ()
    selected = hovering
    if selected then
        btnSelected:setText(selected:getType())
        UUID = selected:getUUID()
        btnUUID:setText(UUID)
    end
end)


events.TICK:register(function ()
    hovering = player:getTargetedEntity()
    if hovering then
        btnSelector:setText("select "..hovering:getType())
    else
        btnSelector:setText("hovering at nothing")
    end
end)
menu:newElement("returnButton")

events.CHAT_RECEIVE_MESSAGE:register(function (message)
    if waiting_chat_data then
        for i = 1, #message, 1 do
            message = message:sub(2,#message) -- trim until first word is yeeted
            if message:sub(1,1) == " " then
                message = message:sub(2,#message)-- trim off trailing space
                --print(message)
                waiting_chat_data = false
                if message:sub(1,#"has the following entity data: ") == "has the following entity data: " then
                    local nbtstr = message:sub(#"has the following entity data:  ",#message)
                    nbtstr = nbtstr:gsub("f,",",")
                    nbtstr = nbtstr:gsub("d,",",")
                    nbtstr = nbtstr:gsub("b,",",")
                    nbtstr = nbtstr:gsub("s,",",")
                    nbtstr = nbtstr:gsub("%]","}")
                    nbtstr = nbtstr:gsub("%[","{")
                    nbtstr = nbtstr:gsub(":","=")

                    nbtstr = nbtstr:gsub("f}","}")
                    nbtstr = nbtstr:gsub("d}","}")
                    nbtstr = nbtstr:gsub("b}","}")
                    nbtstr = nbtstr:gsub("s}","}")
                    
                    local ret,err = load("return "..nbtstr)
                    if not err then
                        nbt = ret()
                        NBT_CHANGED()
                    end
                end
                break
            end
        end
    end
end)
return menu