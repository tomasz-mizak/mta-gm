--[[

  authorization
  ~ client

]]

--[[
  inteface
]]
Login = {}
Login.window = DGS:dgsCreateWindow((screenW-414)/2,(screenH-316)/2,414,316,"Logowanie",false,tocolor(255,255,255,255),25,nil,tocolor(0,0,0,255),nil,tocolor(0,0,0,200),5,true)
DGS:dgsWindowSetMovable(Login.window,false)
DGS:dgsWindowSetSizable(Login.window,false)
Login.message = DGS:dgsCreateLabel(0,0,414,47,"Zaloguj się lub stwórz nowe konto.",false,Login.window,tocolor(253,0,0,255))
DGS:dgsLabelSetVerticalAlign(Login.message,"center")
DGS:dgsLabelSetHorizontalAlign(Login.message,"center")
Login.info1 = DGS:dgsCreateLabel(0,47,414,26, "Nazwa użytkownika:",false,Login.window)
DGS:dgsLabelSetVerticalAlign(Login.info1,"center")
DGS:dgsLabelSetHorizontalAlign(Login.info1,"center")
Login.usernameField = DGS:dgsCreateEdit(83,73,249,26,"",false,Login.window)
Login.info2 = DGS:dgsCreateLabel(0,110,414,26,"Hasło:",false,Login.window)
DGS:dgsLabelSetVerticalAlign(Login.info2,"center")
DGS:dgsLabelSetHorizontalAlign(Login.info2,"center")
Login.passwordField = DGS:dgsCreateEdit(83,136,249,26,"",false,Login.window)
DGS:dgsEditSetMasked(Login.passwordField,true)
Login.signin = DGS:dgsCreateButton(10,185,394,28,"Zaloguj się",false,Login.window)
Login.createAccount = DGS:dgsCreateButton(10,217,394,28,"Stwórz nowe konto",false,Login.window)
Login.disconnect = DGS:dgsCreateButton(10,255,394,28, "Rozłącz się :(",false,Login.window)
DGS:dgsSetVisible(Login.window,false)
-- load profile.xml
local xml = XML.load("profile.xml")
if(not(xml)) then
  xml = XML("profile.xml", "profile")
end
local child = xml:findChild("username", 0)
if(not(child)) then
  child = xml:createChild("username")
end
DGS:dgsSetText(Login.usernameField, child:getValue())
xml:saveFile()
xml:unload()

-- register interface
Register = {}
Register.window = DGS:dgsCreateWindow((screenW-414)/2,(screenH-400)/2,414,400,"Tworzenie nowego konta",false,tocolor(255,255,255,255),25,nil,tocolor(0,0,0,255),nil,tocolor(0,0,0,200),5,true)
DGS:dgsWindowSetMovable(Register.window,false)
DGS:dgsWindowSetSizable(Register.window,false)
Register.message = DGS:dgsCreateLabel(0,0,414,47,"Stwórz konto",false,Register.window,tocolor(253,0,0,255))
DGS:dgsLabelSetVerticalAlign(Register.message,"center")
DGS:dgsLabelSetHorizontalAlign(Register.message,"center")
Register.info1 = DGS:dgsCreateLabel(0,47,414,26,"Nazwa użytkownika:",false,Register.window)
DGS:dgsLabelSetVerticalAlign(Register.info1,"center")
DGS:dgsLabelSetHorizontalAlign(Register.info1,"center")
Register.usernameField = DGS:dgsCreateEdit(83,75,249,26,"",false,Register.window)
Register.info2 = DGS:dgsCreateLabel(0,110,414,26,"Hasło:",false,Register.window)
DGS:dgsLabelSetVerticalAlign(Register.info2,"center")
DGS:dgsLabelSetHorizontalAlign(Register.info2,"center")
Register.passwordField = DGS:dgsCreateEdit(83,136,249,26,"",false,Register.window)
DGS:dgsEditSetMasked(Register.passwordField,true)
Register.info3 = DGS:dgsCreateLabel(0,172,414,26,"Powtórz hasło:",false,Register.window)
DGS:dgsLabelSetVerticalAlign(Register.info3,"center")
DGS:dgsLabelSetHorizontalAlign(Register.info3,"center")
Register.repasswordField = DGS:dgsCreateEdit(83,201,249,26,"",false,Register.window)
DGS:dgsEditSetMasked(Register.repasswordField,true)
Register.gender = DGS:dgsCreateComboBox(107,242,200,20,"Wybierz płeć",false,Register.window)
DGS:dgsComboBoxAddItem(Register.gender,"Mężczyzna")
DGS:dgsComboBoxAddItem(Register.gender,"Kobieta")
Register.finalize = DGS:dgsCreateButton(10, 306, 394, 28, "Stwórz konto", false, Register.window)
Register.back = DGS:dgsCreateButton(10, 339, 394, 28, "Cofnij", false, Register.window)
DGS:dgsSetVisible(Register.window,false)

