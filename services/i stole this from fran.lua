-- ping
local owner = "GNamimates"
local names = {
  ["gn"] = true,
  ["GNamimates"] = true,
  ["GNanimates"] = true,
}

-- time
local lastTimestamp = ""
local timeMsg = ""

-- spam
local oldMsg = ""
local spamCounter = 1

local function pingSound()
  sounds:playSound("entity.arrow.hit_player", pos)
end

local function checkForPing(msg, json)
  -- ignore logs, pings and owner messages
  if (msg:sub(1, 5) == "[lua]" or msg:sub(1, 6) == "[ping]" or msg:sub(2, #owner + 1) == owner) then
    return
  end

  -- play a sound when the message contains one of the names
  for word in msg:gmatch("%w+") do
    if (names[word:lower()]) then
      pingSound()
      return
    end
  end

  -- check for whispers
  if (json:find('"translate":"commands.message.display.incoming"')) then
    pingSound()
  end
end

local function addTime(msg, json)
  -- get time
  local date = client.getDate()
  local hour = date.hour
  local minute = date.minute

  -- format time
  if (hour > 12) then hour = hour % 12 end
  if (hour < 10) then hour = "0"..hour end
  if (minute < 10) then minute = "0"..minute end

  local time = "["..hour..":"..minute.."]"

  -- if the time is different from last
  if (time ~= lastTimestamp) then
    -- save new time and the message that was appended the time
    lastTimestamp = time
    timeMsg = msg

    -- return modified text
    return string.format('["",{"text":"• ","color":"dark_gray"},{"text":"%s","color":"gray"},"\n",%s]', time, json)
  else
    return json
  end
end

local function antiSpam(msg, json)
  -- if the previous message is the same as the current message
  if (oldMsg == msg) then
    -- clear the previous sent message
    host:setChatMessage(1, nil)
    -- increase spam counter
    spamCounter = spamCounter + 1

    -- if the current message is the same as the time message
    -- clear the saved time, forcing it to be readded, as the message containing it was removed
    if (timeMsg == msg) then
      lastTimestamp = ""
    end

    -- return the modified text
    return string.format('[%s,{"text":" (x%s)","color":"dark_gray","italic":true}]', json, spamCounter)
  else
    -- reset spam counter
    spamCounter = 1
    -- update old message
    oldMsg = msg
    return json
  end
end

function events.chat_receive_message(msg, json)
  -- anti spam
  local j = antiSpam(msg, json)

  -- if the message isnt edited by the anti spam
  -- check for pings
  if (j == json) then
    checkForPing(msg, json)
  end

  -- add timestamp and return the new message
  return addTime(msg, j)
end