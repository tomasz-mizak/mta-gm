--[[

  textdraws
  ~ client

  note:
    don't use # in textdraw text, when use colorCoded.

]]--

textdraws = {}

textdraws.settings = {} -- storing settings

textdraws.settings["render_distance"] = 20
textdraws.settings["scale"] = 1
textdraws.settings["font"] = "default"
textdraws.settings["default_color"] = {255,255,255,255}
textdraws.settings["shadow_color"] = {0,0,0,255}

function renderTextDraw(data) -- normal textdraw
  if not data then return end -- start variable needed for render
  if not isLogged(localPlayer) then return end -- check is logged in
  local distance = getDistanceBetweenPoints3D(data.position,localPlayer.position) -- get distance beetwen render obj and local player.
  if distance > textdraws.settings["render_distance"] then return end -- return if distance is > than set on "render_distance".
  local drawPosition = Vector2(getScreenFromWorldPosition(data.position)) -- get x,y screen draw position.
  if drawPosition.x == 0 and drawPosition.y == 0 then return end -- remove bug, always left top corner textdraw is visible.
  if not isLineOfSightClear(localPlayer.position,data.position, true, false, true, true) then return end -- check is line of sight clear
  data.textColor = data.textColor or textdraws.settings["default_color"] -- initialize color, needed in dxDrawText parameter; or load default
  data.shadowColor = data.shadowColor or textdraws.settings["shadow_color"] 
  if type(data.text) == "table" then
    local i = 1
    for key, value in pairs(data.text) do
      local x, y
      local s = string.format("[%s]: %s", tostring(key), tostring(value)) -- calc text width
      x = drawPosition.x - dxGetTextWidth(s, textdraws.settings["scale"], textdraws.settings["font"], data.colorCoded) / 2 -- correct center
      y = drawPosition.y + ( 16 * ( i - 1 ) )
      local _s
      if data.colorCoded then 
        _s = deleteColorCoded(s)
      end
      dxDrawText(_s, x+1, y+1, 0, 0, tocolor(unpack(data.shadowColor)), textdraws.settings["scale"], textdraws.settings["font"], "left", "top", false, false, false, false)
      dxDrawText(s, x, y, 0, 0, tocolor(unpack(data.textColor)), textdraws.settings["scale"], textdraws.settings["font"], "left", "top", false, false, false, data.colorCoded)
      i = i + 1
    end
  else
    local x, y
    x = drawPosition.x - dxGetTextWidth(data.text, textdraws.settings["scale"], textdraws.settings["font"], data.colorCoded) / 2
    y = drawPosition.y
    local _s
    if data.colorCoded then 
      _s = deleteColorCoded(data.text)
    end
    dxDrawText(_s, x+1, y+1, 0, 0, tocolor(unpack(data.shadowColor)), textdraws.settings["scale"], textdraws.settings["font"], "left", "top", false, false, false, false)
    dxDrawText(data.text, x, y, 0, 0, tocolor(unpack(data.textColor)), textdraws.settings["scale"], textdraws.settings["font"], "left", "top", false, false, false, data.colorCoded)
  end
end

function renderDebugTextDraw(data) -- texdraw only visible on debug 3 mode
  if not isDebugViewActive() then return end
  renderTextDraw(data)
end