--[[

  vehicles/public
  ~ server

  # to continue this script, i need make gui window what display list of elements, because i have to display more than chat can display

]]

function getPublicVehicles()
  local r = mysqlQuery("SELECT public_vehicles.*, a1.username as create_account_username FROM public_vehicles INNER JOIN accounts as a1 ON a1.id = public_vehicles.create_account_id")
  assert(r, "error when executing sql script when checking public vehicles")
  return r
end

function getAllowedPublicVehicles()
  local r = mysqlQuery("SELECT * FROM allowed_public_vehicles")
  assert(r, "error when executing sql script when checking allow public vehicles")
  return r
end

function isPublicVehicleAllowed(model)
  assert(model, "model is required")
  assert(isVehicleModelExist(model), "model not exist")
  local r = mysqlQuery("SELECT * FROM allowed_public_vehicles WHERE model = ?", model)
  assert(r, "error when executing sql script when checking allow public vehicle")
  if #r > 0 then
    return true
  end
  return false
end

function addAllowedPublicVehicle(model, creatorID)
  assert(model, "model is required")
  assert(isVehicleModelExist(model), "model not exist")
  assert(creatorID, "creatorID is required")
  assert(tonumber(creatorID), "creatorID must be a number")
  if isPublicVehicleAllowed(model) then
    return false
  end
  local r = mysqlExec("INSERT INTO allowed_public_vehicles (model, create_account_id) VALUES (?,?)", model, creatorID)
  assert(r, "error when executing sql script when adding allow public vehicle")
  if r then
    return true
  end
  return false
end

function removeAllowedPublicVehicle(model)
  assert(model, "model is required")
  assert(isVehicleModelExist(model), "model not exist")
  local r = mysqlExec("DELETE FROM allowed_public_vehicles WHERE model = ?", model)
  assert(r, "error when executing sql script when removing allow public vehicle")
end

function loadPublicVehicles(method)
  method = "normal" or method
  assert(method == "normal" or method == "safe", "method can only be 'normal' or 'safe'")
  if method == "normal" then
    for i, v in ipairs(getElementsByType("vehicles")) do -- destroy existing public vehicles
      if getElementData("vehicle:type") == "public" then
        destroyElement(v)
      end
    end
    local r = mysqlQuery("SELECT * FROM public_vehicles")
    for i, row in ipairs(r) do
      local x, y, z = decodePosition(row["position"])
      local rx, ry, rz = decodePosition(row["rotation"])
      local publicVehicle = createVehicle(tonumber(row["model"]), x, y, z, rx, ry, rz)
      setElementData(publicVehicle, "vehicle:type", "public")
      setElementData(publicVehicle, "vehicle:id", tonumber(row["id"]))
    end
  elseif method == "safe" then -- without deloading of existing/spawned public vehicles
    local spawnedVehiclesIds = {}
    for i, v in ipairs(getElementsByType("vehicles")) do
      if getElementData("vehicle:type") == "public" then
        table.insert(spawnedVehiclesIds, getElementData("vehicle:id"))
      end
    end
    local r = mysqlQuery("SELECT * FROM public_vehicles")
    for i, row in ipairs(r) do
      for _, v in ipairs(spawnedVehiclesIds) do
        if tonumber(row["id"]) ~= tonumber(v) then
          local x, y, z = decodePosition(row["position"])
          local rx, ry, rz = decodePosition(row["rotation"])
          local publicVehicle = createVehicle(tonumber(row["model"]), x, y, z, rx, ry, rz)
          setElementData(publicVehicle, "vehicle:type", "public")
          setElementData(publicVehicle, "vehicle:id", tonumber(row["id"]))
        end
      end
    end
  end
end

function deletePublicVehicle(vehicleID)
  assert(vehicleID, "vehicle id is required")
  assert(type(vehicleID) == "number", "vehicle id must be a integer")
  local r = mysqlQuery("SELECT id FROM public_vehicles WHERE id = ?", vehicleID)
  assert(r, string.format("problem when checking is vehicle with id %d exist", vehicleID))
  if #r > 0 then
    r = mysqlExec("DELETE FROM public_vehicles WHERE id = ?", vehicleID)
    assert(r, string.format("problem when executing delete on vehicleID %d", vehicleID))
    return true
  end
  return false
