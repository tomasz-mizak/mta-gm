--[[

  core
  ~ client

]]


--[[
  globals
]]
screenW, screenH = guiGetScreenSize()
DGS = exports.dgs

--[[
  functions and event handling
]]

function cursor(state) -- cursor showing
  if(state) then
    localPlayer:setData("guisCount", (localPlayer:getData("guisCount") or 0)+1)
    showCursor(true)
  else
    localPlayer:setData("guisCount", (localPlayer:getData("guisCount") or 0)-1)
    if(localPlayer:getData("guisCount")<0) then
      localPlayer:setData("guisCount", 0)
    end
    if(localPlayer:getData("guisCount")==0) then
      showCursor(false)
    end
  end
end
localPlayer:setData('guisCount', 0)
localPlayer:setData('inTuningGarage', false)
localPlayer:setData('isTuningGarageSubWindowShowed', false)
localPlayer:setData('tuningGarageInstalledUpgrade', false)

function set_shaders_enabled(state) -- shaders function triggered from server
  exports.shader_dynamic_sky:setState(state)
  exports.shader_car_paint_fix:setState(state)
  exports.shader_depth_of_field:setState(state)
  exports.shader_fxaa:setState(state)
  localPlayer:setData('shaders',state)
end
addEvent('setShadersEnabled', true)
addEventHandler('setShadersEnabled', root, set_shaders_enabled)

function output(msg, settings) -- output info function, using to stay at the same look of messages
  if not msg then return end
  settings = settings or {
    tagText = "*",
    tagColor = color.hex.deepblue,
    msgColor = color.hex.white,
  }
  outputChatBox(string.format("%s(%s) %s%s", settings.tagColor, settings.tagText, settings.msgColor, msg), 0, 0, 0, true)
end

function getElementSpeed(theElement, unit) -- useful function to get element speed, from mta wiki
  if(not(isPedInVehicle(localPlayer))) then return end
  assert(isElement(theElement), "Bad argument 1 @ getElementSpeed (element expected, got " .. type(theElement) .. ")")
  local elementType = getElementType(theElement)
  assert(elementType == "player" or elementType == "ped" or elementType == "object" or elementType == "vehicle" or elementType == "projectile", "Invalid element type @ getElementSpeed (player/ped/object/vehicle/projectile expected, got " .. elementType .. ")")
  assert((unit == nil or type(unit) == "string" or type(unit) == "number") and (unit == nil or (tonumber(unit) and (tonumber(unit) == 0 or tonumber(unit) == 1 or tonumber(unit) == 2)) or unit == "m/s" or unit == "km/h" or unit == "mph"), "Bad argument 2 @ getElementSpeed (invalid speed unit)")
  unit = unit == nil and 0 or ((not tonumber(unit)) and unit or tonumber(unit))
  local mult = (unit == 0 or unit == "m/s") and 50 or ((unit == 1 or unit == "km/h") and 180 or 111.84681456)
  return (Vector3(getElementVelocity(theElement)) * mult).length
end

function getVehicleRPM(vehicle) -- useful function to get vehicle rpm, from mta wiki
  local vehicleRPM = 0
  if (vehicle) then
      if (getVehicleEngineState(vehicle) == true) then
          if getVehicleCurrentGear(vehicle) > 0 then
              vehicleRPM = math.floor(((getElementSpeed(vehicle, "km/h") / getVehicleCurrentGear(vehicle)) * 160) + 0.5)
              if (vehicleRPM < 650) then
                  vehicleRPM = math.random(650, 750)
              elseif (vehicleRPM >= 9000) then
                  vehicleRPM = math.random(9000, 9900)
              end
          else
              vehicleRPM = math.floor((getElementSpeed(vehicle, "km/h") * 160) + 0.5)
              if (vehicleRPM < 650) then
                  vehicleRPM = math.random(650, 750)
              elseif (vehicleRPM >= 9000) then
                  vehicleRPM = math.random(9000, 9900)
              end
          end
      else
          vehicleRPM = 0
      end
      return tonumber(vehicleRPM)
  else
      return 0
  end
end

addEvent('playSFX', true) -- playSFX for server side
addEventHandler('playSFX', root, function(containerName, bankId, soundId, looped)
  playSFX(containerName, bankId, soundId, looped)
end)

