--[[

  infopanel
  ~ client

]]

infopanel = {}
infopanel.state = false
infopanel.addictionalWidth = 20 -- correct \n blank char width 

infopanel.startx = 0
infopanel.starty = 0

infopanel.margin = 12

infopanel.avatarWidth = 42
infopanel.avatarHeight = 42

infopanel.header = {}
infopanel.header.height = 24
infopanel.header.background = tocolor(255,255,255,200)
infopanel.header.fontColor = tocolor(0,0,0,255)

infopanel.header.nick = {}
infopanel.header.nick.margin = 8

infopanel.header.nick.color = tocolor(0,0,0,200)

infopanel.body = {}
infopanel.body.background = tocolor(0,0,0,180)
infopanel.body.padding = 6
infopanel.body.addictionalHeight = 20
infopanel.content = {}
infopanel.body.color = tocolor(255,255,255,200)

infopanel.calc = {}
infopanel.calc.header = {}
infopanel.calc.header.nickname = {}
infopanel.calc.body = {}
infopanel.calc.body.text = {}

bindKey('f1', 'down', function()
  if not isLogged(localPlayer) then return end
  infopanel.state = not infopanel.state
  playSFX("script", 22, 0, false)
end)

addEventHandler('onClientRender', root, function()
  if not infopanel.state then return end
  displayUI(false)
  showChat(false) -- idk is this needed, but i leave it here

  infopanel.header.nick.text = localPlayer.name .. "\n#" .. tostring(localPlayer:getData('accountID'))

  infopanel.content = {
    "Punkty respektu: " .. tostring(localPlayer:getData("respect")),
    "Model ubrania: " .. tostring(localPlayer.model),
    "Zabójstwa: " .. tostring(localPlayer:getData("kills")),
    "Zgony: " .. tostring(localPlayer:getData("deaths")),
    "Płeć: " .. getGenderName(localPlayer)
  }

  infopanel.calc.x = infopanel.startx + infopanel.margin
  infopanel.calc.y = infopanel.starty + infopanel.margin

  infopanel.calc.header.w = dxGetTextWidth(infopanel.header.nick.text) + infopanel.avatarWidth + infopanel.addictionalWidth
  infopanel.calc.header.h = infopanel.avatarHeight

  infopanel.calc.header.nickname.x = infopanel.calc.x + infopanel.avatarWidth + infopanel.header.nick.margin
  infopanel.calc.header.nickname.y = infopanel.calc.y + infopanel.header.nick.margin
  infopanel.calc.header.nickname.w = dxGetTextWidth(infopanel.header.nick.text) + infopanel.addictionalWidth - infopanel.header.nick.margin * 2
  infopanel.calc.header.nickname.h = infopanel.calc.header.h - infopanel.header.nick.margin * 2

  infopanel.calc.body.x = infopanel.calc.x
  infopanel.calc.body.y = infopanel.calc.y + infopanel.avatarHeight
  infopanel.calc.body.w = dxGetTextWidth(table.concat(infopanel.content, '\n')) + infopanel.addictionalWidth + infopanel.body.padding * 2
  infopanel.calc.body.h = dxGetFontHeight() * #infopanel.content + infopanel.body.padding * 2

  infopanel.calc.body.text.x = infopanel.calc.body.x + infopanel.body.padding 
  infopanel.calc.body.text.y = infopanel.calc.body.y + infopanel.body.padding 
  infopanel.calc.body.text.w = infopanel.calc.body.w - infopanel.body.padding * 2
  infopanel.calc.body.text.h = infopanel.calc.body.h - infopanel.body.padding * 2

  if(infopanel.calc.header.w>infopanel.calc.body.w) then
    infopanel.calc.body.w = infopanel.calc.header.w
  else
    infopanel.calc.header.w = infopanel.calc.body.w
  end

  dxDrawRectangle(infopanel.calc.x,infopanel.calc.y,infopanel.calc.header.w,infopanel.calc.header.h,infopanel.header.background)
  dxDrawImage(infopanel.calc.x,infopanel.calc.y,infopanel.avatarWidth,infopanel.avatarHeight,heads[localPlayer.model])

  dxDrawText(infopanel.header.nick.text,infopanel.calc.header.nickname.x,infopanel.calc.header.nickname.y,infopanel.calc.header.nickname.w,infopanel.calc.header.nickname.h,infopanel.header.nick.color)

  dxDrawRectangle(infopanel.calc.body.x,infopanel.calc.body.y,infopanel.calc.body.w,infopanel.calc.body.h,infopanel.body.background)
  dxDrawText(table.concat(infopanel.content, '\n'),infopanel.calc.body.text.x,infopanel.calc.body.text.y,infopanel.calc.body.text.w,infopanel.calc.body.text.h,infopanel.body.color)

end)