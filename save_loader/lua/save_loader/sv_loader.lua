SaveLoader = SaveLoader or {}

util.AddNetworkString("SaveLoader.OpenMenu")
util.AddNetworkString("SaveLoader.RequestList")
util.AddNetworkString("SaveLoader.SendList")
util.AddNetworkString("SaveLoader.LoadSave")

local function hasUlxAccess(ply)
  if not IsValid(ply) then
    return false
  end

  if ULib and ULib.ucl then
    return ULib.ucl.query(ply, "save_loader") or ULib.ucl.query(ply, "ulx loadmenu")
  end

  return ply:IsAdmin()
end

function SaveLoader.PlayerCanUse(ply)
  return hasUlxAccess(ply)
end

local function sanitizeSaveName(name)
  if not isstring(name) then
    return nil
  end

  name = string.Trim(name)
  if name == "" then
    return nil
  end

  if string.find(name, "[\\/]") then
    return nil
  end

  return name
end

local function getSaveFiles()
  local saves = {}
  local files, _ = file.Find("saves/*.gms", "GAME")

  for _, filename in ipairs(files or {}) do
    local extension = string.GetExtensionFromFilename(filename)
    if SaveLoader.Config.AllowedExtensions[extension] then
      table.insert(saves, filename)
    end
  end

  table.sort(saves)

  return saves
end

net.Receive("SaveLoader.RequestList", function(_, ply)
  if not SaveLoader.PlayerCanUse(ply) then
    return
  end

  net.Start("SaveLoader.SendList")
  net.WriteTable(getSaveFiles())
  net.Send(ply)
end)

net.Receive("SaveLoader.LoadSave", function(_, ply)
  if not SaveLoader.PlayerCanUse(ply) then
    return
  end

  local requested = net.ReadString()
  local safeName = sanitizeSaveName(requested)
  if not safeName then
    return
  end

  local savePath = "saves/" .. safeName
  if not file.Exists(savePath, "GAME") then
    ply:ChatPrint("Save Loader: save not found.")
    return
  end

  local extension = string.GetExtensionFromFilename(safeName)
  if not SaveLoader.Config.AllowedExtensions[extension] then
    ply:ChatPrint("Save Loader: invalid save type.")
    return
  end

  ply:ChatPrint("Save Loader: loading " .. safeName .. "...")
  game.ConsoleCommand("load " .. safeName .. "\n")
end)

concommand.Add("save_loader_open", function(ply)
  if not IsValid(ply) then
    return
  end

  if not SaveLoader.PlayerCanUse(ply) then
    ply:ChatPrint("Save Loader: access denied.")
    return
  end

  net.Start("SaveLoader.OpenMenu")
  net.Send(ply)
end)
