--[[

  core
  ~ server

]]

function toboolean(numb)
  if numb == 0 then
    return false
  else
    return true
  end
end

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function vectorToJSON(vector)
  if not vector then return end
  local result = {}
  if vector.x ~= nil then result[1] = vector.x end
  if vector.y ~= nil then result[2] = vector.y end
  if vector.z ~= nil then result[3] = vector.z end
  return toJSON(result)
end

function write_log_line(msg) -- write log line
  local logsFile = File("logs.txt")
  if(not(logsFile)) then logsFile = File.new("logs.txt") end
  if(logsFile) then
    local time = getRealTime()
    logsFile:setPos(logsFile:getSize())
    logsFile:write("["..string.format('%02d-%02d-%04d %02d:%02d', time.monthday, (time.month+1), (time.year+1900), time.hour, time.minute).."] "..msg.."\n")
    logsFile:close()
  end
end

function outputDebug(text) -- output debug message 
  outputDebugString("gm: "..text, 3, 52, 143, 235)
  write_log_line("gm: "..text)
end

function ghost_mode(player,state)
  triggerClientEvent(player,"ghostMode",player,state)
end

function toboolean(int)
  if(int==1) then 
    return true
  elseif(int==0) then
    return false
  else
    return assert("cannot convert number "..int.." to boolean!")
  end
end

function output(p, msg, settings)
  if not msg or not p then return end
  settings = settings or {
    tagText = "*",
    tagColor = color.hex.deepblue,
    msgColor = color.hex.white,
  }
  p:outputChat(string.format("%s(%s) %s%s", settings.tagColor, settings.tagText, settings.msgColor, msg), 0, 0, 0, true)
end

function check_permission(plr, aclgroup)
  if(not(isElement(plr))) then return end
  if(not(plr.type=="player")) then return end 
  local accName = plr:getAccount():getName()
  if(ACLGroup.get(aclgroup):doesContainObject("user."..accName)) then
    return true
  end
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

function update_player_blips(plr) -- player blips TODO in future
  if(not(isElement(plr))) then return end
  if(not(plr.type=="player")) then return end 
  for _, e in ipairs(getElementsByType("player")) do
    if(isLogged(e)) then

    end
  end
end

function save_player(plr) -- saving player to database
  if(not(isElement(plr))) then return end
  if(not(plr.type=="player")) then return end 
  if(isLogged(plr)) then
    local settings = {shaders = plr:getData("shaders")}
    mysqlExec("update accounts set settings=?, respect=?, money=?, health=?, armor=?, deaths=?, kills=?, skin=?, position=?, rotation=? where id=?", toJSON(settings), plr:getData('respect'), plr:getMoney(), plr.health, plr.armor, (plr:getData('deaths') or 0), (plr:getData('kills') or 0), plr:getModel(), toJSON({plr.position.x,plr.position.y,plr.position.z}), toJSON({plr.rotation.x,plr.rotation.y,plr.rotation.z}), plr:getData('accountID')) -- catch errors?
  end
end
addEventHandler('onPlayerQuit', root, function() save_player(source) end)