--[[
  handling
]]
function update_login_message(msg) -- update login info label
  if(msg) then
    DGS:dgsSetText(Login.message,msg)
    playSFX("genrl", 53, 2, false)
  end
end
addEvent("updateLoginMessage", true)
addEventHandler("updateLoginMessage", root, update_login_message)
function update_register_message(msg) -- update register info label
  if(msg) then
    DGS:dgsSetText(Register.message,msg)
    playSFX("genrl", 53, 2, false)
  end
end
addEvent('updateRegisterMessage', true)
addEventHandler('updateRegisterMessage', root, update_register_message)
addEvent('reactivateButton', true)
addEventHandler('reactivateButton', root, function(btnString) -- set enabled/disabled button from the server when client sends a request for login
  if(btnString) then
    if(btnString=="login") then
      DGS:dgsSetEnabled(Login.signin, true)
    elseif(btnString=="register") then
      DGS:dgsSetEnabled(Register.finalize, true)
    end
  end
end)
addEventHandler('onDgsMouseClick', root, function(button,state) -- buttons handling
  if(button=="left" and state=="down" and (not(cooldown))) then
    if(source==Login.createAccount) then
      set_login_visible(false)
      set_register_visible(true)
      cooldown = true
      setTimer(function() cooldown = false end, 1000, 1)
    elseif(source==Login.disconnect) then
      triggerServerEvent('disconnectByKick', localPlayer)
      cooldown = true
      setTimer(function() cooldown = false end, 1000, 1)
    elseif(source==Login.signin) then
      DGS:dgsSetEnabled(Login.signin, false)
      triggerServerEvent('accountLogin', localPlayer, false, DGS:dgsGetText(Login.usernameField), DGS:dgsGetText(Login.passwordField))
      local xml = XML.load("profile.xml")
      if (not(xml)) then
        xml = XML("profile.xml", "profile")
      end
      local child = xml:findChild("username", 0)
      child:setValue(DGS:dgsGetText(Login.usernameField))
      xml:saveFile()
      xml:unload()
      cooldown = true
      setTimer(function() cooldown = false end, 1000, 1)
    elseif(source==Register.finalize) then
      DGS:dgsSetEnabled(Register.finalize, false)
      triggerServerEvent('accountRegister', localPlayer, false, DGS:dgsGetText(Register.usernameField), DGS:dgsGetText(Register.passwordField), DGS:dgsGetText(Register.repasswordField), DGS:dgsComboBoxGetSelectedItem(Register.gender))
      cooldown = true
      setTimer(function() cooldown = false end, 1000, 1)
    elseif(source==Register.back) then
      set_register_visible(false)
      set_login_visible(true)
      cooldown = true
      setTimer(function() cooldown = false end, 1000, 1)
    end
  end
end)
function set_register_visible(state) -- set register gui visible
  DGS:dgsSetVisible(Register.window, state)
  cursor(state)
end
addEvent('setRegisterGUIVisible', true)
addEventHandler('setRegisterGUIVisible', root, set_register_visible)
function set_login_visible(state) -- set login gui visible
  DGS:dgsSetVisible(Login.window, state)
  cursor(state)
end
addEvent('setLoginGUIVisible', true)
addEventHandler('setLoginGUIVisible', root, set_login_visible)
local authSound = false
addEvent('stopAuthMusic',true)
addEventHandler('stopAuthMusic', root, function() authSound:destroy() end)
function check_transfer_box() -- login check
  fadeCamera(true)
  showChat(false)
  if(not(getElementData(localPlayer, 'logged'))) then displayUI(false) end
  if(isTransferBoxActive()) then
    setTimer(2000, 1, checkTransferBox)
  else
    if(not(localPlayer:getData("logged"))) then
      set_login_visible(true)
      Camera.setMatrix(1283.4246826172,-893.20416259766,42.875343322754,1303.4353027344,-875.22149658203,46.988639831543)
      local hour = getRealTime().hour
      if(hour>=4 and hour<=9) then
        authSound = Sound('music/authsys/morning.mp3')
      elseif(hour>9 and hour<16) then
        authSound = Sound('music/authsys/noon.mp3')
      else
        authSound = Sound('music/authsys/midnight.mp3')
      end
      if(authSound) then authSound:setVolume(0.2) end
    end
  end
end
check_transfer_box()