end

function createPublicVehicle(model, x, y, z, rx, ry, rz, creatorID)
  assert(model, "model id is required")
  assert(x and y and z, "x, y, z is required")
  assert(checkVarTypes("number", x, y, z), "x, y, z must be a number")
  assert(rx and ry and rz, "rx, ry, rz is required")
  assert(checkVarTypes("number", rx, ry, rz), "rx, ry, rz must be a number")
  assert(creatorID, "creatorID is required")
  assert(type(creatorID) == "number", "creatorID must be a number")
  if isVehicleModelExist(model) then
    if tonumber(model) then
      model = tonumber(model)
    else
      model = getVehicleModelFromName(model)
    end
    print(model)
    if not isPublicVehicleAllowed(model) then
      return false
    end
    local r = mysqlExec("INSERT INTO public_vehicles (model, position, rotation, create_account_id, update_account_id, enabled) VALUES (?,?,?,?,?,?)", model, encodePosition(x, y, z), encodePosition(rx, ry, rz), creatorID, creatorID, true)
    assert(r, "error when try to execute sql script in createPublicVehicle")
    -- TODO: load public vehicle safe(not deloading) / brute
    return true
  end
  return false
end

function cmd_createPublicVehicle(p, cmd, arg1, arg2, arg3, arg4)
  if arg1 == "public" then
    if arg2 == "create" then
      if arg3 then
        if isVehicleModelExist(arg3) then
          if tonumber(arg3) then
            arg3 = tonumber(arg3)
          else
            arg3 = getVehicleModelFromName(arg3)
          end
          if not isPublicVehicleAllowed(arg3) then
            return output(p, string.format("Pojazd nie znajduje się on na liście dozwolonych pojazdów. Lista dostępna pod komendą /%s public allow list", cmd))
          end
          local x, y, z = getElementPosition(p)
          local rx, ry, rz = getElementRotation(p)
          local creatorID = getElementData(p, "accountID")
          if createPublicVehicle(arg3, x, y, z, rx, ry, rz, creatorID) then
            return output(p, "Stworzono na tym miejscu pojazd publiczny.")
          else
            return output(p, "Błąd podczas tworzenia publicznego pojazdu.")
          end
        else
          return output(p, "taki model nie istnieje")
        end
      else
        return output(p, "podaj model nazwa/id")
      end
    elseif arg2 == "remove" then
  
    elseif arg2 == "state" then

    elseif arg2 == "tp" then
      for i, v in ipairs(getElementsByType("public")) do
        if getElementData(v, "vehicles:public") then

        end
      end
    elseif arg2 == "list" then
      local cols = {
        {
          title = "ID",
          width = 0.2
        },
        {
          title = "Model",
          width = 0.2
        },
        {
          title = "Twórca",
          width = 0.3
        },
      }
      local rows = {}
      local d = getPublicVehicles()
      for i, v in ipairs(d) do
        table.insert(rows, {
          v["id"],
          getVehicleNameFromModel(v["model"]),
          v["create_account_username"]
          
        })
      end
      createList(p, 400, 300, "vehicles - pojazdy publiczne", cols, rows, 20)
    elseif arg2 == "allow" then
      if arg3 == "add" then
        if arg4 then
          if isVehicleModelExist(arg4) then
            if tonumber(arg4) then
              arg4 = tonumber(arg4)
            else
              arg4 = getVehicleModelFromName(arg4)
            end
            local creatorID = getElementData(p, "accountID")
            addAllowedPublicVehicle(arg4, creatorID)
          end
        else
          return output(p, string.format("Podaj jaki model chcesz wpisać do listy dozwolonych /%s %s %s [model id]", cmd, arg1, arg2, arg3))
        end
      elseif arg3 == "remove" then
        if arg4 then
          if isVehicleModelExist(arg4) then
            if tonumber(arg4) then
              arg4 = tonumber(arg4)
            else
              arg4 = getVehicleModelFromName(arg4)
            end
            local creatorID = getElementData(p, "accountID")
            addAllowedPublicVehicle(arg4, creatorID)
          end
        else
          return output(p, string.format("Podaj jaki model chcesz usunąć z listy dozwolonych /%s %s %s [model id]", cmd, arg1, arg2, arg3))
        end
      elseif arg3 == "list" then
        local cols = {
          {
            title = "Model",
            width = 0.3
          },
          {
            title = "Nazwa pojazdu",
            width = 0.7
          }
        }
        local rows = {}
        local d = getAllowedPublicVehicles()
        for i, v in ipairs(d) do
          table.insert(rows, {
            v["model"],
            getVehicleNameFromModel(v["model"])
          })
        end
        createList(p, 400, 300, "dozwolone pojazdy publiczne", cols, rows, 20)
      else

      end
    else
      return output(p, string.format("By dowiedzieć się jak użyć komendy %s, wpisz /%s help", cmd, cmd))
    end
  elseif arg1 == "help" then
    local cols = {
      {
        title = "Komenda",
        width = 0.3
      },
      {
        title = "Opis",
        width = 0.7
      }
    }
    local rows = {
      {
        string.format("/%s public add [model id]", cmd),
        "Dodaje publiczny pojazd o wskazanym modelu"
      },
      {
        string.format("/%s public remove [id]", cmd),
        "Usuwa publiczny pojazd o wskazanym id"
      },
      {
        string.format("/%s public state [id]", cmd),
        "Wyłącza lub włącza spawnowanie pojazdu"
      },
      {
        string.format("/%s public list", cmd),
        "Wyświetla listę publicznych pojazdów"
      },
      {
        string.format("/%s allow add [model id]", cmd),
        "Dodaje do listy akceptowanych pojazdów"
      },
      {
        string.format("/%s allow remove", cmd),
        "Usuwa z listy akceptowanych pojazdów"
      },
      {
        string.format("/%s allow list", cmd),
        "Wyświetla listęp akceptowanych pojazdów"
      },
    }
    createList(p, 700, 300, "vehicles - komendy", cols, rows, 20)
  else
    return output(p, string.format("By dowiedzieć się jak użyć komendy %s, wpisz /%s help", cmd, cmd))
  end