function getRgbRankColor(plr) -- get acl group color in rgb
  if(not(isElement(plr))) then return end
  if(not(plr.type=="player")) then return end 
  if(plr:getData("aclGroup")=="Admin") then
    return color.rgb.red
  elseif(plr:getData("aclGroup")=="SuperModerator") then
    return color.rgb.blue
  elseif(plr:getData("aclGroup")=="Moderator") then
    return color.rgb.green
  elseif(plr:getData("aclGroup")=="Vip") then
    return color.rgb.orange
  end
  return color.rgb.white
end

function getHexRankColor(plr) -- get acl group color in hex
  if(not(isElement(plr))) then return end
  if(not(plr.type=="player")) then return end 
  if(plr:getData("aclGroup")=="Admin") then
    return color.hex.red
  elseif(plr:getData("aclGroup")=="SuperModerator") then
    return color.hex.blue
  elseif(plr:getData("aclGroup")=="Moderator") then
    return color.hex.green
  elseif(plr:getData("aclGroup")=="Vip") then
    return color.hex.orange
  end
  return color.hex.white
end

function ghost_mode(state)
  if(not(source.vehicle)) then return end
  source:setData("isGhostModeActive", state)
  for i, v in ipairs(getElementsByType("vehicle")) do
    v:setCollidableWith(source.vehicle, not state)
  end
end
addEvent("ghostMode", true)
addEventHandler("ghostMode", root, ghost_mode)

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end


