--[[

  nametags
  ~ server

]]

function onResourceStart() -- disable old nametags
  local players = getElementsByType("player")
  for _, player in ipairs(players) do
    player:setNametagShowing(false)
  end
end

addEventHandler('onResourceStart', resourceRoot, onResourceStart)
addEventHandler('onPlayerJoin', root, function()
  source:setNametagShowing(false)
end)