function load_player(plr, data) -- load player, this function is called after login or wasted
  if(not(isElement(plr))) then return end
  if(not(plr.type=="player")) then return end 
  if(data) then
    if(saveLocation) then
      if not (#data.position>0) then
        local enabledSpawnpoints = getEnabledSpawnPoints()
        local rand = math.random(1,#enabledSpawnpoints)
        local sp = enabledSpawnpoints[rand]
        data.position = sp.position
        data.rotation = sp.rotation
      end
      plr:spawn(Vector3(unpack(data.position)))
      plr:setRotation(Vector3(unpack(data.rotation)))
    else
      local enabledSpawnpoints = getEnabledSpawnPoints()
      local rand = math.random(1,#enabledSpawnpoints)
      local sp = enabledSpawnpoints[rand]
      plr:spawn(Vector3(unpack(sp.position)))
      plr:setRotation(Vector3(unpack(sp.rotation)))
    end
    plr:setHealth(data.health)
    plr:setArmor(data.armor)
    plr:setMoney(data.money)
    plr:setCameraTarget(plr)
    plr:setModel(data.skin)
    plr:setData('respect', data.respect)
    plr:setData('deaths', data.deaths)
    plr:setData('kills', data.kills)
    plr:setData('gender', data.gender)
    -- settings
    for setting, value in ipairs(data.settings) do
      plr:setData(setting, value)
    end
    triggerClientEvent(plr, 'setShadersEnabled', plr, data.shaders)
    triggerClientEvent(plr, "uiDisplay", plr, true)
    local aclGroups = ACLGroup.list()
    for _, v in ipairs(aclGroups) do
      if(check_permission(source, v.name)) then
        plr:setData("aclGroup", v.name)
      end
    end
  else
    plr:kick("Cannot load player!")
  end
end

function load_permissions(plr) -- load permissions, used in nametags and chat
  if(not(isElement(plr))) then return end
  if(not(plr.type=="player")) then return end 
  if(plr) then if(not(isLogged(plr))) then return end end -- to verify !!! it's important !!!
  for _, plr in ipairs(getElementsByType('player')) do
    if(isLogged(plr)) then
      local aclGroups = ACLGroup.list()
      for _, v in ipairs(aclGroups) do
        if(check_permission(plr, v.name)) then
          plr:setData("aclGroup", v.name)
        end
      end
    end
  end
end
addEventHandler('onResourceStart', resourceRoot, load_permissions)
addCommandHandler('loadpermissions', load_permissions)

addEventHandler('onPlayerWasted', root, function(totalAmmo, killer, killerWeapon, bodypart, stealth) -- respawn player
  source:setData('deaths', source:getData('deaths')+1)
  -- respawn
  setTimer(function(plr, model)
    local enabledSpawnpoints = getEnabledSpawnPoints()
    local rand = math.random(1,#enabledSpawnpoints)
    local position = Vector3(unpack(enabledSpawnpoints[rand].position))
    local rotation = Vector3(unpack(enabledSpawnpoints[rand].rotation))
    plr:spawn(position)
    plr:setRotation(rotation)
    plr:setModel(model)
  end, 5000, 1, source, source.model)
  -- killer handling
  if(killer) then
    if(killer.type=="vehicle") then
      killer = killer:getOccupant(0)
      if(not killer) then return end
    end
    if(killer.type=="player") then
      if(source~=killer) then
        killer:setData('kills', killer:getData('kills')+1)
      end
    end
  end
end)

function GM_givePlayerMoney(plr, money)
  plr:giveMoney(money)
  triggerClientEvent(plr, 'GM_givePlayerMoney', plr, money)
  triggerClientEvent(plr, "playSFX", plr, "script", 146, 3, false)
end

function GM_takePlayerMoney(plr, money)
  plr:takeMoney(money)
  triggerClientEvent(plr, 'GM_takePlayerMoney', plr, money)
  triggerClientEvent(plr, "playSFX", plr, "script", 146, 3, false)
end

function GM_takeMoney(plr,money)
  plr:takeMoney(money)
end

addCommandHandler('shaders', function(plr) -- turn on/off shaders
  triggerClientEvent(plr, 'setShadersEnabled', plr, not plr:getData("shaders"))
end)

setFPSLimit(fpsLimit) -- set fps limit

if(realTime) then -- realtime
  setMinuteDuration(60000)
  setTime(getRealTime().hour,getRealTime().minute)
end

addEventHandler('onPlayerJoin', root, function() -- join/quit info
  for _, plr in ipairs(getElementsByType('player')) do
    output(plr, string.format("%s dołączył do gry!", source.name))
  end
end)
addEventHandler('onPlayerQuit', root, function()
  for _, plr in ipairs(getElementsByType('player')) do
    output(plr, string.format("%s opuścił rozgrywkę!", source.name))
  end
end)

setTimer(function() -- update session time
  for i, el in ipairs(getElementsByType("player")) do
    if(el:getData("stime")) then el:setData("stime", el:getData("stime")+1) else el:setData("stime",1) end
  end
end,60000,0)

setTimer(function() -- time money
  for _, plr in ipairs(getElementsByType("player")) do
    GM_givePlayerMoney(plr, timeMoneyAmount)
    output(plr, string.format("otrzymujesz %s za czas spędzony na serwerze.", timeMoneyAmount))
    triggerClientEvent(plr, "playSFX", plr, "script", 95, 2, false)
  end
end, timeMoneySequence, 0)

local msgIndex = 1 
setTimer(function() -- auto message
  for _, plr in ipairs(getElementsByType("player")) do
    output(plr, messages[msgIndex])
    if(messages[msgIndex+1]~=nil) then
      msgIndex = msgIndex+1
    else
      msgIndex = 0
    end
  end
end, autoMsgTime, 0)

--[[
  createList - trigger to client
]]

function createList(p, width, height, title, cols, rows, rowHeight)
  triggerClientEvent(p, "gm_transport_c_createList", p, width, height, title, cols, rows, rowHeight)
end