--[[
  promptwindow
]]
function createPromptWindow(headerText,bodyText,cancelText,okText,minLen,maxLen,okFnc,cancelFnc,createFnc)
  -- call to create function
    createFnc()
  -- initialize defaults
  headerText = headerText or ""
  bodyText = bodyText or ""
  cancelText = cancelText or "Anuluj"
  okText = okText or "Akceptuj"
  minLen = minLen or 0
  maxLen = maxLen or 65535
  -- build window if functions is availabe
  if(okFnc and cancelFnc) then
    cursor(true)
    local window = DGS:dgsCreateWindow((screenW-360)/2,(screenH-140)/2,360,140,headerText,false,0xFFFFFFFF,25,nil,0xC8141414,nil,0x96141414,5,true)
    DGS:dgsWindowSetSizable(window,false)
    local label = DGS:dgsCreateLabel(0,0,358,42,bodyText,false,window)
    DGS:dgsLabelSetHorizontalAlign(label,"center")
    DGS:dgsLabelSetVerticalAlign(label,"center")
    DGS:dgsSetProperty(label,"wordbreak",true)
    local edit = DGS:dgsCreateEdit(10,50,338,23,"",false,window)
    DGS:dgsEditSetMaxLength(edit,maxLen)
    local cancel = DGS:dgsCreateButton(10,80,162,21,cancelText,false,window)
    local send = DGS:dgsCreateButton(186,80,162,21,okText,false,window)
    addEventHandler('onDgsMouseClick', root, function(button,state)
      if(button=="left" and state=="down") then
        if(source==cancel) then
          destroyElement(window)
          cursor(false)
          cancelFnc()
          guiSetInputEnabled(false)
        elseif(source==send) then
          local str = DGS:dgsGetText(edit)
          if(#str>=minLen) then
            destroyElement(window)
            cursor(false)
            okFnc(str)
            guiSetInputEnabled(false)
          end
        end
      end
    end)
    guiSetInputEnabled(true)
  end
end

--[[
  createAlertWindow
]]
function createAlertWindow(s)
  s.title = s.title or ""
  s.text = s.text or ""
  s.titleColor = s.titleColor or {255,255,255}
  s.textColor = s.textColor or {255,255,255}
  s.disableNo = s.disableNo or false
  if(s.noFunction and s.yesFunction) then
    cursor(true)
    local window = GuiWindow((screenW - 342) / 2, (screenH - 104) / 2, 342, 104, s.title, false)
    window:setSizable(false)
    local label = GuiLabel(10, 25, 322, 43, s.text, false, window)
    label:setColor(unpack(s.textColor))
    label:setHorizontalAlign("center",true)
    label:setVerticalAlign("center")
    local noBtn = guiCreateButton(20, 72, 147, 23, "No", false, window)
    local yesBtn = guiCreateButton(175, 72, 147, 23, "Yes", false, window)
    
    noBtn:setEnabled(not s.disableNo)
    addEventHandler('onClientGUIClick', noBtn, function()
      if(source~=noBtn) then return end
      window:destroy()
      cursor(false)
      s.noFunction()
    end)
    addEventHandler('onClientGUIClick', yesBtn, function()
      if(source~=yesBtn) then return end
      window:destroy()
      cursor(false)
      s.yesFunction()
    end)
  end
end

--[[
  vehicle combustion, mileage and engine control
]]
setTimer(function()
  if(not(localPlayer.inVehicle)) then return end
  if(not(localPlayer.vehicle)) then return end

  if not(localPlayer.vehicle:getEngineState()) then return end

  -- initials
  local speed = math.ceil(getElementSpeed(localPlayer.vehicle, "km/h"))
  local rpm = getVehicleRPM(localPlayer.vehicle)
  local param = localPlayer.vehicle:getHandling()
  local scaleExtent = 2

  -- mileage
  local mileage = localPlayer.vehicle:getData('mileage')
  local momentaryMileage = speed/1000
  localPlayer.vehicle:setData('mileage',mileage+(momentaryMileage/scaleExtent))
  -- print(momentaryMileage)

  -- fuel
  local fuel = localPlayer.vehicle:getData('fuel')
  local maxFuel = localPlayer.vehicle:getData('max_fuel')
  local combustion = round((param.mass*speed)/(rpm*3),2)
  if not(combustion==0) then
    combustion = momentaryMileage/combustion
  end
  if(speed==0) then
    combustion = 0.001
  end
  if localPlayer.vehicle.vehicleType == "Quad" or localPlayer.vehicle.vehicleType == "Bike" then
    combustion = combustion/6
  end
  if(fuel>0) then
    if(fuel-combustion<0) then
      localPlayer.vehicle:setData('fuel',0)
    else
      localPlayer.vehicle:setData('fuel',fuel-combustion)
    end
  else
    triggerServerEvent('trigger_setVehicleEngineState',localPlayer,localPlayer.vehicle,false)
  end

end,1000,0)

vehicleStop = false
addEventHandler('onClientRender', root, function()
  if(localPlayer.inVehicle and localPlayer.vehicle) then 
    local engineState = localPlayer.vehicle:getEngineState()
    local fuel = localPlayer.vehicle:getData('fuel')
    if(fuel==0) then
      if(vehicleStop) then
        setElementVelocity(localPlayer.vehicle,0,0,0)
        toggleControl('vehicle_left',false)
        toggleControl('vehicle_right',false)
        toggleControl('accelerate',false)
        toggleControl('brake_reverse',false)
      else
        local speed = getElementSpeed(localPlayer.vehicle)
        if(speed==0) then vehicleStop = true end
      end
    else
      vehicleStop = false
      toggleControl('vehicle_left',true)
      toggleControl('vehicle_right',true)
      toggleControl('accelerate',true)
      toggleControl('brake_reverse',true)
    end
  end
end)

function onEnter_turnOffEngine(p,seat)
  if(seat~=0) then return end
  --if(source.)
  --TODO: try to quiet engine when player enter to vehicle
end
addEventHandler('onClientVehicleEnter',root,onEnter_turnOffEngine)


--[[
  load head avatars, used in scoreboard and info panel
]]
heads = {}
allSkins = getValidPedModels()
for _, v in ipairs(allSkins) do
  if(v==266 or v==300) then
    heads[v] = DxTexture("img/heads/unknown.png")
  else
    heads[v] = DxTexture("img/heads/Skinid"..v..".jpg")
  end
end

-- toggle off bg weapons and general
setAmbientSoundEnabled( "general", false )
setAmbientSoundEnabled( "gunfire", false )

-- clean vehicles with elementdata 'cleaned'
local myShader = dxCreateShader("texture.fx")
addEventHandler("onClientElementDataChange", root,
function (dataName)
    if (getElementType(source) == "vehicle") and (dataName == "cleaned") then
        engineApplyShaderToWorldTexture(myShader, "vehiclegrunge256", source)
        engineApplyShaderToWorldTexture(myShader, "?emap*", source)
    end
end)
addEventHandler("onClientElementDataChange", root,
function (dataName)
    for _, vehicle in ipairs(getElementsByType("vehicle")) do
        if (getElementData(vehicle, "cleaned")) then
            engineApplyShaderToWorldTexture(myShader, "vehiclegrunge256", vehicle)
            engineApplyShaderToWorldTexture(myShader, "?emap*", vehicle)
        end
    end
end)

function onChatMessage(text) -- disable login, logout chat message
  if(string.sub(text,1,6) == "login:" or string.sub(text,1,7) == "logout:") then
    cancelEvent()
  end
end
addEventHandler("onClientChatMessage",root,onChatMessage)

-- turn off f11 --/ not work, but why i do this stuff??? XD
toggleControl("radar", true)

--[[
  disabling vehicle radio
]]
function disableRadio()
  if(not localPlayer.inVehicle) then
    output("Musisz znajdować się w pojeździe", nil, "RADIO")
    return
  end
  setRadioChannel(0)
  output("Wyłączono", nil, "RADIO")
end
addCommandHandler("toggleofradio", disableRadio)
addCommandHandler("tor", disableRadio)
addCommandHandler("radiooff", disableRadio)
addCommandHandler("ro", disableRadio)

--[[
  get position
]]
addCommandHandler('pos', function()
  local position = localPlayer:getPosition()
  setClipboard(position.x..','..position.y..','..position.z)
  output("Obecna pozycja została skopiowana do schowka.")
end)

--[[
  get rotation
]]
addCommandHandler('rot', function()
  local rotation = localPlayer:getRotation()
  setClipboard(rotation.x..','..rotation.y..','..rotation.z)
  output("Obecna rotacja została skopiowana do schowka.")
end)

--[[
  list
]]

list = {}
list.width = 600
list.height = 300

function createList(width, height, title, cols, rows, rowHeight)
  if width and not tonumber(width) then return end
  if height and not tonumber(height) then return end
  if title and not tostring(title) then return else title = tostring(title) end
  if rowHeight and not tonumber(rowHeight) then return end
  width = width or list.width
  height = height or list.height
  list.window = DGS:dgsCreateWindow((screenW-width)/2,(screenH-height)/2, width, height, title, false, tocolor(255,255,255,255), 25, nil, tocolor(0,0,0,255), nil, tocolor(0,0,0,180), 5, true)
  DGS:dgsWindowSetSizable(list.window, false)
  local gridList = DGS:dgsCreateGridList(0, 0, width, height-50, false, list.window, 20, tocolor(0,0,0,0), tocolor(0,0,0,255), tocolor(255,255,255,200), tocolor(0,0,0,0), tocolor(0,0,0,0), tocolor(200,0,0,120))
  rowHeight = rowHeight or 20
  DGS:dgsSetProperty(gridList, "rowHeight", rowHeight)
  for i, col in ipairs(cols) do
    DGS:dgsGridListAddColumn(gridList, col.title, col.width)
  end
  for i, row in ipairs(rows) do
    local rowElement = DGS:dgsGridListAddRow(gridList)
    for k, inRow in ipairs(row) do
      DGS:dgsGridListSetItemText(gridList, rowElement, k, inRow)
    end
  end
  local closeButton = DGS:dgsCreateButton(0,height-45,width,20,"Zamknij",false,list.window, tocolor(255,255,255,255), 1, 1, nil, nil, nil, tocolor(200,0,0,180), tocolor(200,0,0,255), tocolor(255,0,0,255))
  addEventHandler("onDgsMouseClick", root, function(button,state)
    if button=="left" and state=="down" and source == closeButton then
      destroyElement(list.window)
      cursor(false)
    end
  end)
  cursor(true)
end

addEvent("gm_transport_c_createList", true)
addEventHandler("gm_transport_c_createList", root, createList)

-- local cols = {
--   {
--     title = "Komenda",
--     width = 0.3
--   },
--   {
--     title = "Opis",
--     width = 0.7
--   }
-- }

-- local rows = {
--   {"/v public create", "Zjebany ten świat"},
--   {"/v public create", "Zjebany ten świat"},
--   {"/v public create", "Zjebany ten świat"},
--   {"/v public create", "Zjebany ten świat"},
--   {"/v public create", "Zjebany ten świat"},
--   {"/v public create", "Zjebany ten świat"},
--   {"/v public create", "Zjebany ten świat"},
--   {"/v public create", "Zjebany ten świat"},
--   {"/v public create", "Zjebany ten świat"},
--   {"/v public create", "Zjebany ten świat"},
--   {"/v public create", "Zjebany ten świat"},
--   {"/v public create", "Zjebany ten świat"},
--   {"/v public create", "Zjebany ten świat"},
--   {"/v public create", "Zjebany ten świat"},
--   {"/v public create", "Zjebany ten świat"},
--   {"/v public create", "Zjebany ten świat"},
--   {"/v public create", "Zjebany ten świat"},
-- }

-- createList(300, 300, "vehicles", cols, rows)