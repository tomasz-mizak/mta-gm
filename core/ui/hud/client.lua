--[[

  ui/hud
  ~ client
  
]]

local hud = {}

hud.time = {}
hud.time.x = 0
hud.time.y = 0
hud.time.xPadding = 4
hud.time.yPadding = 2
hud.time.xOffset = 20
hud.time.yOffset = 20
hud.time.bottomMargin = 2
hud.time.weekday = {"Poniedziałek","Wtorek","Środa","Czwartek","Piątek","Sobota","Niedziela"}

hud.money = {}
hud.money.xPadding = 4
hud.money.yPadding = 2
hud.money.bottomMargin = 8

hud.weapon = {}
hud.weapon.xPadding = 4
hud.weapon.yPadding = 2
hud.weapon.bottomMargin = 8

hud.otherInfo = {}
hud.otherInfo.xPadding = 4
hud.otherInfo.yPadding = 2
hud.otherInfo.bottomMargin = 8

hud.moneyNotify = {}

-- removing data from moneyNotify
function removeMoneyFromArray()
  table.remove(hud.moneyNotify, 1)
  -- setTimer(function() -- verify table is empty, after 6 seconds
  --   if(#hud.moneyNotify>0) then
  --     removeMoneyFromArray()
  --   end
  -- end, 6000, 1)
end

-- give player money event handling 
addEvent("GM_givePlayerMoney", true)
addEventHandler("GM_givePlayerMoney", localPlayer, function(money)
  table.insert(hud.moneyNotify, { '+', '$' .. money })
  setTimer(removeMoneyFromArray, 5000, 1)
end)
addEvent("GM_takePlayerMoney", true)
addEventHandler("GM_takePlayerMoney", localPlayer, function(money)
  table.insert(hud.moneyNotify, { '-', '$' .. money })
  setTimer(removeMoneyFromArray, 5000, 1)
end)


function get_correct_weekday()
  local realtime = getRealTime()
  if(realtime.weekday==0) then
    return hud.time.weekday[7]
  else
    return hud.time.weekday[realtime.weekday]
  end
end

addEventHandler('onClientRender',root,function()

  if(not(localPlayer:getData("displayHud"))) then return end

  local realtime = getRealTime()
  hud.time.text = string.format("%s, %02d.%02d.%04d, %02d:%02d",get_correct_weekday(),realtime.weekday,realtime.month,tostring(realtime.year+1900),realtime.hour,realtime.minute)
  hud.time.w = dxGetTextWidth(hud.time.text) + hud.time.xPadding * 2
  hud.time.h = dxGetFontHeight() + hud.time.yPadding * 2
  hud.time.cx1 = screenW - hud.time.w - hud.time.xOffset
  hud.time.cy1 = 0 + hud.time.yOffset
  hud.time.cx2 = hud.time.cx1 + hud.time.w
  hud.time.cy2 = hud.time.cy1 + hud.time.h

  hud.otherInfo.text = "Zdrowie: "..math.floor(localPlayer.health).."%"
  local armor = localPlayer:getArmor()
  if(armor>0) then
    hud.otherInfo.text = hud.otherInfo.text .. ", Kamizelka: "..round(armor,0).."%"
  end
  if(isElementInWater(localPlayer)) then
    local oxygen = math.floor(localPlayer.oxygenLevel/10)
    hud.otherInfo.text = hud.otherInfo.text .. ", Tlen: "..round(oxygen,0).."%"

  end
  hud.otherInfo.w = dxGetTextWidth(hud.otherInfo.text) + hud.otherInfo.xPadding * 2
  hud.otherInfo.h = hud.time.h
  hud.otherInfo.cx1 = screenW - hud.otherInfo.w - hud.time.xOffset
  hud.otherInfo.cy1 = 0 + hud.time.yOffset + hud.time.h + hud.time.bottomMargin
  hud.otherInfo.cx2 = hud.otherInfo.cx1 + hud.otherInfo.w
  hud.otherInfo.cy2 = hud.otherInfo.cy1 + hud.otherInfo.h

  hud.money.text = string.format("$%s",localPlayer.getMoney())
  hud.money.w = dxGetTextWidth(hud.money.text) + hud.money.xPadding * 2
  hud.money.h = hud.time.h
  hud.money.cx1 = screenW - hud.money.w - hud.time.xOffset
  hud.money.cy1 = 0 + hud.time.yOffset + hud.time.h + hud.time.bottomMargin + hud.otherInfo.h + hud.otherInfo.yPadding
  hud.money.cx2 = hud.money.cx1 + hud.money.w
  hud.money.cy2 = hud.money.cy1 + hud.money.h

  hud.weapon.text = checkTranslationForWeapon(getPedWeapon(localPlayer))
  if(getPedWeapon(localPlayer)~=0) then hud.weapon.text = string.format("%s, %s-%s", hud.weapon.text, getPedAmmoInClip(localPlayer), getPedTotalAmmo(localPlayer)) end
  hud.weapon.w = dxGetTextWidth(hud.weapon.text) + hud.weapon.xPadding * 2
  hud.weapon.h = hud.time.h
  hud.weapon.cx1 = screenW - hud.weapon.w - hud.time.xOffset
  hud.weapon.cy1 = 0 + hud.time.yOffset + hud.time.h * 2 + hud.time.bottomMargin * 2 + hud.otherInfo.h + hud.otherInfo.yPadding
  hud.weapon.cx2 = hud.weapon.cx1 + hud.weapon.w
  hud.weapon.cy2 = hud.weapon.cy1 + hud.weapon.h

  dxDrawRectangle(hud.time.cx1,hud.time.cy1-hud.time.bottomMargin,hud.time.w,hud.time.bottomMargin,tocolor(255,255,255,140))
  dxDrawRectangle(hud.time.cx1,hud.time.cy1,hud.time.w,hud.time.h,tocolor(0,0,0,200))
  dxDrawText(hud.time.text,hud.time.cx1,hud.time.cy1,hud.time.cx2,hud.time.cy2,tocolor(255,255,255,200),1,"default","center","center")

  dxDrawRectangle(hud.otherInfo.cx1,hud.otherInfo.cy1-hud.time.bottomMargin,hud.otherInfo.w,hud.time.bottomMargin,tocolor(255,255,255,140))
  dxDrawRectangle(hud.otherInfo.cx1,hud.otherInfo.cy1,hud.otherInfo.w,hud.otherInfo.h,tocolor(0,0,0,200))
  dxDrawText(hud.otherInfo.text,hud.otherInfo.cx1,hud.otherInfo.cy1,hud.otherInfo.cx2,hud.otherInfo.cy2,tocolor(255,0,0,180),1,"default","center","center")

  dxDrawRectangle(hud.money.cx1,hud.money.cy1-hud.time.bottomMargin,hud.money.w,hud.time.bottomMargin,tocolor(255,255,255,140))
  dxDrawRectangle(hud.money.cx1,hud.money.cy1,hud.money.w,hud.money.h,tocolor(0,0,0,200))
  dxDrawText(hud.money.text,hud.money.cx1,hud.money.cy1,hud.money.cx2,hud.money.cy2,tocolor(0,200,0,200),1,"default","center","center")

  dxDrawRectangle(hud.weapon.cx1,hud.weapon.cy1-hud.time.bottomMargin,hud.weapon.w,hud.time.bottomMargin,tocolor(255,255,255,140))
  dxDrawRectangle(hud.weapon.cx1,hud.weapon.cy1,hud.weapon.w,hud.weapon.h,tocolor(0,0,0,200))
  dxDrawText(hud.weapon.text,hud.weapon.cx1,hud.weapon.cy1,hud.weapon.cx2,hud.weapon.cy2,tocolor(52, 201, 235,200),1,"default","center","center")

  -- money give/take render
  for i, v in ipairs(hud.moneyNotify) do
    local x,y = hud.money.cx1, hud.money.cy1+hud.money.h + 5
    local text = v[2]
    local text2 = v[2]
    if(v[1]=='+') then
      text = '#00ff00+'..text
      text2 = '+'..text2
    else
      text = '#ff0000-'..text
      text2 = '-'..text2
    end
    y = y + ((i-1)*dxGetFontHeight())
    local offsetX = 5
    local offsetY = 24
    dxDrawText(text2,x-150-offsetX+0.5,y-0.5+offsetY,x+50+1-offsetX,y+offsetY+dxGetFontHeight()-1,tocolor(0,0,0,200),1,"default","right","center",false,false,false,true)
    dxDrawText(text,x-150-offsetX,y+offsetY,x+50-offsetX,y+offsetY+dxGetFontHeight(),tocolor(0,255,0,200),1,"default","right","center",false,false,false,true)
  end
end)