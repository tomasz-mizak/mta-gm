--[[
  
  speedometer
  
  errors:
    when a vehicle has been deleted, db3 throws errors

]]

-->> Init
local imgXY = 24
local imgRightMargin = 12
local showSpeedo = false

local right = {}
right.x = 0
right.y = 0
right.w = 160
right.h = 104
right.xOffset = 20
right.yOffset = 20
right.xPadding = 8
right.yPadding = 8
right.rowOffset = 8
right.color = tocolor(220,220,220,180)
-- animation
right.static_ax = 500
right.current_ax = right.static_ax
right.ax_state = true
right.ax_speed = 10

local left = {}
left.w = 170
left.h = 72
left.xPadding = 8
left.yPadding = 8
left.rowOffset = 8
left.color = tocolor(220,220,220,140)

local top = {}
top.h = 30
top.xPadding = 8
top.yPadding = 3
top.xOffset = 4
top.color = tocolor(0,0,0,200)

-->> right side
local vehicleImg = {}
vehicleImg.img = DxTexture('img/speedo/motor.png')
vehicleImg.motor = DxTexture('img/speedo/motor.png')
vehicleImg.quad = DxTexture('img/speedo/quad.png')
vehicleImg.bike = DxTexture('img/speedo/bike.png')
vehicleImg.plane = DxTexture('img/speedo/plane.png')
vehicleImg.aircraft = DxTexture('img/speedo/aircraft.png')
vehicleImg.boat = DxTexture('img/speedo/boat.png')
vehicleImg.trailer = DxTexture('img/speedo/trailer.png')
vehicleImg.train = DxTexture('img/speedo/train.png')
vehicleImg.car = DxTexture('img/speedo/car.png')

vehicleImg.color = tocolor(255,255,255,200)

local vehicleText = {}
vehicleText.text = "none"
vehicleText.color = tocolor(0,0,0,200)

local speedImg = {}
speedImg.img = DxTexture('img/speedo/speedometer.png')
speedImg.color = tocolor(255,255,255,200)

local speedText = {}
speedText.text = "0 km/h"
speedText.color = tocolor(0,0,0,200)

local healthImg = {}
healthImg.img = DxTexture('img/speedo/health.png')
healthImg.color = tocolor(255,255,255,200)

local healthText = {}
healthText.text = "0%"
healthText.color = tocolor(0,0,0,200)

-->> left side
local fuelImg = {}
fuelImg.img = DxTexture('img/speedo/fuel.png')
fuelImg.color = tocolor(255,255,255,200)

local fuelText = {}
fuelText.text = "399/400 L"
fuelText.color = tocolor(0,0,0,200)

local mileageImg = {}
mileageImg.img = DxTexture('img/speedo/mileage.png')
mileageImg.color = tocolor(255,255,255,200)

local mileageText = {}
mileageText.text = "1270000002121 km"
mileageText.color = tocolor(0,0,0,200)

-->> top controls
local engineImg = {}
engineImg.img = DxTexture('img/speedo/engine.png')
engineImg.color = tocolor(255,255,255,50)

local alertImg = {}
alertImg.img = DxTexture('img/speedo/alert.png')
alertImg.color = tocolor(255,255,255,50)

local tireImg = {}
tireImg.img = DxTexture('img/speedo/tire.png')
tireImg.color = tocolor(255,255,255,50)

local lowfuelImg = {}
lowfuelImg.img = DxTexture('img/speedo/low_fuel.png')
lowfuelImg.color = tocolor(255,255,255,50)