end

addCommandHandler("vehicle", cmd_createPublicVehicle)
addCommandHandler("v", cmd_createPublicVehicle)

addEventHandler("onResourceStart", resourceRoot, function() -- first load of public vehicles
  loadPublicVehicles()
end)

function spawnVehicles()
  for i, data in ipairs(vehiclesToSpawn) do
    local veh = Vehicle(data[1], data[2], data[3], data[4], 0, 0, data[5], "666")
    veh:setData('publicVehicle', true)
  end
end

function respawnVehicles()
  for _, el in ipairs(getElementsByType("player")) do
    output(el, "Pojazdy zostaną zrestartowane za 10 sekund.")
    triggerClientEvent(el, "playSFX", el, "script", 217, 0, false)
    setTimer(function(el)
      setTimer(function(el) triggerClientEvent(el, "playSFX", el, "script", 95, 0, false) end, 1000, 3, el)
      setTimer(function(el)
        triggerClientEvent(el, "playSFX", el, "script", 95, 1, false)
        output(el, "Pojazdy zostały zrestartowane")
        for _, veh in ipairs(getElementsByType("vehicle")) do
          if(veh:getData('publicVehicle')) then
            local cnt = 0
            local condition = true
            for seat, plr in pairs(veh:getOccupants()) do cnt = cnt + 1 end
            if(cnt>0) then
              condition = false
            end
            if(condition) then
              veh:respawn()
            end
          else
            local cnt = 0
            local condition = true
            for seat, plr in pairs(veh:getOccupants()) do cnt = cnt + 1 end
            if(cnt>0) then
              condition = false
            end
            if(condition) then
              veh:destroy()
            end
          end
        end
      end, 4000, 1, el)
    end, 7000, 1, el)
  end
end

addEventHandler("onResourceStart", resourceRoot, function() -- on resource start, first time spawn vehicles and set timer to respawn.
  spawnVehicles()
  setTimer(respawnVehicles, respawnVehicleTime, 0)
end)

function cmd_respawnVehicles(p, arg1)
  if isLogged(p) then
    if arg1 == "vehicles" then
      respawnVehicles()
    end
  end
end

addCommandHandler("respawn", cmd_respawnVehicles)
