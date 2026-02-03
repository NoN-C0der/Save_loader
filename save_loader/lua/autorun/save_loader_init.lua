if SERVER then
  AddCSLuaFile("save_loader/cl_gui.lua")
  AddCSLuaFile("save_loader/sh_config.lua")

  include("save_loader/sh_config.lua")
  include("save_loader/sv_loader.lua")
else
  include("save_loader/sh_config.lua")
  include("save_loader/cl_gui.lua")
end
