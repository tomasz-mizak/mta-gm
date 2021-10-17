--[[

  spawnpoints
  ~ server

]]

spawnPoints = {} -- used to store spawnpoints fetched from database

function loadSpawnPoints() -- refreshing existing spawnpoints
  spawnPoints = {}
  local r = mysqlQuery("select spawn_points.*, accounts1.id as create_account_id, accounts1.username as create_account_username, accounts2.id as update_account_id, accounts2.username as update_account_username from spawn_points inner join accounts as accounts1 on accounts1.id = spawn_points.create_account_id inner join accounts as accounts2 on accounts2.id = spawn_points.update_account_id;")
  assert(r, "spawnpoints - error when loading spawn points")
  for i, v in ipairs(r) do
    local position = fromJSON(v["position"])
    local rotation = fromJSON(v["rotation"])
    table.insert(spawnPoints, {
      id = v["id"],
      state = toboolean(v["enabled"]),
      position = {position[1], position[2], position[3]},
      rotation = {rotation[1], rotation[2], rotation[3]},
      createTimestamp = v["create_timestamp"],
      createAccountID = v["create_account_id"],
      createAccountUsername = v["create_account_username"],
      updateTimestamp = v["update_timestamp"],
      updateAccountID = v["update_account_id"],
      updateAccountUsername = v["update_account_username"]
    })
  end
  return true
end

function addSpawnPoint(position, rotation, creatorID) -- inserting new spawn point to database
  creatorID = creatorID or 0
  local r = mysqlExec("insert into spawn_points (position,rotation,enabled,create_account_id,update_account_id) values (?,?,?,?,?)", toJSON(position), toJSON(rotation), true, creatorID, creatorID)
  assert(r, "spawnpoints - error when try to insert spawnpoint to table spawn_points")
  loadSpawnPoints()
  return true
end
  
function updateSpawnPoint(id) -- update data in db using array spawnPoints
  assert(id and tonumber(id), "id should be a integer")
  for i, v in ipairs(spawnPoints) do
    if tonumber(v.id) == tonumber(id) then
      local r = mysqlExec("update spawn_points set position = ?, rotation = ?, enabled = ?, update_account_id = ?, update_timestamp = current_timestamp where id = ?", toJSON(v.position), toJSON(v.rotation), v.state, v.updateAccountID, id)
      assert(r, string.format("spawnpoints - error when try to update spawn point ID[%d]!", id))
      loadSpawnPoints()
      return true
    end
  end
end

function deleteSpawnPoint(id)
  assert(id and tonumber(id), "id should be a integer")
  for i, v in ipairs(spawnPoints) do
    if tonumber(v.id) == tonumber(id) then
      local r = mysqlExec("delete from spawn_points where id = ?", id)
      assert(r, string.format("spawnpoints - error when try to delete spawn point ID[%d]!", id))
      loadSpawnPoints()
      return true
    end
  end
end

function getEnabledSpawnPoints()
  local array = {}
  for i, v in ipairs(spawnPoints) do
    if v.state then
      table.insert(array, v)
    end
  end
  return array
end

addEventHandler("onResourceStart", resourceRoot, function() -- load spawnpoints on resource start
  loadSpawnPoints()
end)

