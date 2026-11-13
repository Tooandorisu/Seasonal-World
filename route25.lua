local roofs={{704,16,64,14}}

-- Follow the angled sides of Bill's roof and leave the windows below it clear.
for row=0,7 do
  local width=math.max(5,15-row*2)
  local y=30+row
  roofs[#roofs+1]={704,y,width,1}
  roofs[#roofs+1]={768-width,y,width,1}
end

-- Bill's upper windows sit between the side panels, above the blue fascia.
roofs[#roofs+1]={704,32,16,8}
roofs[#roofs+1]={752,32,16,8}
roofs[#roofs+1]={707,40,58,8}

return {
  roofs=roofs, details=roofs, warmRoofs=true, finishRoofs=roofs,
  protect={{704,16,64,48}},
  preserveSurfaceBlock=0x55,
  preserveCellTiles={[0x3c]=true},
  lights={{708,30,56}}, fences={},
  tintTrim={{688,48,16,16},{704,30,16,10},{752,30,16,10}},
  ledgeSnow={{0,112,128,8}},
}