addEventHandler('onClientRender', root, function()

  if(not(localPlayer.inVehicle)) then return end
  if(not(localPlayer.vehicle)) then return end
  if(not(localPlayer:getData("displaySpeedometer"))) then return end

  -- fuel state img handling
  local fuelRatio = round(localPlayer.vehicle:getData('fuel') / localPlayer.vehicle:getData('max_fuel'),2)
  if(fuelRatio<=0.2) then lowfuelImg.color = tocolor(235, 0, 0, 100)
  elseif(fuelRatio<=0.4) then lowfuelImg.color = tocolor(235, 219, 52, 100)
  else lowfuelImg.color = tocolor(255,255,255,50) end

  -- wheel's state img handling
  local wheelsArray = {localPlayer.vehicle:getWheelStates()}
  local wheelsGood = true
  for _, v in ipairs(wheelsArray) do
    if v~=0 then
      wheelsGood = false
      break
    end
  end
  if wheelsGood then tireImg.color = tocolor(255,255,255,50)
  else tireImg.color = tocolor(235, 0, 0, 100) end

  -- engine state img handling
  if(localPlayer.vehicle.health<=400) then engineImg.color = tocolor(235, 0, 0, 100)
  elseif(localPlayer.vehicle.health<=750) then engineImg.color = tocolor(235, 219, 52, 100)
  elseif(localPlayer.vehicle.health<=900) then engineImg.color = tocolor(50, 168, 82, 100)
  else engineImg.color = tocolor(255,255,255,50) end

  fuelText.text = round(localPlayer.vehicle:getData('fuel'),2)..'/'..localPlayer.vehicle:getData('max_fuel')..' L'
  mileageText.text = round(localPlayer.vehicle:getData('mileage'),2)..' km'

  -->> right correct
  right.correctedW = dxGetTextWidth(localPlayer.vehicle.name) + (right.xPadding*2) + imgXY + 40
  right.w = right.correctedW

  -->> left correct
  left.correctedW_mileage = dxGetTextWidth(mileageText.text) + (left.xPadding*2) + imgXY + 20
  left.correctedW_fuel = dxGetTextWidth(fuelText.text) + (left.xPadding*2) + imgXY + 20
  if(left.correctedW_mileage>=left.correctedW_fuel) then
    left.w = left.correctedW_mileage
  else
    left.w = left.correctedW_fuel
  end

  -->> update static ax before any calcs
  right.static_ax = left.w + right.w + right.xOffset

  -->> ax manipulation
  if(right.ax_state) then
    if(right.current_ax>0) then
      right.current_ax = right.current_ax - right.ax_speed
    end
  else
    if(right.current_ax<right.static_ax) then
      right.current_ax = right.current_ax + right.ax_speed
    end
  end
  
  -->> right calc + animation on x
  right.cx = right.x+(screenW-right.w)-right.xOffset + right.current_ax
  right.cy = right.y+(screenH-right.h)-right.yOffset
  -->> left calc
  left.cx = right.cx - left.w
  left.cy = right.cy
  -->> top calc
  top.cx = left.cx
  top.cy = left.cy - top.h
  top.w = right.w + left.w
  -->> vehicle img switch
  if(localPlayer.vehicle.vehicleType=="Bike") then
    vehicleImg.img = vehicleImg.motor
  elseif(localPlayer.vehicle.vehicleType=="Quad") then
    vehicleImg.img = vehicleImg.quad
  elseif(localPlayer.vehicle.vehicleType=="BMX") then
    vehicleImg.img = vehicleImg.bike
  elseif(localPlayer.vehicle.vehicleType=="Plane") then
    vehicleImg.img = vehicleImg.plane
  elseif(localPlayer.vehicle.vehicleType=="Helicopter") then
    vehicleImg.img = vehicleImg.aircraft
  elseif(localPlayer.vehicle.vehicleType=="Boat") then
    vehicleImg.img = vehicleImg.boat
  elseif(localPlayer.vehicle.vehicleType=="Trailer") then
    vehicleImg.img = vehicleImg.trailer
  elseif(localPlayer.vehicle.vehicleType=="Train") then
    vehicleImg.img = vehicleImg.train
  else
    vehicleImg.img = vehicleImg.car
  end
  -->> vehicle img calc
  vehicleImg.cx = right.cx+right.xPadding
  vehicleImg.cy = right.cy+right.yPadding
  -->> vehicle text calc
  vehicleText.cx = vehicleImg.cx + imgXY + imgRightMargin
  vehicleText.cy = vehicleImg.cy
  vehicleText.cw = vehicleImg.cx + right.w - (imgXY + imgRightMargin)
  vehicleText.ch = vehicleImg.cy + imgXY
  -->> vehicle text correct
  vehicleText.text = localPlayer.vehicle.name
  -->> speed img calc
  speedImg.cx = right.cx+right.xPadding
  speedImg.cy = right.cy+right.yPadding + imgXY + right.rowOffset
  -->> speed text correct
  speedText.text = math.ceil(getElementSpeed(localPlayer.vehicle, "km/h")).." km/h"
  -->> speed text calc
  speedText.cx = speedImg.cx + imgXY + imgRightMargin
  speedText.cy = speedImg.cy
  speedText.cw = speedImg.cx + right.w - (imgXY + imgRightMargin)
  speedText.ch = speedImg.cy + imgXY
  -->> health img calc
  healthImg.cx = right.cx+right.xPadding
  healthImg.cy = right.cy+right.yPadding + imgXY*2 + right.rowOffset*2
  -->> health text correct
  healthText.text = math.ceil((math.ceil(localPlayer.vehicle.health-251)/7.51))
  if(healthText.text<0) then healthText.text = 0 end
  healthText.text = healthText.text .. "%"
  -->> health text calc
  healthText.cx = healthImg.cx + imgXY + imgRightMargin
  healthText.cy = healthImg.cy
  healthText.cw = healthImg.cx + right.w - (imgXY + imgRightMargin)
  healthText.ch = healthImg.cy + imgXY
  -->> fuel img calc
  fuelImg.cx = left.cx + left.xPadding
  fuelImg.cy = left.cy + left.yPadding
  -->> fuel text calc
  fuelText.cx = fuelImg.cx + imgXY + imgRightMargin
  fuelText.cy = fuelImg.cy
  fuelText.cw = fuelImg.cx + left.w - (imgXY + imgRightMargin)
  fuelText.ch = fuelImg.cy + imgXY
  -->> mileage img calc
  mileageImg.cx = left.cx + left.xPadding
  mileageImg.cy = left.cy + left.yPadding + imgXY + right.rowOffset
  -->> mileage text calc
  mileageText.cx = mileageImg.cx + imgXY + imgRightMargin
  mileageText.cy = mileageImg.cy
  mileageText.cw = mileageImg.cx + left.w - (imgXY + imgRightMargin)
  mileageText.ch = mileageImg.cy + imgXY

  -->> engine img calc
  engineImg.cx = top.cx + top.xPadding
  engineImg.cy = top.cy + top.yPadding
  -->> alert img calc
  alertImg.cx = top.cx + top.xPadding*2 + imgXY + top.xOffset
  alertImg.cy = top.cy + top.yPadding
  -->> tire img calc
  tireImg.cx = top.cx + top.xPadding*3 + imgXY*2 + top.xOffset*3
  tireImg.cy = top.cy + top.yPadding
  -->> low_fuel img calc
  lowfuelImg.cx = top.cx + top.xPadding*4 + imgXY*3 + top.xOffset*4
  lowfuelImg.cy = top.cy + top.yPadding

  dxDrawRectangle(right.cx,right.cy,right.w,right.h,right.color)
  dxDrawRectangle(left.cx,left.cy,left.w,left.h,left.color)
  dxDrawRectangle(top.cx,top.cy,top.w,top.h,top.color)
  dxDrawText(getRadioChannelName(getRadioChannel()),top.cx,top.cy-dxGetFontHeight(1),top.cx+top.w,top.cy-dxGetFontHeight(1)+top.h,tocolor(255,255,255,150),1,"default","right")

  dxDrawImage(vehicleImg.cx,vehicleImg.cy,imgXY,imgXY,vehicleImg.img,0,0,0,vehicleImg.color)
  dxDrawText(vehicleText.text,vehicleText.cx,vehicleText.cy,vehicleText.cw,vehicleText.ch,vehicleText.color,1,"default","left","center")

  dxDrawImage(speedImg.cx,speedImg.cy,imgXY,imgXY,speedImg.img,0,0,0,speedImg.color)
  dxDrawText(speedText.text,speedText.cx,speedText.cy,speedText.cw,speedText.ch,speedText.color,1,"default","left","center")

  dxDrawImage(healthImg.cx,healthImg.cy,imgXY,imgXY,healthImg.img,0,0,0,healthImg.color)
  dxDrawText(healthText.text,healthText.cx,healthText.cy,healthText.cw,healthText.ch,healthText.color,1,"default","left","center")

  dxDrawImage(fuelImg.cx,fuelImg.cy,imgXY,imgXY,fuelImg.img,0,0,0,fuelImg.color)
  dxDrawText(fuelText.text,fuelText.cx,fuelText.cy,fuelText.cw,fuelText.ch,fuelText.color,1,"default","left","center")

  dxDrawImage(mileageImg.cx,mileageImg.cy,imgXY,imgXY,mileageImg.img,0,0,0,mileageImg.color)
  dxDrawText(mileageText.text,mileageText.cx,mileageText.cy,mileageText.cw,mileageText.ch,mileageText.color,1,"default","left","center")

  dxDrawImage(engineImg.cx,engineImg.cy,imgXY,imgXY,engineImg.img,0,0,0,engineImg.color)
  dxDrawImage(alertImg.cx,alertImg.cy,imgXY,imgXY,alertImg.img,0,0,0,alertImg.color)
  dxDrawImage(tireImg.cx,tireImg.cy,imgXY,imgXY,tireImg.img,0,0,0,tireImg.color)
  dxDrawImage(lowfuelImg.cx,lowfuelImg.cy,imgXY,imgXY,lowfuelImg.img,0,0,0,lowfuelImg.color)

end)

addEventHandler("onClientVehicleEnter",root,function()
  right.ax_state = true
end,true,"high")

addEventHandler("onClientVehicleStartExit",root,function()
  right.ax_state = false
end,true,"high")
