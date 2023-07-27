local config = {
   model_base = models.handgun.model,
   model_head = models.handgun.model.hed,
   model_neck = models.handgun.model.hed.nec,
   model_camera = models.handgun.model.camera,

   model_arrow = models.handgun.model.Arrow,

   model_arms = {models.handgun.model.hed.nec.LA,models.handgun.model.hed.nec.L,models.handgun.model.hed.nec.RA,models.handgun.model.hed.nec.R},
   model_flash = {models.handgun.model.hed.nec.flash},

   animation_idle = animations["handgun.model"].idle,
   animation_aim = animations["handgun.model"].aim,
   animation_intro = animations["handgun.model"].intro,
   animation_shoot = animations["handgun.model"].shoot,
   animation_reload = animations["handgun.model"].reload,

   projectile_power = 6,
   projectile_precision = 200,
   ammo_max = 32,
}
return config