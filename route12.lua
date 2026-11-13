local roofs={
  {128,256,96,30}, -- Lavender gate
  {160,1216,64,14}, -- Super Rod house
}

-- The side awnings widen toward the bottom. Stop each row at the eave
-- so the bright door and window trim below it keep their original colours.
for row=0,7 do
  local width=math.max(5,15-row*2)
  local y=1230+row
  roofs[#roofs+1]={160,y,width,1}
  roofs[#roofs+1]={224-width,y,width,1}
end
roofs[#roofs+1]={161,1238,4,1}
roofs[#roofs+1]={219,1238,4,1}

return {
  roofs=roofs, details=roofs, warmRoofs=true, finishRoofs=roofs,
  protect={{128,256,96,96},{160,1216,64,32}},
  preserveSurfaceBlock=0x54,
  lights={{132,286,88},{164,1230,56}}, fences={},
  tintTrim={{208,208,16,16},{176,1008,16,16}},
  ledgeSnow={},
}
