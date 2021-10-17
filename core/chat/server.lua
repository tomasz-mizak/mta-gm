--[[

  chat
  ~ server

]]

addEventHandler('onPlayerChat', root, function(message, messageType) 
  if(source:getData('logged')) then
    local time = getRealTime()
    local rankColor = getHexRankColor(source)
    for _, plr in ipairs(getElementsByType('player')) do
      plr:outputChat(rankColor.."["..(string.format('%02d:%02d', time.hour, time.minute)).."] "..source.name..":#ffffff "..message, 0, 0, 0, true)
      write_log_line("["..(string.format('%02d:%02d', time.hour, time.minute)).."] "..source.name..": "..message)
    end
    local messages = source:getData("chatMessages") or {}
    table.insert(messages, message)
    source:setData("chatMessages", messages)
    setTimer(function(source)
      local messages = source:getData("chatMessages") or {}
      for i=1,#messages do
        if(messages[i+1]~=nil) then
          messages[i] = messages[i+1]
        end
        if(i==#messages) then
          messages[i] = nil
        end
      end
      source:setData("chatMessages", messages)
    end, 8000, 1, source)
  end
  cancelEvent()
end)