--[[

  nametags
  ~ client

]]


local scale = 1
local font = "default"
local renderDistance = 20
addEventHandler('onClientRender', root, function()
  if(not(localPlayer:getData("logged"))) then return end
  local cameraMatrix = Vector3(localPlayer.cameraMatrix)
  local localPlayerPosition = Vector3(localPlayer.position)
  for _, e in ipairs(getElementsByType('player')) do
    local elementPosition = Vector3(e.position)
    local distanceBetween = getDistanceBetweenPoints3D(localPlayerPosition, elementPosition)
    if(distanceBetween<=renderDistance) then
      distanceBetween = math.ceil(distanceBetween)
      elementPosition.z = elementPosition.z + (distanceBetween/50) + 1
      if(isLineOfSightClear(localPlayerPosition,elementPosition, true, false, false) and not(localPlayer==e) and (localPlayer.dimension==e.dimension)) then
      local draw = Vector3(getScreenFromWorldPosition(elementPosition))
      if(draw.x~=0 and draw.y~=0) then
          local respect = e:getData("respect").." respect points" or "0 respect points"
          local nickname = e.name
          local messages = e:getData("chatMessages") or {}
          if(nickname) then
            local padding = Vector2(1,1)
            -- draw messages
            local drawChatMessages = Vector2(draw.x, draw.y)
            for i, message in ipairs(messages) do
              if(i==1) then
                  drawChatMessages.y = drawChatMessages.y - 30
              end
              if(#message>34) then
                drawChatMessages.y = drawChatMessages.y - 30
              else
                drawChatMessages.y = drawChatMessages.y - 25
              end
              if(#message>34) then
                local messageWidth = 300
                local messageHeight = dxGetFontHeight(scale, font)*2
                local multipler = Vector2(0,0)
                --dxDrawRectangle(drawChatMessages.x-(messageWidth/2)-padding.x, drawChatMessages.y-padding.y, messageWidth+(padding.x*multipler.x), messageHeight+(padding.y*multipler.y), tocolor(0,0,0,80))
                dxDrawText(message, drawChatMessages.x-(messageWidth/2)-padding.x, drawChatMessages.y-padding.y, drawChatMessages.x+(messageWidth/2)+padding.x, drawChatMessages.y-padding.y+messageHeight+(padding.y*multipler.y), tocolor(255,255,255,255), scale, font, "center", "center", true, true)
              else
                local messageWidth = dxGetTextWidth(message, scale, font)
                local messageHeight = dxGetFontHeight(scale, font)*2
                local multipler = Vector2(0,0)
                --dxDrawRectangle(drawChatMessages.x-(messageWidth/2)-padding.x, drawChatMessages.y-padding.y, messageWidth+(padding.x*multipler.x), messageHeight+(padding.y*multipler.y), tocolor(0,0,0,80))
                dxDrawText(message, drawChatMessages.x-(messageWidth/2)-padding.x, drawChatMessages.y-padding.y, drawChatMessages.x+(messageWidth/2)+padding.x, drawChatMessages.y-padding.y+messageHeight+(padding.y*multipler.y), tocolor(255,255,255,255), scale, font, "center", "center", true, true)
              end
              if(i==3) then break end
            end
            -- draw respect
            draw.y = draw.y - 20
            local respectWidth = dxGetTextWidth(respect, scale, font)
            local respectHeight = dxGetFontHeight(scale, font)
            local multipler = Vector2(0,0)
            dxDrawRectangle(draw.x-(respectWidth/2)-padding.x, draw.y-padding.y, respectWidth+(padding.x*multipler.x), respectHeight+(padding.y*multipler.y), tocolor(0,0,0,170))
            dxDrawText(respect, draw.x-(respectWidth/2)-padding.x, draw.y-padding.y, draw.x+(respectWidth/2)+padding.x, draw.y-padding.y+respectHeight+(padding.y*multipler.y), tocolor(200,200,200,200), scale, font, "center", "center")
            -- draw nickname
            draw.y = draw.y + 20
            local nicknameWidth =dxGetTextWidth(nickname, scale, font)
            local nicknameHeight = dxGetFontHeight(scale, font)
            local multipler = Vector2(0,0)
            dxDrawRectangle(draw.x-(nicknameWidth/2)-padding.x, draw.y-padding.y, nicknameWidth+(padding.x*multipler.x), nicknameHeight+(padding.y*multipler.y), tocolor(0,0,0,170))
            dxDrawText(nickname, draw.x-(nicknameWidth/2)-padding.x, draw.y-padding.y, draw.x+(nicknameWidth/2)+padding.x, draw.y-padding.y+nicknameHeight+(padding.y*multipler.y), tocolor(unpack(getRgbRankColor(e))), scale, font, "center", "center", false, false, false, true)
          end
        end
      end
    end
  end
end)