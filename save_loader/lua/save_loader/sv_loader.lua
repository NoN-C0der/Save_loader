SaveLoader = SaveLoader or {}

util.AddNetworkString("SaveLoader.OpenMenu")
util.AddNetworkString("SaveLoader.RequestList")
util.AddNetworkString("SaveLoader.SendList")
util.AddNetworkString("SaveLoader.LoadSave")

function SaveLoader.Log(message)
  if not SaveLoader.Config or not SaveLoader.Config.Debug then
    return
  end

  local text = "[Save Loader] " .. tostring(message)
  print(text)
  ServerLog(text .. "\n")
end

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

local function runLoadCommand(saveName)
  local commands = concommand.GetTable and concommand.GetTable() or {}
  if commands.gm_load then
    RunConsoleCommand("gm_load", saveName)
    SaveLoader.Log("Issued gm_load for " .. saveName)
    return
  end

  game.ConsoleCommand("load " .. saveName .. "\n")
  SaveLoader.Log("Issued load for " .. saveName)
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
    SaveLoader.Log("Denied save list request from " .. tostring(ply))
    return
  end

  SaveLoader.Log("Sending save list to " .. tostring(ply))
  net.Start("SaveLoader.SendList")
  net.WriteTable(getSaveFiles())
  net.Send(ply)
end)

net.Receive("SaveLoader.LoadSave", function(_, ply)
  if not SaveLoader.PlayerCanUse(ply) then
    SaveLoader.Log("Denied load request from " .. tostring(ply))
    return
  end

  local requested = net.ReadString()
  local safeName = sanitizeSaveName(requested)
  if not safeName then
    SaveLoader.Log("Rejected invalid save name from " .. tostring(ply))
    return
  end

  local savePath = "saves/" .. safeName
  if not file.Exists(savePath, "GAME") then
    ply:ChatPrint("Save Loader: save not found.")
    SaveLoader.Log("Save not found: " .. safeName)
    return
  end

  local extension = string.GetExtensionFromFilename(safeName)
  if not SaveLoader.Config.AllowedExtensions[extension] then
    ply:ChatPrint("Save Loader: invalid save type.")
    SaveLoader.Log("Invalid save type for " .. safeName)
    return
  end

  local loadName = string.StripExtension(safeName)
  ply:ChatPrint("Save Loader: loading " .. loadName .. "...")
  SaveLoader.Log("Loading save " .. loadName .. " for " .. tostring(ply))
  runLoadCommand(loadName)
end)

concommand.Add("save_loader_open", function(ply)
  if not IsValid(ply) then
    return
  end

  if not SaveLoader.PlayerCanUse(ply) then
    ply:ChatPrint("Save Loader: access denied.")
    SaveLoader.Log("Denied menu open for " .. tostring(ply))
    return
  end

  SaveLoader.Log("Opening menu for " .. tostring(ply))
  net.Start("SaveLoader.OpenMenu")
  net.Send(ply)
end)
