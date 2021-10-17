--[[

  fuelstations
  ~ client

]]

local TankFuelDialog = {}
TankFuelDialog.width = 180
TankFuelDialog.height = 150
TankFuelDialog.headerText = "Tankowanie pojazdu"
TankFuelDialog.offer = {5,10,15,30,50}

function showTankFuelDialog(costPeerLiter)
 
  if not (localPlayer.inVehicle and localPlayer.vehicle) then return end
  local neededFuel = tonumber(localPlayer.vehicle:getData("max_fuel")) - tonumber(localPlayer.vehicle:getData("fuel"))
  
  TankFuelDialog.window = DGS:dgsCreateWindow((screenW-TankFuelDialog.width)/2,(screenH-TankFuelDialog.height)/2,TankFuelDialog.width,TankFuelDialog.height,TankFuelDialog.headerText,false,0xFFFFFFFF,25,nil,tocolor(0,0,0,255),nil,tocolor(0,0,0,130),5,true)
  DGS:dgsWindowSetSizable(TankFuelDialog.window,false)
  local text = DGS:dgsCreateLabel(5,5,TankFuelDialog.width-5*2,35,string.format("Cena paliwa za litr: $%s.\nW baku brakuje: %sl paliwa.", tostring(costPeerLiter), tostring(round(neededFuel,2))),false,TankFuelDialog.window)

  local combobox = DGS:dgsCreateComboBox(5, 40, 150, 24, "Wybierz ilość paliwa", false, TankFuelDialog.window, 20, tocolor(255,255,255,255), 1, 1, nil, nil, nil, tocolor(0,0,0,180), tocolor(0,0,0,180), tocolor(0,0,0,180))
  for i, v in ipairs(TankFuelDialog.offer) do
    if(v>neededFuel) then break end
    DGS:dgsComboBoxAddItem(combobox, string.format("Zatankuj %sl",v))
  end
  DGS:dgsComboBoxAddItem(combobox, "Zatankuj do pełna")

  local cancel = DGS:dgsCreateButton(5,95,80,24,"Anuluj",false,TankFuelDialog.window,tocolor(255,255,255,255),1,1,nil,nil,nil,tocolor(200,0,0,180),tocolor(200,0,0,255),tocolor(255,0,0,255))
  local apply = DGS:dgsCreateButton(95,95,80,24,"Zatwierdź",false,TankFuelDialog.window,tocolor(255,255,255,255),1,1,nil,nil,nil,tocolor(0,200,0,180),tocolor(0,200,0,255),tocolor(0,255,0,255))

  addEventHandler("onDgsMouseClick", cancel, function(button, state)
    if button ~= "left" or state ~= "down" then return end
    destroyElement(TankFuelDialog.window)
    cursor(false)
  end)

  addEventHandler("onDgsMouseClick", apply, function(button, state)
    if button ~= "left" or state ~= "down" then return end
    local count = DGS:dgsComboBoxGetItemCount(combobox)
    local sel = DGS:dgsComboBoxGetSelectedItem(combobox)
    if sel~=-1 then
      if sel == count then -- full tank
        triggerServerEvent("buyFuel",localPlayer,neededFuel)        
      else -- from offer
        triggerServerEvent("buyFuel",localPlayer,TankFuelDialog.offer[sel])
      end
    else
      output("Musisz wybrać ile litrów paliwa chcesz zatankować.")
    end
  end)
  cursor(true)
end

addEvent("displayFuelDialog", true)
addEventHandler("displayFuelDialog", root, function(state,fuelCost)
  if state then showTankFuelDialog(fuelCost) else
    if isElement(TankFuelDialog.window) then 
      destroyElement(TankFuelDialog.window) 
    end
    cursor(false)
  end
end)

addEventHandler("onClientRender", root, function() -- render textdraws on fuel station markers
  for i, v in ipairs(Element.getAllByType("marker")) do
    if v:getData("fuelDispenser") then
      local position = v.position
      position.z = position.z + 1
      renderTextDraw({
        text = string.format("Pozostało %d/%sl paliwa", tonumber(v:getData("currentValue")), tonumber(v:getData("maxValue"))),
        textColor = {255, 98, 0, 255},
        position = position
      })
      local data = {
        currentValue = v:getData("currentValue"),
        maxValue = v:getData("maxValue"),
        isActive = v:getData("isActive")
      }
      position.z = position.z + 1.5
      renderDebugTextDraw({
        text = data,
        textColor = {255,0,0,255},
        position = position
      })
    end
  end
end)