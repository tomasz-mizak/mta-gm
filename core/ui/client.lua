--[[

  displayUI

]]



function displayUI(state,exceptions) -- showing hud function (chat visiblity doesnt work)
  if(not(exceptions)) then
    showChat(state)
    localPlayer:setData("displaySpeedometer", state)
    localPlayer:setData("displayHud", state)
    for _, component in ipairs(hudComponents) do
      if(component[2]) then
        setPlayerHudComponentVisible(component[1], state)
      else
        setPlayerHudComponentVisible(component[1], false)
      end
    end
  else
    for _, c1 in ipairs(hudComponents) do
      for _, c2 in ipairs(exceptions) do
        local condition = false
        if(c1[1]==c2) then
          setPlayerHudComponentVisible(c1[1], not state)
          condition = true
          break
        end
        if(not(condition)) then
          setPlayerHudComponentVisible(c1[1], state)
        end
      end
    end
    local chatCondition = false
    for _, c in ipairs(exceptions) do
      if(c=="chat") then
        chatCondition = true
      end
    end
    if(chatCondition) then
      showChat(not state)
    else
      showChat(state)
    end
    localPlayer:setData("displaySpeedometer", state)
    localPlayer:setData("displayHud", state)
  end
end
addEvent('uiDisplay', true)
addEventHandler('uiDisplay', root, displayUI)