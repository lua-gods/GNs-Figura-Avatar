config:name("just-GN-config")
local panel = require("libraries.panel")
BENCHMARK_MODE = false
BENCHMARK_MODE = config:load("benchmark-mode")
if type(BENCHMARK_MODE) == "nil" then config:save("benchmark-mode",false) end
require("services.globals")

local color_order = {
   "#f5555d",
   "#99e65f",
   "#00cdf9",
   "#ed7614",
   "#ffeb57",
   "#f389f5",
   "#bf6f4a",
   "#c7cfdd",
   "#ff0040",
   "#c64524",
}

local events_data = {
{name="CHAT_RECEIVE_MESSAGE",include=false},
{name="CHAT_SEND_MESSAGE",include=false},
{name="ENTITY_INIT",include=false},
{name="KEY_PRESS",include=false},
{name="MOUSE_MOVE",include=false},
{name="MOUSE_PRESS",include=false},
{name="MOUSE_SCROLL",include=false},
{name="POST_RENDER",include=false},
{name="POST_WORLD_RENDER",include=false,proxy=avatar.getWorldRenderCount},
{name="RENDER",include=true,proxy=avatar.getRenderCount},
{name="SKULL_RENDER",include=false},
{name="TICK",include=true,proxy=avatar.getTickCount},
{name="USE_ITEM",include=false},
{name="WORLD_RENDER",include=true,proxy=avatar.getRenderCount},
{name="WORLD_TICK",include=true,proxy=avatar.getWorldTickCount},
}

local included_events_data = {}

local registered = {}
local new_events = {}
local total_benchmarking_func_count = 0
local total_events_benchmarking = 0

for _, evnt in pairs(events_data) do
   local name = evnt.name
   if not evnt.include then
      new_events[name] = events:getEvents()[name]
   else
      table.insert(included_events_data,evnt)
      registered[name] = {}
      if evnt.include then
         total_benchmarking_func_count = total_benchmarking_func_count + 1
      end
      new_events[name] = {
         register = function (self,func,unique_name)
            local predicted_name = tostring(func)
            --predicted_name:sub(11,#predicted_name)
            local trimmed = ""
            local phase = 0
            local line_to = 0
            local line_from = 0
            local func_name = ""
            for i = #predicted_name, 1, -1 do
               local char = predicted_name:sub(i,i)
               if phase == 0 then -- get line to
                  if char == "-" then 
                     line_to = tonumber(trimmed)
                     phase = 1 trimmed = ""
                     i = i - 1
                  end
                  trimmed = char .. trimmed
               elseif phase == 1 then
                  if char == ":" then -- get line from
                     line_from = tonumber(trimmed:sub(1,#trimmed-1)) 
                     phase = 2 trimmed = ""
                  end
                  if char ~= "-" then trimmed = char .. trimmed end
               elseif phase == 2 then
                  if unique_name then
                     break
                  end
                  if char == ":" then -- get file name
                     func_name = trimmed:sub(2,#trimmed-1)
                     phase = 3 trimmed = ""
                  end
                  if char ~= "-" then
                     trimmed = char .. trimmed
                  end
               end
            end
            predicted_name = trimmed
            if unique_name then
               table.insert(registered[name],{func=func,name=unique_name,line_count=line_to-line_from,benchmark=0})
            else
               table.insert(registered[name],{func=func,name=func_name,line_count=line_to-line_from,benchmark=0})
            end
         end
      }
   end
end



true_events = events
events = new_events
local counters = {}

local labelLib = require("libraries.GNLabelLib")
local selected = 1

local info_lines = {}

for event_id, evnt in pairs(included_events_data) do
   local id = 0
   local event_name = evnt.name
   id = id + 1
   if registered[event_name] then
      counters[event_name] = 1
      total_events_benchmarking = total_events_benchmarking + 1
      local label
      if H then
         label = labelLib:newLabel():setAnchor(-1,1):setOffset(5,(total_events_benchmarking + 2) * -10):setText(event_name)
      end
      
      true_events[event_name]:register(function (...)
         if #registered[event_name] ~= 0 then
            
            
            local c = counters[event_name]
            local current = registered[event_name][c]
            current.benchmark = evnt.proxy(avatar)
            if c == 1 and H then
               local compose
               if selected == event_id then
                  compose = '[{"text":"'.. event_name .. ' : ","color":"red"},'
               else
                  compose = '[{"text":"'.. event_name .. ' : ","color":"white"},'
               end
               local i = 0
               for _, r in pairs(registered[event_name]) do
                  i = i + 1
                  if info_lines[i] then
                     info_lines[i]:setText('[{"text":"'..r.line_count..' ","color":"'..color_order[1]..'"},{"text":"'..r.name..'","color":"'..color_order[i]..'"},'..'{"text":" '..r.benchmark..'","color":"'..color_order[3]..'"}'..']')
                  end
                  compose = compose .. '{"text":"' .. "i"..("|"):rep(math.ceil(r.benchmark/10)) .. '","color":"'.. color_order[i] ..'"},'
               end
               compose = compose:sub(1,#compose-1) .. "]"
               label:setText(compose)
            end
            
            counters[event_name] = (counters[event_name] % #registered[event_name]) + 1
            current.func(...)
            
         end
      return false
      end)
   end
end

local title = labelLib:newLabel():setAnchor(-1,1):setOffset(5,(total_benchmarking_func_count + 3.5) * -10):setText("Scroll to Select Event"):setScale(1.5,1.5)


true_events.MOUSE_SCROLL:register(function (dir)
   selected = ((selected - 1 + dir) % total_benchmarking_func_count) + 1
   title:setText(included_events_data[selected].name)
   for key, value in pairs(info_lines) do
      value:delete()
   end
   local i = 0
   for _, func in pairs(registered[included_events_data[selected].name]) do
      i = i + 1
      local label = labelLib:newLabel()
      label:setAnchor(-1,1):setOffset(5,(total_benchmarking_func_count + 4.5 + i) * -10)
      :setText('[{"text":"'..func.line_count..' ","color":"'..color_order[1]..'"},{"text":"'..func.name..'","color":"'..color_order[i]..'"},'..'{"text":" '..func.benchmark..'","color":"'..color_order[3]..'"}'..']')
      info_lines[i] = label
   end
end)
