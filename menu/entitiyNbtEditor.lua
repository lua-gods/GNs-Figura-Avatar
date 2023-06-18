local panel = require("libraries.panel")

local selected
local hovering
local UUID
local nbt

local commits = {}
local nbtPage

local waiting_chat_data = false

local menu = panel:newPage()

local btnSelected = menu:newElement("button"):setText("Entity"):setColorHex("#d3fc7e")
local btnUUID = menu:newElement("button"):setText("UUID"):setColorHex("#92a1b9")

menu:newElement("margin")

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

local function table2page(tbl,path)
    local page = panel:newPage()
    for key, value in pairs(tbl) do
        local button = page:newElement("button"):setText(tostring(value) .. " : " .. key)
        local type = type(value)
        if type == "table" then
            button.ON_RELEASE:register(function ()
                if path then
                    panel:setPage(table2page(value,path .. "." .. key))
                else
                    panel:setPage(table2page(value,key))
                end
            end)
        elseif type == "number" then
            local setPage = panel:newPage()
            setPage:newElement("button"):setText(key)
            setPage:newElement("textEdit"):setValue(value)
            local line = setPage:newElement("button"):setText("Apply")
            line.ON_RELEASE:register(function ()
                panel:returnToLastPage()
                commits[path] = line.text
            end)
            setPage:newElement("returnButton")

            button.ON_RELEASE:register(function ()
                panel:setPage(setPage)
                panel.selected_index = 2
            end)
        end
    end
    page:newElement("margin")
    if path then
        page:newElement("button"):setText(path)
    end
    page:newElement("returnButton")
    return page
end


local function NBT_CHANGED()
    nbtPage = table2page(nbt)
end

-->==========================================[]==========================================<--


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
            if message:sub(1,4) == " has" then
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