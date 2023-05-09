--╔══════════════════════════════════════════════════════════════════════════╗--
--║                                                                          ║----[[--=======================================================]=]
--║  ██  ██  ██████  ██████   █████    ██    ██████   ████    ████    ████   ║--|   _______   __                _                 __           |
--║  ██ ██     ██      ██    ██       ████     ██    ██  ██  ██          ██  ║--|  / ____/ | / /___ _____ ___  (_)___ ___  ____ _/ /____  _____|
--║  ████      ██      ██    ██       █  █     ██     █████  █████    ████   ║--| / / __/  |/ / __ `/ __ `__ \/ / __ `__ \/ __ `/ __/ _ \/ ___/|
--║  ██ ██     ██      ██    ██      ██████    ██        ██  ██  ██  ██      ║--|/ /_/ / /|  / /_/ / / / / / / / / / / / / /_/ / /_/  __(__  ) |
--║  ██  ██  ██████    ██     █████  ██  ██    ██     ████    ████    ████   ║--|\____/_/ |_/\__,_/_/ /_/ /_/_/_/ /_/ /_/\__,_/\__/\___/____/  |
--║                                                                          ║--[-[===========================================================]]
--╚══════════════════════════════════════════════════════════════════════════╝--
---@type Event
local EventsAPI
pcall(function()
  EventsAPI = require("EventsAPI")
end)

---@alias TimerProcessType
---| "TICK"
---| "WORLD_TICK"
---| "RENDER"
---| "WORLD_RENDER"

local timerContainers = {
  ---@type Timer[]
  TICK = {},
  ---@type Timer[]
  RENDER = {},
  ---@type Timer[]
  WORLD_TICK = {},
  ---@type Timer[]
  WORLD_RENDER = {},
}

---@class Timer
---@field time number
---@field duration number
---@field onFinish function?
---@field onProcess fun(progress:number,delta:number)?
---@field onFinishEvent Event
---@field onProcessEvent Event
---@field paused boolean
---@field removed boolean
---@field loop boolean
local Timer = {}
Timer.__index = Timer

---Creates a new timer instance
---@param type TimerProcessType
---@param duration number
---@param onFinish function|nil?
---@param onProcess fun(progress:number,delta:number)|nil?
---@param loop boolean|nil
---@param start boolean
---@return Timer
function Timer:new(type, duration, loop, start, onFinish, onProcess)
  ---@type Timer
  local timer = {
    time = duration,
    duration = duration,
    paused = not start,
    onFinish = onFinish,
    onProcess = onProcess,
  }
  timer.loop = loop
  if EventsAPI then
    timer.onFinishEvent = EventsAPI:new()
    timer.onProcessEvent = EventsAPI:new()
  end
  setmetatable(timer, self)
  if timerContainers[type] then
    table.insert(timerContainers[type], timer)
  else
    error("invalid type", 2)
  end
  return timer
end

function Timer:remove()
  self.removed = true
end

function Timer:pause()
  self.paused = true
end

function Timer:resume()
  self.paused = false
end

function Timer:stop()
  self.paused = true
  self.time = self.duration
end

function Timer:play()
  self.paused = false
  self.time = self.duration
end

do
  local function updateTimers(timerArray, delta)
    for i = 1, #timerArray do
      ---@type Timer
      local timer = timerArray[i]
      if timer then
        if timer.removed then
          table.remove(timerArray, i)
          i = i - 1
          goto continue
        end
        if timer.time <= 0 then
          timer.time = timer.duration
          timer.paused = not timer.loop
          if timer.onFinish then
            timer.onFinish()
          end
          if EventsAPI then
            timer.onFinishEvent:invoke()
          end
        end
        if not timer.paused then
          timer.time = math.max(timer.time - delta, 0)
          if timer.onProcess then
            timer.onProcess((timer.duration - timer.time) / timer.duration, delta)
          end
          if EventsAPI then
            timer.onProcessEvent:invoke((timer.duration - timer.time) / timer.duration, delta)
          end
        end
      end
      ::continue::
    end
  end

  events.TICK:register(function()
    updateTimers(timerContainers.TICK, 1)
  end)

  events.WORLD_TICK:register(function()
    updateTimers(timerContainers.WORLD_TICK, 1)
  end)

  local lastRenderTime = client:getSystemTime()
  events.RENDER:register(function()
    local delta = (client:getSystemTime() - lastRenderTime) / 1000
    lastRenderTime = client:getSystemTime()
    updateTimers(timerContainers.RENDER, delta)
  end)

  local lastWorldRenderTime = client:getSystemTime()
  events.WORLD_RENDER:register(function()
    local delta = (client:getSystemTime() - lastWorldRenderTime) / 1000
    lastWorldRenderTime = client:getSystemTime()
    updateTimers(timerContainers.WORLD_RENDER, delta)
  end)
end

return Timer
