
local parts = {
   base = models.gn.base,
   head = models.gn.base.Torso.Head,
   body = models.gn.base.Torso,
   left_arm = models.gn.base.Torso.LeftArm,
   right_arm = models.gn.base.Torso.RightArm,
   left_leg = models.gn.base.LeftLeg,
   right_leg = models.gn.base.RightLeg,
}

events.TICK:register(function ()
   parts.left_arm:setVisible(not HOLDING_GUN)
   parts.right_arm:setVisible(not HOLDING_GUN)
end)