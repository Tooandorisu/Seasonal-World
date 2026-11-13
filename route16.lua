local roofs={
  {288,32,96,30}, -- North gate passage
  {288,96,96,30}, -- Cycling Road entrance
  {96,64,64,14},  -- Fly house
}

-- Follow the house's side awnings down to their eaves.
for row=0,7 do
  local width=math.max(5,15-row*2)
  local y=78+row
  roofs[#roofs+1]={96,y,width,1}
  roofs[#roofs+1]={160-width,y,width,1}
end
roofs[#roofs+1]={97,86,4,1}
roofs[#roofs+1]={155,86,4,1}

return {
  roofs=roofs, details=roofs, warmRoofs=true, finishRoofs=roofs,
  protect={{288,32,96,160},{96,64,64,32}},
  lights={{292,62,88},{292,126,88},{100,78,56}}, fences={},
  -- The live house palette also tints the trim just below both eaves green.
  tintTrim={{432,176,16,16},{80,272,16,16},{96,78,16,10},{144,78,16,10}},
  -- The east cycling gate warp at (24,11) shares its cell with fence posts.
  entranceSnow={{272,64,16,32},{384,64,16,32},{272,160,16,32},{384,160,16,16}},
  ledgeSnow={},
}
