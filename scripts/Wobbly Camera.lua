local mac = require("libraries.macroScriptLib"):newScript("gn:wobbly_camera")

local loc_vel = vectors.vec3()

local rest = vectors.vec3()
local lstate = vectors.vec3()
local state = vectors.vec3()
local vel = vectors.vec3()

mac.ENTER:register(function ()

end)

mac.TICK:register(function ()
    lstate = state:copy()
    loc_vel = (player:getVelocity():augmented() * matrices.mat4():rotateY(player:getRot().y)).xyz
    state = state + vel
    vel = vel * 0.8 - (state-rest) * 0.5
    renderer:setCrosshairOffset()
    rest = loc_vel
end)

mac.FRAME:register(function (delta)
    local lv = math.lerp(lstate,state,delta)
   renderer:offsetCameraRot(lv.z*-15,0,lv.x*-15)
   renderer:offsetCameraPivot(0,lv.y*0.5,0)
end)

mac.EXIT:register(function ()
    renderer:offsetCameraRot(0,0,0)
    renderer:offsetCameraPivot(0,0,0)
end)

return mac