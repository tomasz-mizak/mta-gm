--[[

  fuelstations
  ~ server

]]

function loadFuelDispenser(id) -- default load dispenser function
  if not id or not tonumber(id) then return end
  local result = mysqlQuery("select * from fuel_dispensers where id=?", id)
  for _, row in ipairs(result) do
    row["position"] = Vector3(fromJSON(row["position"]))
    local m = Marker(row["position"], "cylinder", 3, 0, 0, 200, 100)
    m:setData("id", tonumber(row["id"]))
    m:setData("fuelDispenser", true)
    m:setData("currentValue", tonumber(row["current_value"]))
    m:setData("maxValue", tonumber(row["max_value"]))
  end
end

function loadThrowedFuelDispenser(tt) -- using to load dispenser after use create command in game
  if not tt then return end
  local r = mysqlQuery("select id from fuel_dispensers where throw_timestamp=?", tt)
  local id = tonumber(r[1].id)
  loadFuelDispenser(id)
end

function loadFuelDispensers() -- using on server start, to load all dispensers existing in table fuel_dispensers / it's only hardcoded function
  local result = mysqlQuery("select * from fuel_dispensers where enabled = 1")
  for _, row in ipairs(result) do
    row["position"] = Vector3(fromJSON(row["position"]))
    local m = Marker(row["position"], "cylinder", 3, 0, 0, 200, 100)
    m:setData("id", tonumber(row["id"]))
    m:setData("fuelDispenser", true)
    m:setData("currentValue", tonumber(row["current_value"]))
    m:setData("maxValue", tonumber(row["max_value"]))
  end
end

function createFuelDispenser(data) -- create fuel dispenser function, currently used in commandline
  if not data or type(data) ~= "table" then return end
  if data.pos == nil then
    assert("fuelstations - position required!")
    return
  end
  if data.currentValue == nil then
    assert("fuelstations - currentValue required!")
    return
  end
  if data.maxValue == nil then
    assert("fuelstations - maxValue required!")
    return
  end
  if type(data.position) ~= "userdata" then
    assert("fuelstations - position must be a userdata:Vector3")
    return
  end
  if not tonumber(data.currentValue) then
    assert("fuelstations - currentValue should be a integer")
    return
  end
  if not tonumber(data.maxValue) then
    assert("fuelstations - maxValue should be a integer")
    return
  end
  local tt = getRealTime().timestamp
  local q = mysqlExec("insert into fuel_dispensers (throw_timestamp, position, current_value, max_value, enabled) values (?,?,?,?,?)", tt, vectorToJSON(s.pos), s.currentValue, s.maxValue, true)
  if q then
    output(p, string.format("Stworzono nowy instrybutor o pojemności %s/%s. Został on zapisany do bazy, powinien zostać załadowany po stworzeniu.", s.currentValue, s.maxValue))
    loadThrowedFuelDispenser(tt)  
    return
  else
    assert("fuelstations - insert data to fuel_dispensers table error")
  end
end

function createFuelDispenserCMD(p, cmd, currentValue, maxValue) -- function for commandline
  -- TODO: add verification
  if p.inVehicle then
    output(p, "By stworzyć instrybutor paliwa musisz wyjść z pojazdu, w celu poprawnego pobrania wysokości.")
    return
  end
  if not currentValue or not tonumber(currentValue) then
    output(string.format("Musisz podać ilość paliwa w dystrybutorze (/cfd [%scurrentValue%s] [maxValue]).", "#ff0000", "#ffffff"))
    return
  end
  if not currentValue or not tonumber(currentValue) then
    output("Musisz podać maksymalną ilość paliwa w dystrybutorze (/cfd [currentValue] [%smaxValue%s]).", "#ffffff", "#ff0000")
    return
  end
  local position = p:getPosition() -- store position, it's needed to correct z axis
  position.z = position.z - 0.96
  createFuelDispenser(p,{
    position=position,
    currentValue=currentValue,
    maxValue=maxValue
  })
end

-- Event handling
addEventHandler("onResourceStart", resourceRoot, loadFuelDispensers)

addEventHandler("onMarkerHit", root, function(e, md) -- show dialog when hit dispenser marker
  if e.type == "player" and e.inVehicle and md then
    local neededFuel = tonumber(e.vehicle:getData("max_fuel"))-tonumber(e.vehicle:getData("fuel"))
    print(source:getData("isActive") == nil)
    if tonumber(source:getData("currentValue")) >= neededFuel and (source:getData("isActive") == false or not isElement(source:getData("isActive"))) then
      source:setData("isActive", e)
      triggerClientEvent(e, "displayFuelDialog", e, true, fuelCostPeerLiter)
    end
  end
end)

addEventHandler("onMarkerLeave", root, function(e, md)
  if e.type == "player" and e.inVehicle and md then
    if source:getData("isActive") == e then
      source:setData("isActive", false)
    end
    triggerClientEvent(e, "displayFuelDialog", e, false)
  end
end)


addCommandHandler("create-fuel-dispenser", createFuelDispenserCMD)
addCommandHandler("cfd", createFuelDispenserCMD)

addEvent('buyFuel', true)
addEventHandler('buyFuel', root, function(fuel)
  fuel = round(fuel,2)
  local neededMoney = fuel * fuelCostPeerLiter
  if neededMoney <= source.money then
    if source.inVehicle and source.vehicle then
      if tonumber(source.vehicle:getData("fuel"))+fuel >= tonumber(source.vehicle:getData("max_fuel")) then
        output(source, "Nie możesz zatankować pojazdu, masz pełny bak!")
        triggerClientEvent(source, "displayFuelDialog", source, false)
        return
      end
      source.vehicle:setData("fuel", tonumber(source.vehicle:getData("fuel"))+fuel)
      for _, marker in ipairs(Element.getAllByType("marker")) do
        if marker:getData("isActive") == source and marker:getData("fuelDispenser") then
          marker:setData("currentValue", tonumber(marker:getData("currentValue"))-fuel)
          GM_takePlayerMoney(source, math.ceil(neededMoney))
          output(source, string.format("Kupiłeś %sl paliwa, kosztowało Cię to $%s.",fuel,math.ceil(neededMoney)))
          triggerClientEvent(source, "displayFuelDialog", source, false)
          return
        end
      end
    else
      output(source, "Powinieneś znajdować się w pojeździe!")
    end
  else
    output(source, string.format("Brakuje Ci $%s by kupić %sl paliwa.",(source.money-neededMoney*-1),fuel))
  end
end)

function saveFuelDispensers()
  for i, v in ipairs(Element.getAllByType("marker")) do
    if v:getData("fuelDispenser") then
      mysqlExec("update fuel_dispensers set current_value = ?, last_update = current_timestamp where id = ?", v:getData("currentValue"), v:getData("id"))
    end
  end
end
Timer(saveFuelDispensers, saveFuelDispensersTime, 0)