local head = models.gn.base.Torso.Head.HClothing
local config = {
   mapping = {
      pupils = {
         head.eyes.Lpupil,
         head.eyes.Rpupil
      },
      eyelashes = {
         head.eyeLashes.Reyelash,
         head.eyeLashes.Leyelash
      }
   },
   auto_stare = {
      fastest_wait = 1*20,
      longest_wait = 5*20,

      stare_fast = 0.5*20,
      stare_long = 1*20,
   },
   preset = {
      pupil = {
         left = {clamp=vec(-1,1,-1,1),offset=vec(0.5,0),multiply=vec(1,0.5)},
         right = {clamp=vec(-1,1,-1,1),offset=vec(-0.5,0),multiply=vec(1,0.5)}
      },
      offset = vec(0,0),
      eyelashes = {
         offset = vec(0,0),
      }
   }
}

local eye = {}
local eye_pos = vec(0,0)

function eye:worldToHead(pos)
   local mat = matrices.mat4()
   local head_rot = player:getRot()
   mat:rotate(head_rot.x,-head_rot.y,0)
   mat:invert()
   local ppos = player:getPos()+vec(0,player:getEyeHeight(),0)
   ppos = ppos - pos
   ppos = (mat * vec(ppos.x,ppos.y,ppos.z,1)).xyz
   ppos = vec(ppos.x,-ppos.y,ppos.z)
   return ppos
end

---@param Lclamp Vector4
---@param Loffset Vector2
---@param Lmultiply Vector2
---@param Rclamp Vector4
---@param Roffset Vector2
---@param Rmultiply Vector2
---@return table
function eye:setPreset(Lclamp,Loffset,Lmultiply,Rclamp,Roffset,Rmultiply,eyelashesOffset,offset)
   config.preset.pupil.left.clamp = Lclamp
   config.preset.pupil.left.offset = Loffset
   config.preset.pupil.left.multiply = Lmultiply
   config.preset.pupil.right.clamp = Rclamp
   config.preset.pupil.right.offset = Roffset
   config.preset.pupil.right.multiply = Rmultiply
   config.preset.offset = offset
   config.preset.eyelashes.offset = eyelashesOffset

   
   models.gn.base.Torso.Head.HClothing.eyeLashes:setPos(config.preset.eyelashes.offset.x,config.preset.eyelashes.offset.y,0)
   models.gn.base.Torso.Head.HClothing.eyes:setPos(config.preset.offset.x,config.preset.offset.y,0)
   return self
end

local blink_time = 0

events.TICK:register(function()
   blink_time = blink_time - 1
   if blink_time < 0 then
      blink_time = math.random(1*20,5*20)
      animations.gn.blink:play()
   end
   eye_pos = vec(
      (player:getRot().y-player:getBodyYaw())/90,
      (player:getRot().x)/-90)
   local lp = vec(math.clamp(
      eye_pos.x*config.preset.pupil.left.multiply.x,
      config.preset.pupil.left.clamp.x,
      config.preset.pupil.left.clamp.y)+
      config.preset.pupil.left.offset.x,
      
      math.clamp(
      eye_pos.y*config.preset.pupil.left.multiply.y,
      config.preset.pupil.left.clamp.z,
      config.preset.pupil.left.clamp.w)+
      config.preset.pupil.left.offset.y
      )
   local rp = vec(math.clamp(
      eye_pos.x*config.preset.pupil.right.multiply.x,
      config.preset.pupil.right.clamp.x,
      config.preset.pupil.right.clamp.y)+
      config.preset.pupil.right.offset.x,
      
      math.clamp(
      eye_pos.y*config.preset.pupil.right.multiply.y,
      config.preset.pupil.right.clamp.z,
      config.preset.pupil.right.clamp.w)+
      config.preset.pupil.right.offset.y
      )
   config.mapping.pupils[1]:setPos(lp.x,lp.y,0)
   config.mapping.pupils[2]:setPos(rp.x,rp.y,0)
end)

local yo = vec(1,2,3,4)
local r = math.min(yo.w)


return eye