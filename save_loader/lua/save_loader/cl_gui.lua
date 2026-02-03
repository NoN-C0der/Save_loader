SaveLoader = SaveLoader or {}

local function logDebug(message)
  if not SaveLoader.Config or not SaveLoader.Config.Debug then
    return
  end

  MsgC(Color(90, 200, 255), "[Save Loader] ", color_white, tostring(message) .. "\n")
end

local function requestList()
  logDebug("Requesting save list from server.")
  net.Start("SaveLoader.RequestList")
  net.SendToServer()
end

local function buildMenu(saveList)
  local frame = vgui.Create("DFrame")
  frame:SetTitle(SaveLoader.Config.MenuTitle)
  frame:SetSize(480, 420)
  frame:Center()
  frame:MakePopup()

  local info = vgui.Create("DLabel", frame)
  info:SetText("Select a save to load on the server.")
  info:Dock(TOP)
  info:DockMargin(10, 8, 10, 4)
  info:SetTall(18)

  local list = vgui.Create("DListView", frame)
  list:Dock(FILL)
  list:DockMargin(10, 4, 10, 10)
  list:AddColumn("Save File")

  for _, filename in ipairs(saveList or {}) do
    list:AddLine(filename)
  end

  local button = vgui.Create("DButton", frame)
  button:Dock(BOTTOM)
  button:DockMargin(10, 0, 10, 10)
  button:SetText("Load Selected Save")
  button:SetTall(36)

  button.DoClick = function()
    local line = list:GetSelectedLine()
    if not line then
      return
    end

    local selected = list:GetLine(line):GetValue(1)
    if not selected then
      return
    end

    logDebug("Requesting load for " .. selected)
    net.Start("SaveLoader.LoadSave")
    net.WriteString(selected)
    net.SendToServer()
  end
end

net.Receive("SaveLoader.OpenMenu", function()
  logDebug("Menu open received.")
  requestList()
end)

net.Receive("SaveLoader.SendList", function()
  local saves = net.ReadTable() or {}
  logDebug("Received save list with " .. tostring(#saves) .. " entries.")
  buildMenu(saves)
end)
