--[[

  vehicles/private
  ~ server

]]

function savePrivateVehicle(id)
  if not(id) then return assert("id is important!") end
  for _, v in ipairs(getElementsByType('vehicle')) do
    if(v:getData('vehicleID') and tonumber(v:getData('vehicleID'))==id) then
      local i = {
        position = {getElementPosition(v)}, -- i use non-objective functions, because objective fnc, can't be capsulated to array with {} brackets.
        rotation = {getElementRotation(v)},
        plateText = v:getPlateText(),
        color = {getVehicleColor(v)},
        upgrades = v:getUpgrades(),
        paintjob = v:getPaintjob(),
        health = v:getHealth(),
        interior = v:getInterior(),
        dimension = v:getDimension(),
        frozen = v:isFrozen(),
        handling = v:getHandling(),
        lightsColor = {getVehicleHeadLightColor(v)},
        fuel = tonumber(v:getData('fuel')),
        mileage = tonumber(v:getData('mileage')),
        wheelState = {getVehicleWheelStates(v)},
        engineState = tonumber(v:getData('engine_state')),
        ownerID = tonumber(v:getData('ownerID')) or false
      }
      print(toJSON(i.position))
      
      local sql = 'UPDATE vehicles SET position=?,rotation=?,plate_text=?,color=?,upgrades=?,paintjob=?,health=?,interior=?,dimension=?,frozen=?,handling=?,lights_color=?,fuel=?,mileage=?,wheel_state=?,engine_state=? WHERE id=?'
      mysqlExec(sql,toJSON(i.position),toJSON(i.rotation),i.plateText,toJSON(i.color),toJSON(i.upgrades),i.paintjob,i.health,i.interior,i.dimension,i.frozen,toJSON(i.handling),toJSON(i.lightsColor),i.fuel,i.mileage,toJSON(i.wheelState),i.engineState,id)
      return true
    end
  end
  return false
end

function loadVehicle(id)
  if not(id) then return assert("id is important!") end
  local r = mysqlQuery('SELECT * FROM vehicles WHERE id=?',id)
  if(#r>0) then

    r = r[1]

    local i = {
      model = r.model,
      position = Vector3(unpack(fromJSON(r.position))),
      rotation = Vector3(unpack(fromJSON(r.rotation))),
      plateText = r.plate_text,
      color = fromJSON(r.color),
      upgrades = fromJSON(r.upgrades),
      paintjob = r.paintjob,
      health = r.health,
      interior = r.interior,
      dimension = r.dimension,
      frozen = r.frozen,
      handling = fromJSON(r.handling),
      lightsColor = fromJSON(r.lights_color),
      fuel = r.fuel,
      maxFuel = r.max_fuel,
      mileage = r.mileage,
      wheelState = fromJSON(r.wheel_state),
      engineState = r.engine_state,
      customName = r.custom_name
    }

    local veh = Vehicle(i.model,i.position,i.rotation,i.plateText)
    veh:setColor(unpack(i.color))
    for _, u in ipairs(i.upgrades) do veh:addUpgrade(u) end
    setVehiclePaintjob(veh,i.paintjob)
    veh:setHealth(i.health)
    veh:setInterior(i.interior)
    veh:setDimension(i.dimension)
    veh:setFrozen(toboolean(i.frozen))
    for _, e in ipairs(i.handling) do setVehicleHandling(veh,e[1],e[2]) end
    veh:setHeadLightColor(unpack(i.lightsColor))
    veh:setData('vehicleID',id)
    veh:setData('fuel', i.fuel)
    veh:setData('max_fuel', i.maxFuel)
    veh:setData('mileage', i.mileage)
    veh:setWheelStates(unpack(i.wheelState))
    veh:setData('engine_state', i.engine_state)
    veh:setData('custom_name', i.custom_name)
  else
    return false
  end
end

function createPrivateVehicle(i,save,initSpawn)
  if not(i and i.model~=nil and i.position~=nil and i.rotation~=nil and i.maxFuel~=nil) then return assert("Cannot create object, using: RPG_Vehicle:create(); needs model[], position[], rotation[], maxFuel[]") end
  i.color = i.color or {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
  i.upgrades = i.upgrades or {}
  i.paintjob = i.paintjob or 0
  i.plateText = i.plateText or '#jne'
  i.health = i.health or 1000
  i.locked = i.locked or false
  i.interior = i.interior or 0
  i.dimension = i.dimension or 0
  i.frozen = i.frozen or false
  i.handling = i.handling or {}
  i.lightsColor = i.lightsColor or {255,255,255}
  i.fuel = i.fuel or 0
  i.mileage = i.mileage or 0
  i.wheelState = i.wheelState or {0,0,0,0}
  i.engineState = i.engineState or 0
  i.customName = i.customName or ""
  i.ownerId = i.ownerId or 0
  if(save) then
    local sql = 'INSERT INTO vehicles (throw_timestamp,model,position,rotation,color,upgrades,paintjob,plate_text,health,locked,interior,dimension,frozen,handling,lights_color,max_fuel,fuel,mileage,wheel_state,engine_state,custom_name,owner_id) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)'
    local throwTimestamp = getRealTime().timestamp
    if(mysqlExec(sql,throwTimestamp,i.model,toJSON({i.position.x,i.position.y,i.position.z}),toJSON({i.rotation.x,i.rotation.y,i.rotation.z}),toJSON(i.color),toJSON(i.upgrades),i.paintjob,i.plateText,i.health,i.locked,i.interior,i.dimension,i.frozen,toJSON(i.handling),toJSON(i.lightsColor),i.maxFuel,i.fuel,i.mileage,toJSON(i.wheelState),i.engineState,i.customName,i.ownerId)) then
      local r = mysqlQuery('SELECT id FROM vehicles WHERE throw_timestamp=?',throwTimestamp)
      local id = tonumber(r[1].id)
      if(initSpawn) then loadVehicle(id) end
      return id
    else return false end
  else

  end
end

addCommandHandler('cveh', function(p, cmd, model, owner)
  if model then
    if not tonumber(model) then
      model = getVehicleModelFromName(model)
    end
  end
  model = model or 411
  if owner and not tonumber(owner) then
    output(p, string.format("Pojazd %s nie może zostać stworzony, podano złego właściciela (%s), powinien być numerem ID konta.", model, owner))
    return
  end
  owner = owner or 0
  createPrivateVehicle({
    model=model,
    position=Vector3(p.position)+Vector3(0,2,0),
    rotation=Vector3(p.rotation),
    maxFuel=50,
    fuel=5,
    plateText='Hohn',
    color={255,255,255,0,0,0,0,0,0},
    lightsColor={255,0,0},
    ownerId=owner
  },true,true)
end)

function set_vehicle_engine_state(v,state)
  v:setEngineState(state)
end
addEvent('trigger_setVehicleEngineState',true)
addEventHandler('trigger_setVehicleEngineState',root,set_vehicle_engine_state)