--[=[------•·······•·······♥·······•·······•------[=[--
  /)_/) ┌─────┐┌─┐ ┌─┐┌───┐  ┌───┐      ┌─┐ ┌─┐       ♥
 { . .} │ ┌───┘│ └─┼─┘│ ┌─┼─┐│ ┌─┼─┐  ┌─┼─┼─┼─┼─┐     ♥
 /    > │ └─┐  │ ┌─┘  │ └─┘ ││ │ │ │  └─┼─┼─┼─┼─┘(\_(\
 ♥      │ ┌─┘  │ │    │ ┌─┐ ││ │ │ │    └─┼─┼─┘  {. . }
 ♥      └─┘    └─┘    └─┘ └─┘└─┘ └─┘      └─┘    <    \
--]=]------•·······•·······♥·······•·······•------]=]--

-- petpet v2.1

---------------# CONFIG #---------------

-- petting properties
local delay = 3    -- minimum wait between pets, in ticks
local scale = 0.75 -- starting scale of pets, increases with time
local particle = "heart" -- particle used while petting

-- toggles if the player must have an empty offhand to be able to pet
local requiresEmptyOffhand = true

-- how much times, in ticks, an entity should be considered as being petted
-- after they stop receiving pets
-- this is used to be able to pet multiple entities without toggling their state each time
local pettingTreshold = 20

-- whitelist of allowed blocks to pet
-- if the whitelist is empty, any block can be petted
-- if the whitelist is nil, cannot pet blocks
-- otherwise, pet only the blocks in the list
local blockWhitelist = {
  ["minecraft:player_head"] = true,
  ["minecraft:player_wall_head"] = true
}

-- the bounding box for petting blocks
local blockBB = vec(0.7, 0.7, 0.7)

---------------# EVENTS #---------------

-- event that runs once you get/stop being petted
-- "beingPetted" is a boolean indicating the current state
local function onBeingPetted(beingPetted)

end

-- event that runs every tick, only if youre being petted by someone
-- "petters" is a list of uuids currently petting you
local function whileBeingPetted(petters)

end

-- event that runs once someone pets you, by swinging their arm
-- "entity" is the entity currently petting you
local function onceSomeonePetsMe(entity)

end

-------------# PETPET CODE #-------------

-- internal variables
local blockPosFix = vec(0.5, 0, 0.5)
local petting = {}
local petters = {}
local beingPetted = false
local lastPet = -1

-- on pet event
avatar:store("petpet", function(uuid, timer)
  -- new petter
  petters[uuid] = tonumber(timer)

  -- now petting
  if (not beingPetted) then
    beingPetted = true
    onBeingPetted(beingPetted)
  end
end)

-- pet keybind
local petCheck
local key = keybinds:of("Petpet", "key.mouse.2")
  :onPress(function()
    -- only allow for pets when sneaking with empty hands
    if (player:isSneaking() and player:getItem(1).id == "minecraft:air" and (not requiresEmptyOffhand or player:getItem(2).id == "minecraft:air") and petCheck()) then
      lastPet = world.getTime() + delay - 1
      return true
    end
  end)
  :onRelease(function()
    -- disallow pets
    lastPet = -1
    scale = 0.75
  end)

-- on pet :3
local function pet(pos, box)
  -- pos
  local box2 = box / 2

  box:applyFunc(function(val) return val * math.random() end)
  pos = pos + box.xyz - box2.x_z

  -- ping
  host:swingArm()
  pings["fran.petpet.pet"]((pos * 1000):floor(), math.floor(scale * 1000))
  scale = scale * 1.01
end

-- pet blocks
local function petBlock()
  -- get block
  local block = player:getTargetedBlock(true, host:getReachDistance())

  if (blockWhitelist ~= nil and (blockWhitelist[block.id] or next(blockWhitelist) == nil)) then
    -- pet
    pet(block:getPos() + blockPosFix, blockBB:copy())
    return true
  else
    -- no pets :(
    return false
  end
end

-- pet entity
local function petEntity(entity)
  if (entity:hasContainer() or entity:hasInventory()) then
    -- cant pet this entity
    return false
  end

  -- pet
  pet(entity:getPos(), entity:getBoundingBox())

  -- set entity as petted
  local uuid = entity:getUUID()
  if (petting[uuid] == nil) then
    pings["fran.petpet.entity"](uuid, pettingTreshold * 1.5)
    petting[uuid] = pettingTreshold
  end

  return true
end

-- pet target detection
function petCheck()
  -- get crosshair entity
  local entity = player:getTargetedEntity(host:getReachDistance())
  if (entity ~= nil) then
    -- try pet entity
    return petEntity(entity)
  else
    -- try pet block
    return petBlock()
  end
end

-- tick event
function events.tick()
  -- button holding = infinite pets ^^
  if (host:isHost() and lastPet > -1 and (lastPet - world.getTime()) % delay == 0) then
    petCheck()
  end

  -- iterate over my pets
  for key, value in pairs(petting) do
    value = value - 1
    petting[key] = value > -1 and value or nil
  end

  -- im being petted >///<
  if (beingPetted) then
    -- being petted event
    whileBeingPetted(petters)

    -- iterate over my petters
    beingPetted = false
    for key, value in pairs(petters) do
      value = value - 1
      if (value > -1) then
        -- still petting, update
        beingPetted = true
        petters[key] = value

        -- pet event
        local entity = world.getEntity(key)
        if (entity ~= nil and entity.getSwingTime ~= nil and entity:getSwingTime() == 1) then
          onceSomeonePetsMe(entity)
        end
      else
        -- no more pets, remove
        petters[key] = nil
      end
    end

    -- call toggle pet event
    if (not beingPetted) then
      onBeingPetted(false)
    end
  end
end

-- pet ping
pings["fran.petpet.pet"] = function(pos, scale)
  -- spawn the pet particle
  particles[particle]:pos(pos / 1000):scale(scale / 1000):spawn()
end

-- entity petpet ping
pings["fran.petpet.entity"] = function(target, timer)
  local e = world.getEntity(target)
  if (e ~= nil) then
    -- grab function
    local fun = e:getVariable("petpet")
    if (type(fun) == "function") then
      -- call it in protected mode
      pcall(fun, avatar:getUUID(), timer)
    end
  end
end