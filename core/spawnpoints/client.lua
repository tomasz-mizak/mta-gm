--[[

  spawnpoints
  ~ client

]]

local spawnPoints = {} -- local client table, it's used for sync data from server

addEvent("gm_sync_c_spawnpoints", true) -- event existing for execute on server side
addEventHandler("gm_sync_c_spawnpoints", root, function(data)
  spawnPoints = data
end)

addEventHandler("onClientRender", root, function()
  for i, v in ipairs(spawnPoints) do
    local state = "enabled"
    local stateColor = "#00ff00"
    if not v.state then state = "disabled" stateColor = "#ff0000" end
    local text = string.format("%s%s spawnpoint (id:%d)#ffffff\nposition: %d, %d, %d \nrotation: %d, %d, %d\ncreated by: %s (id:%d) at time %s\nupdated by: %s (id:%d) at time: %s", stateColor, state, v.id, v.position[1], v.position[2], v.position[3], v.rotation[1], v.rotation[2], v.rotation[3], v.createAccountUsername, v.createAccountID, v.createTimestamp, v.updateAccountUsername, v.updateAccountID, v.updateTimestamp)
    renderDebugTextDraw({
      text = text,
      position = Vector3(unpack(v.position)),
      colorCoded = true
    })
  end
end)