function cmd_spawnPoints(p, cmd, a1, a2)
  -- TODO: verify permissions / maybe ACL?
  if a1 == "create" then
    if p.inVehicle then
      return output(p, "Wyjdź z pojazdu, jeżeli chcesz utworzyć spawnpoint.")
    end
    if addSpawnPoint({getElementPosition(p)}, {getElementRotation(p)}, p:getData("accountID")) then
      return output(p, "Pomyślnie utworzono spawnpoint.")
    else
      return output(p, "Wystąpił błąd podczas tworzenia spawnpoint'u.")
    end
  elseif a1 == "delete" then
    if a2 and tonumber(a2) then
      for i, v in ipairs(spawnPoints) do
        if v.id == tonumber(a2) then
          if deleteSpawnPoint(a2) then
            return output(p, string.format("Usunięto spawnpoint o ID %d", a2))
          end
          return output(p, string.format("Wystąpił błąd podczas usuwania spawnpointu o ID %d", a2))
        end
      end
    else
      return output(p, string.format("By usunąć spawnpoint, podaj jego ID jako drugi argument (/%s %s [id]).", cmd, a1))
    end
  elseif a1 == "modify" then
    if a2 and tonumber(a2) then
      for i, v in ipairs(spawnPoints) do
        if v.id == tonumber(a2) then
          spawnPoints[i].position = {getElementPosition(p)}
          spawnPoints[i].rotation = {getElementRotation(p)}
          updateSpawnPoint(a2)
          return output(p, string.format("Zmodyfikowano pozycję spawnpointu o id %d", a2))
        end
      end
      return output(p, string.format("Nie znaleziono spawnpointu o ID %d", a2))
    else
      return output(p, string.format("By zmodyfikować spawnpoint, podaj jego ID jako drugi argument (/%s %s [id]).", cmd, a1))
    end
  elseif a1 == "tp" then
    if a2 and tonumber(a2) then
      for i, v in ipairs(spawnPoints) do
        if v.id == tonumber(a2) then
          p:setPosition(unpack(v.position))
          p:setRotation(unpack(v.rotation))
          return output(p, string.format("Przeniesiono do spawnpointu o id %d", a2))
        end
      end
      return output(p, string.format("Nie znaleziono spawnpointu o ID %d", a2))
    else
      return output(p, "By przenieść się do spawnpointu, podaj jego ID jako drugi argument (/spawnpoints tp [id]).")
    end
  elseif a1 == "list" then
    if #spawnPoints == 0 then return output(p, "Brak spawnpointów, zrób jakieś!") end 
    local cols = {
      {
        title = "ID",
        width = 0.1
      },
      {
        title = "Pozycja",
        width = 0.4
      },
      {
        title = "Strefa",
        width = 0.3
      },
      {
        title = "Stan",
        width = 0.2
      }
    }
    local rows = {}
    for i, v in ipairs(spawnPoints) do
      local state = "aktywny"
      if not v.state then
        state = "wyłączony"
      end
      table.insert(rows, {
        v.id,
        string.format("%d, %d, %d", v.position[1], v.position[2], v.position[3]),
        getZoneName(unpack(v.position)),
        state
      })
    end
    createList(p, 500, 400, "lista spawnpointów", cols, rows, 20)
  elseif a1 == "state" then
    if a2 and tonumber(a2) then
      for i, v in ipairs(spawnPoints) do
        if v.id == tonumber(a2) then
          spawnPoints[i].state = not spawnPoints[i].state
          spawnPoints[i].updateAccountID = p:getData("accountID")
          updateSpawnPoint(a2)
          local s = "włączony"
          if not spawnPoints[i].state then s = "wyłączony" end
          return output(p, string.format("Spawnpoint o id %d został %s.", a2, s))
        end
      end
      return output(p, string.format("Nie znaleziono spawnpointu o ID %d", a2))
    else
      return output(p, string.format("By włączyc/wyłączyć spawnpoint, podaj jego ID jako drugi argument (/%s %s [id]).", cmd, a1))
    end
  elseif a1 == "help" then
    local help = {
      string.format("#ff4545Dostępne jest kilka wywołań kluczowych dla komendy %s:", cmd),
      string.format("/%s help - treść którą widzisz", cmd),
      string.format("/%s create - tworzy spawnpoint", cmd),
      string.format("/%s delete - usuwa spawnpoint", cmd),
      string.format("/%s modify - zmienia pozycje spawnpointu na obecną", cmd),
      string.format("/%s state - włącza/wyłącza spawnpoint", cmd),
      string.format("/%s list - wyświetla listę spawnpointów", cmd),
      "#ff4545* komendy możesz wywołać poprzez /sp, /spawnpoint, /spawnpoints"
    }
    for i, v in ipairs(help) do
      output(p, v)
    end
  else
    return output(p, string.format("Jeżeli nie wiesz jak użyć komendy %s (spawnpoints), wpisz /%s help.", cmd, cmd))
  end
end

addCommandHandler("spawnpoints", cmd_spawnPoints)
addCommandHandler("spawnpoint", cmd_spawnPoints)
addCommandHandler("sp", cmd_spawnPoints)

Timer(function()
  triggerClientEvent(root, "gm_sync_c_spawnpoints", root, spawnPoints)
end, 5000, 0)