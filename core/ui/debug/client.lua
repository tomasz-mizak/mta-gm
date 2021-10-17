--[[

  debug
  ~ client

]]

addEventHandler('onClientRender', root, function()
  if(not(isDebugViewActive())) then return end
  if(ipane.state) then return end
  local debug = {
    data = {
      { text = "dimension", data = localPlayer.dimension },
      { text = "interior", data = localPlayer.interior },
      { text = "guisCount", data = localPlayer:getData("guisCount") },
      { text = "isGhostModeActive", data = localPlayer:getData("isGhostModeActive") },
      { text = "speedo current ax", data = right.current_ax },
      { text = "speedo static ax", data = right.static_ax },
    },
    maxW = 0,
    maxH = 0,
    x = screenW-175,
    y = (screenH-300)/2,
    divider = 20,
    padding = 10
  }
  debug.maxH = 20*#debug.data
  for _, v in ipairs(debug.data) do
    local len = dxGetTextWidth(v.text..": "..tostring(v.data),1,"default")
    if(len>debug.maxW) then debug.maxW = len end
  end
  dxDrawRectangle(debug.x,debug.y,debug.maxW+debug.padding,debug.maxH+debug.padding,tocolor(0,0,0,200))
  for i, v in ipairs(debug.data) do
    dxDrawText(v.text..": "..tostring(v.data),debug.x+debug.padding/2,debug.y+debug.padding/2+((i-1)*debug.divider),0,0,tocolor(255,255,255,200))
  end
end)