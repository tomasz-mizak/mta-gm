--[[

  vehiclecontrol
  ~ client

]]

local vcontrol = {}

vcontrol.x = 0
vcontrol.y = 0
vcontrol.w = 200
vcontrol.h = 16
vcontrol.bg = {tocolor(0,0,0,180),tocolor(100,100,100,150)}
vcontrol.color = {tocolor(255,255,255,200)}

vcontrol.controls = {
  {
    text = {"Włącz światła","Wyłącz światła"},
    fnc = function() print('x') end,
  },
  {
    text = {"Włącz silnik", "Wyłącz silnik"},
    fnc = function() print('x') end,
  },
}

addEventHandler('onClientRender',root,function()
  for i, v in ipairs(vcontrol.controls) do
    local bg = vcontrol.bg[1]
    if(i%2==0) then bg = vcontrol.bg[2] end
    local x, y = vcontrol.x,vcontrol.y+((i-1)*vcontrol.h)
    --dxDrawRectangle(x,y,vcontrol.w,vcontrol.h,bg)
    -- dxDrawText(v.text[1],x,y,x+vcontrol.w,y+vcontrol.h,vcontrol.color[1])
  end
end)