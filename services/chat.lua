--[[______   __                _                 __
  / ____/ | / /___ _____ ___  (_)___ ___  ____ _/ /____  _____
 / / __/  |/ / __ `/ __ `__ \/ / __ `__ \/ __ `/ __/ _ \/ ___/
/ /_/ / /|  / /_/ / / / / / / / / / / / / /_/ / /_/  __(__  )
\____/_/ |_/\__,_/_/ /_/ /_/_/_/ /_/ /_/\__,_/\__/\___/____]] 
if not host:isHost() then return end

local ping_when = {
   avatar:getEntityName(),
}

local sound_control = {
   master_volume = 1,
   ping_volume   = 1,
   chat_volume   = 1,

   chat_sounds = {
      { -- talk
         when = {
            "chat.type.text",
            "chat.type.emote",
            "chat.type.announcement"
         },
         play = {{id="minecraft:entity.item.pickup",pitch=0.6,volume=0.08}}
      },
      {
         when = {
            "chat.type.admin",
            "commands.",   
         },
         play = {
            {id="minecraft:block.note_block.banjo",pitch=1.5,volume=0.2},--{id="minecraft:entity.elder_guardian.hurt",pitch=0.9,volume=1},--{id="minecraft:entity.blaze.hurt",pitch=0.5,volume=1},
            {id="minecraft:entity.item.pickup",pitch=0.6,volume=0.5}
         },
      },
      {
         when = {
            "multiplayer.player.left",
         },
         play = {{id="minecraft:block.barrel.close",pitch=0.9,volume=1},}
      },
      {
         when = {
            "multiplayer.player.joined",
            "multiplayer.player.joined.renamed",
         },
         play = {{id="minecraft:block.barrel.open",pitch=0.9,volume=1},}
      },
      ping = {
         play = {{id="minecraft:block.note_block.pling",pitch=1.2,volume=1}}
      },
      death = {
         play = {{id="minecraft:block.bell.use",pitch=0.5,volume=1}}
      }
   }
}

local config = {
   duplichecker_max_itteration = 3,
   history_cache_size = 10,
}
local theme = {
   repeat_prefix = '{"text":""}', -- empty
   repeat_suffix = '{"text":" [x%s]","color":"dark_gray"}'
}
-- >====================[ Libraries ]====================<--
local jsonWizard = require("libraries.json")

-- >====================[  ]====================<--
local repeat_count = {}
local history = {}

---- Example usage:
local rawJsonText = '{"text":"Hello, world!", "color":"yellow"}'
local resultTable = jsonWizard.decode(rawJsonText)

-- >====================[ Boss Fight ]====================<--

---@param sound_data {id: string,pitch: number?, volume:number?}
---@param volume_mul number
local function sound(sound_data,volume_mul)
   if sound_data[1] then
      for key, value in pairs(sound_data) do
         sound(value,volume_mul)
      end
      return
   end
   local pitch,volume = 1,1
   if sound_data.pitch then pitch = sound_data.pitch end
   if sound_data.volume then volume = sound_data.volume end
   sounds:playSound(sound_data.id,client:getCameraPos():add(0,1,0),volume * volume_mul,pitch)
end

events.CHAT_RECEIVE_MESSAGE:register(function(message, json)
   local final = json
   -->====================[ Duplichecker ]====================<--
   local is_duplicate = false
   for i = 1, config.duplichecker_max_itteration, 1 do
      if history[i] and message == history[i].message then
         host:setChatMessage(i, nil)
         if repeat_count[message] then
            repeat_count[message] = repeat_count[message] + 1
         else
            repeat_count[message] = 2
         end
         is_duplicate = true
         table.remove(history, i)
         final = string.format('[' .. theme.repeat_prefix .. ',%s,' .. theme.repeat_suffix .. ']',json, repeat_count[message])
      end
   end

   -- >==========[ History Cache Capper ]==========<--
   for i = 1, 10, 1 do
      if #history > config.history_cache_size then
         table.remove(history, config.history_cache_size)
         for key, _ in pairs(repeat_count) do
            if key == history[config.history_cache_size].message then
               repeat_count[key] = nil
            end
         end
      else break
      end
   end

   -->====================[ Shift + Click to Copy ]====================<--
   local decoded_json = jsonWizard.decode(final)
   local is_single = false
   local components
   if decoded_json.with and decoded_json.translate then
      components = decoded_json.with
      if not components[1] then
         is_single = true
      end
   else
      components = decoded_json
      if not components[1] then
         is_single = true
      end
   end

   if is_single then
      if not components.clickEvent and not components.insertion then
         components.insertion = message
      end
   else
      for key, component in pairs(components) do
         if not component.text then -- simple text to advanced converter
            component = {text=component}
         end
         if not component.clickEvent and not component.insertion then -- make message clickable
            component.insertion = message
         end
      end
   end
   final = jsonWizard.encode(decoded_json)
   
   table.insert(history, 1, {message = message, json = json})
   -->====================[ Ping ]====================<--
   local did_ping = false
   local can_ping = (decoded_json.translate and decoded_json.translate == "chat.type.text" and decoded_json.with[1].text ~= avatar:getEntityName() and not is_duplicate) -- cancel ping when message is from self
   if decoded_json.translate and (string.find(decoded_json.translate,"death.attack.") or string.find(decoded_json.translate,"death.fell.")) then
      sound(sound_control.chat_sounds.death.play,sound_control.ping_volume)
   elseif can_ping then
      for key, value in pairs(ping_when) do
         if final:find(value) then
            sound(sound_control.chat_sounds.ping.play,sound_control.ping_volume)
            did_ping = true
         end
      end
   end
   if decoded_json.translate and not did_ping then
      for i, custom in pairs(sound_control.chat_sounds) do
         if type(i) == "number" and custom.when then
         for key, check in pairs(custom.when) do
               if string.find(decoded_json.translate,check) then
                  sound(custom.play,sound_control.chat_volume)
                  return final
               end
            end
         end
      end
   end
   return final
end)
