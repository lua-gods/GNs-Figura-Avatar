-- To enable: /figura run setDrunk(true)

-- To disable: /fiiguaun seTnuk(alse
-- Whoops I mean: i/gur rseuDnk(fal)
-- Whoops I mean: ... just reload the script :P

if not IS_HOST then return end
local function registerDrunkEvents()
    events.KEY_PRESS:register(function()
        return math.random() > 0.8
    end, "drunk")

    events.CHAT_SEND_MESSAGE:register(function(message)
        local chars = {}
        if not message then return end
        for i = 1, #message do
            chars[i] = message:sub(i,i)
        end
        for i = 1, #chars do
            if math.random() > 0.4 then
                chars[i] = chars[i]:lower()
            end
            if math.random() > 0.4 and chars[i + 1] == nil then
                chars[i] = string.rep(chars[i], math.random(1, 8))
            end
            if math.random() > 0.6 and chars[i] == " " then
                chars[i] = chars[i-1] or ""
            end
            if math.random() > 0.9 then
                chars[i] = chars[i] .. " "
            end
            if math.random() > 0.98 then
                chars[i] = chars[i]:upper()
            end
            if math.random() > 0.94 then
                chars[i] = chars[i] .. chars[i]
            end                          
            if math.random() > 0.94 then
                chars[i] = chars[i] .. string.char(math.random(32, 126))
            end    
            if math.random() > 0.94 then
                chars[i] = ""
            end
        end
        return table.concat(chars)
    end, "drunk")

    events.CHAR_TYPED:register(function(char)
        local chat = host:getChatText()
        if not chat then return end
        if math.random() > 0.98 then
            host:setChatText(chat .. char)
        end
    end, "drunk")

    local mouse_state = 1
    events.MOUSE_MOVE:register(function()
        renderer:setEyeOffset(vec(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5))
        if math.random() > 0.99 then
            mouse_state = math.random(1, 3)
        end
        return (mouse_state == 1 and math.random() > 0.9) or (mouse_state == 2 and math.random() > 0.2) or (mouse_state == 3 and true)
    end, "drunk")

    events.MOUSE_PRESS:register(function(button, state)
        return math.random() > 0.8
    end, "drunk")

    events.MOUSE_SCROLL:register(function(dir)
        if math.random() > 0.5 then
            return true
        end
    end, "drunk")

    events.RENDER:register(function ()
        if world.getTime() % 10 == 0 then
            renderer:setPostEffect(player:getVelocity():length() > 0.2 and "phosphor" or "antialias")
        end
        renderer:offsetCameraRot(-player:getVelocity():dot(player:getLookDir()) * 10,2,0.5)
    end, "drunk")
end

local function removeDrunkEvents()
    events.KEY_PRESS:remove("drunk")
    events.CHAT_SEND_MESSAGE:remove("drunk")
    events.CHAR_TYPED:remove("drunk")
    events.MOUSE_MOVE:remove("drunk")
    events.MOUSE_PRESS:remove("drunk")
    events.MOUSE_SCROLL:remove("drunk")
    renderer:setPostEffect(nil)
    renderer:setFOV(nil)
    renderer:setEyeOffset(nil)
    renderer:offsetCameraRot(nil)
end

function setDrunk(val)
    if val then
        registerDrunkEvents()
    else
        removeDrunkEvents()
    end
end