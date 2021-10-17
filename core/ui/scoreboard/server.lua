--[[

  scoreboard
  ~ server

]]

function syncPlayerList() -- function used to update player list on client side
  local players = {}
  for i, e in ipairs(getElementsByType("player")) do
    if(e:getData("logged")) then
      table.insert(players, {
        nickname = e.name,
        respect = e:getData("respect"),
        stime = el:getData("stime") or 0,
        ping = e.ping,
        model = e.model
      })
    else 
      table.insert(players, {
        nickname = e.name,
        respect = 0,
        stime = e:getData("stime") or 0,
        ping = e.ping,
        model=300
      })
    end
  end
  triggerClientEvent(root, "gm_sync_c_playerlist", root, players)
end

addEventHandler("onResourceStart", resourceRoot, function() -- on resource start, execute infinite timer to update server player list on client side
  Timer(syncPlayerList, sendPlayerListTime, 0)
end)