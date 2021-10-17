--[[

  scoreboard
  ~ client

]]

local players = {}

local page = 1
local maxpagesize = 8

addEvent('gm_sync_c_playerlist', true)
addEventHandler("gm_sync_c_playerlist", root, function(array)
  players = array
end)

bindKey('tab','down',function()
  if(not(localPlayer:getData("logged"))) then return end
  if(localPlayer:getData("inTuningGarage")) then return end
  playSFX("script", 16, 2, false)
end)

bindKey('tab','up',function()
  if(not(localPlayer:getData("logged"))) then return end
  if(localPlayer:getData("inTuningGarage")) then return end
  playSFX("script", 16, 2, false)
end)

addEventHandler('onClientRender', root, function()
  if(not(localPlayer:getData("logged"))) then return end
  if(localPlayer:getData("inTuningGarage")) then return end
  if(not(getKeyState("tab"))) then displayUI(true) showChat(true) uivisible=true return end
  
  displayUI(false)
  showChat(false)
  uivisible = false
  local avatarW = 32
  local avatarH = 32
  local avatarmargin = 4
  local nickname = 230
  local respect = 150
  local stime = 125
  local ping = 50
  local all = avatarW+nickname+respect+stime+ping
  local startX = (screenW-all)/2
  local startY = 100
  local sh = avatarH
  local bottomrowmargin = 1
  local rows = 0 -- do not change
  startX=startX+avatarW
  dxDrawText("Nickname", startX, startY, startX+nickname, startY+32, tocolor(255,255,255), 1, "default", "left", "bottom")
  startX=startX+nickname
  dxDrawText("Respect", startX, startY, startX+respect, startY+32, tocolor(255,255,255), 1, "default", "left", "bottom")
  startX=startX+respect
  dxDrawText("Session time", startX, startY, startX+stime, startY+32, tocolor(255,255,255), 1, "default", "left", "bottom")
  startX=startX+stime
  dxDrawText("Ping", startX, startY, startX+ping, startY+32, tocolor(255,255,255), 1, "default", "left", "bottom")
  for i=(page*maxpagesize)-(maxpagesize-1),maxpagesize*page do
    local v = players[i]
    if(v==nil) then return end
    startX = (screenW-all)/2
    startY = 132
    local k = i-(maxpagesize*(page-1))
    dxDrawImage(startX, startY+(sh*(k-1))+bottomrowmargin*k,32,32,heads[v.model])
    --dxDrawRectangle(startX, startY+(sh*(k-1))+bottomrowmargin*k, 32, 32, tocolor(255,0,0))
    startX=startX+avatarW
    dxDrawRectangle(startX, startY+(sh*(k-1))+bottomrowmargin*k, all, 32, tocolor(255,255,255,200))
    startX=startX+avatarmargin
    dxDrawText(v.nickname, startX, startY+(sh*(k-1))+bottomrowmargin*k, startX+nickname, startY+32+(sh*(k-1))+bottomrowmargin*k, tocolor(0,0,0), 1, "default", "left", "center")
    startX=startX+nickname
    dxDrawText(v.respect.." points", startX, startY+(sh*(k-1))+bottomrowmargin*k, startX+respect, startY+32+(sh*(k-1))+bottomrowmargin*k, tocolor(0,0,0), 1, "default", "left", "center")
    startX=startX+respect
    dxDrawText(v.stime.." minutes", startX, startY+(sh*(k-1))+bottomrowmargin*k, startX+stime, startY+32+(sh*(k-1))+bottomrowmargin*k, tocolor(0,0,0), 1, "default", "left", "center")
    startX=startX+stime
    dxDrawText(v.ping.." ms", startX, startY+(sh*(k-1))+bottomrowmargin*k, startX+ping, startY+32+(sh*(k-1))+bottomrowmargin*k, tocolor(0,0,0), 1, "default", "left", "center")
    rows = rows + 1
    -- pages
    startX = (screenW-all)/2
    startY = 132
    if((players[i+1]==nil)or(rows==8)) then
      dxDrawText("jne9703 © 2021, Page "..page.."/"..math.ceil(#players/maxpagesize), startX+all+avatarW-dxGetTextWidth("jne9703 © 2021, Page "..page.."/"..math.ceil(#players/maxpagesize), 1, "default", false), startY+(rows*bottomrowmargin)+(rows*32), startX, startY, tocolor(255,255,255), 1, "default")
    end
  end
end)

bindKey("pgup", "down", function()
  if((page-1)<=0) then
    page=math.ceil(#players/maxpagesize)
  else
    page=page-1
  end
end)

bindKey("pgdn", "down", function()
  if((page+1)>math.ceil(#players/maxpagesize)) then
    page=1
  else
    page=page+1
  end
end)