--[[

  authorization
  ~ server

]]

function login_info(plr,msg)
  if(plr and msg) then
    triggerClientEvent(plr, 'updateLoginMessage', plr, msg)
  end
end

function register_info(plr,msg)
  if(plr and msg) then
    triggerClientEvent(plr, 'updateRegisterMessage', plr, msg)
  end
end

function reactivate_button(plr,btnString)
  if(plr and btnString) then
    triggerClientEvent(plr, 'reactivateButton', plr, btnString)
  end
end

function account_login(plr, username, password)
  if(not(plr)) then plr = source end
  if(plr and username and password) then
    local usrLen = #username
    local passLen = #password
    if(not(usrLen>=authsys.uminlen)) then login_info(plr, "Minimalna długość nazwy użytkownika to "..authsys.uminlen.." znaki.") reactivate_button(plr, "login") return end
    if(not(usrLen<=authsys.umaxlen)) then login_info(plr, "Maksymalna długość nazwy użytkownika to  "..authsys.umaxlen.." znaków.") reactivate_button(plr, "login") return end
    if(not(string.match(username,"[^a-zA-Z0-9]")==nil)) then login_info(plr, "Nazwa użytkownika nie może zawierać znaków specjalnych.") reactivate_button(plr, "login") return end
    if(not(passLen>=authsys.pminlen)) then login_info(plr, "Minimalna długość hasła to "..authsys.pminlen.." znaki.") reactivate_button(plr, "login") return end
    if(not(passLen<=authsys.pmaxlen)) then login_info(plr, "Maksymalna długość hasła to "..authsys.pmaxlen.." znaków.") reactivate_button(plr, "login") return end
    if(tryToLoginAttempt) then return end
    local result = mysqlQuery("select * from accounts where username=?", username)
    if(result~=false) then
      if(#result>0) then
        result = result[1]
        if(passwordVerify(password, result["password"], {})) then
          local id = result["id"]
          local condition = true
          for _, e in ipairs(getElementsByType("player")) do
            if(e:getData('accountID')==id) then
              condition = false
              break
            end
          end
          if(condition) then
            if(plr:logIn(Account(username, password), password)) then
              if(not(mysqlExec("update accounts set last_login=current_timestamp where id=?", result["id"]))) then
                outputDebug("Cannot update last login date for player "..plr.name)
              end
              output(plr, string.format("Zalogowano na konto %s.", username))
              outputDebug(plr.name.." has logged to the account!")
                -- apply account settings
              plr:setName(username)
              plr:setData('accountID', id)
              plr:setData('logged', true)
              triggerClientEvent(plr, 'setRegisterGUIVisible', plr, false)
              triggerClientEvent(plr, 'setLoginGUIVisible', plr, false)
              triggerClientEvent(plr, 'stopAuthMusic', plr)
                -- load player data
              local data = {
                settings = fromJSON(result["settings"]),
                respect = result["respect"],
                money = result["money"],
                health = result["health"],
                armor = result["armor"],
                deaths = result["deaths"],
                kills = result["kills"],
                skin = result["skin"],
                gender = result["gender"],
                position = fromJSON(result["position"]),
                rotation = fromJSON(result["rotation"])
              }
              load_player(plr, data)
              return true
            else
              Account.add(username, password)
              login_info(plr, "Tworzenie konta!")
              account_login(plr, username, password)
            end
          else
            login_info(plr, "Inny gracz jest obecnie zalogowany na to konto!")
            reactivate_button(plr, "login")
          end
        else
          plr:setData("authAttempts",(plr:getData("authAttempts") or 0)+1)
          if(plr:getData("authAttempts")>=3) then
            plr:kick("Zbyt dużo nieudanych prób logowania.")
          else
            login_info(plr, "Hasło do konta '"..username.."' jest niepoprawne ("..plr:getData("authAttempts").."/"..authsys.loginAttempts..").")
            reactivate_button(plr, "login")
          end
        end
      else
        login_info(plr, "Konto nie istnieje.")
        reactivate_button(plr, "login")
      end
    else
      login_info(plr, "Limit czasu logowania został przekroczony.")
      reactivate_button(plr, "login")
    end
  end
end
addEvent('accountLogin', true)
addEventHandler('accountLogin', root, account_login)

function account_register(plr, username, password, repassword, gender)
  if(not(plr)) then plr = source end
  if(plr and username and password and repassword) then
    local usrLen = #username
    local passLen = #password
    if(not(usrLen>=authsys.uminlen)) then register_info(plr, "Minimalna długość nazwy użytkownika to "..authsys.uminlen.." znaki.") reactivate_button(plr, "register") return end
    if(not(usrLen<=authsys.umaxlen)) then register_info(plr, "Maksymalna długość nazwy użytkownika to  "..authsys.umaxlen.." znaków.") reactivate_button(plr, "register") return end
    if(not(string.match(username,"[^a-zA-Z0-9]")==nil)) then register_info(plr, "Nazwa użytkownika nie może zawierać znaków specjalnych.") reactivate_button(plr, "register") return end
    if(not(passLen>=authsys.pminlen)) then register_info(plr, "Minimalna długość hasła to "..authsys.pminlen.." znaki.") reactivate_button(plr, "register") return end
    if(not(passLen<=authsys.pmaxlen)) then register_info(plr, "Maksymalna długość hasła to "..authsys.pmaxlen.." znaków.") reactivate_button(plr, "register") return end
    if(not(password==repassword)) then register_info(plr, "Hasła różnią się.") reactivate_button(plr, "register") return end
    if(gender==-1) then register_info(plr, "Wybierz płeć.") reactivate_button(plr, "register") return end
    local result = mysqlQuery("select username from accounts where username=?", username)
    if(result~=false) then
      if(#result==0) then
        local sp = spawnPoints[math.random(1,#spawnPoints)]
        local settings = {shaders=false}
        if(mysqlExec("insert into accounts (username, password, settings, respect, money, health, armor, deaths, kills, skin, gender, position, rotation) values (?,?,?,?,?,?,?,?,?,?,?,?,?)", username, passwordHash(password, 'bcrypt', {}), toJSON(settings), 0, 5000, 100, 0, 0, 0, validSkins[gender][math.random(1,#validSkins[gender])], gender, toJSON({sp[1],sp[2],sp[3]}), toJSON({sp[4],sp[5],sp[6]}))) then
          if(Account.add(username, password)) then
            output(plr, string.format("Stworzono konto z nazwą użytkownika %s, życzymy miłej gry.", username))
            outputDebug(plr.name.." has registered Account with name "..username..".")
            account_login(plr, username, password)
          else
            outputDebug("Cannot create ingame account for player "..plr.name..", trying to login without creating ingame account...")
            -- try to login without creating ingame account
            if(account_login(plr, username, password)) then
              output(plr, string.format("Stworzono konto %s, życzymy miłej rozgrywki!", username))
              outputDebug(plr.name.." logged successfull to account!")
            else
              register_info(plr, "Nie można stworzyć konta w grze, zgłoś ten wyjątek administracji.")
              reactivate_button(plr, "register")
            end
          end
        else
          register_info(plr, "Nie można stworzyć konta, zgłoś ten wyjątek administracji.")
          reactivate_button(plr, "register")
        end
      else
        register_info(plr, "Konto z nazwą użytkownika "..username.." już istnieje.")
        reactivate_button(plr, "register")
      end
    end
  else
    register_info(plr, "Query timeouted.")
    reactivate_button(plr, "register")
  end
end
addEvent('accountRegister', true)
addEventHandler('accountRegister', root, account_register)
addEventHandler('onPlayerCommand', root, function(command) -- disables the hardcoded commands
  if(command=="whois") then
    cancelEvent()
  elseif(command=="logout") then
    cancelEvent()
  elseif(command=="login") then
    cancelEvent()
  elseif(command=="register") then
    cancelEvent()
  elseif(command=="nick") then
    cancelEvent()
  end
end)
addEvent('disconnectByKick', true) -- event for handle client "disconnect" button
addEventHandler('disconnectByKick', root, function() source:kick('disconnected') end)