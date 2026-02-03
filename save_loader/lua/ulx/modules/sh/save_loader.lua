if not ulx then
  return
end

local CATEGORY_NAME = "Save Loader"

function ulx.loadmenu(calling_ply)
  if not IsValid(calling_ply) then
    return
  end

  if not SaveLoader or not SaveLoader.PlayerCanUse then
    calling_ply:ChatPrint("Save Loader: addon not available.")
    return
  end

  if not SaveLoader.PlayerCanUse(calling_ply) then
    ULib.tsayError(calling_ply, "Save Loader: access denied.", true)
    return
  end

  net.Start("SaveLoader.OpenMenu")
  net.Send(calling_ply)
end

local loadmenu = ulx.command(CATEGORY_NAME, "ulx loadmenu", ulx.loadmenu, "!loadmenu")
loadmenu:defaultAccess(ULib.ACCESS_ADMIN)
loadmenu:help("Open the Save Loader menu.")

ULib.ucl.registerAccess("save_loader", ULib.ACCESS_ADMIN, "Allow access to the Save Loader addon.", CATEGORY_NAME)
