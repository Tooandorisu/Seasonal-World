local ledges={{96,16,96,8},{96,48,96,8},{224,40,96,8},{8,72,80,8},{0,80,192,8}}
local standard={
  lights={}, fences={}, details={},
  tintTrim={{176,144,16,16}}, ledgeSnow=ledges,
}

local beachHouseRoof={{64,128,64,14}}
-- Cover the angled eaves without extending into the door and windows.
for row=0,7 do
  local width=math.max(5,15-row*2)
  local y=142+row
  beachHouseRoof[#beachHouseRoof+1]={64,y,width,1}
  beachHouseRoof[#beachHouseRoof+1]={128-width,y,width,1}
end
beachHouseRoof[#beachHouseRoof+1]={65,150,4,1}
beachHouseRoof[#beachHouseRoof+1]={123,150,4,1}

local yellow={
  roofs=beachHouseRoof, details=beachHouseRoof, warmRoofs=true, finishRoofs=beachHouseRoof,
  protect={{64,128,64,32}},
  lights={{68,142,56}}, fences={},
  tintTrim={{176,176,16,16},{64,142,16,10},{112,142,16,10}},
  ledgeSnow=ledges,
}

function standard.forMap(_,_,game)
  if game=="yellow" then return yellow end
  return standard
end

return standard
