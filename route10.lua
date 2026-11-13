local roofs={
  {160,256,64,30}, -- Rock Tunnel Pokémon Center
  {32,544,128,30}, -- Power Plant
  -- The original Pokémon Tower roof straddles the Lavender Town seam.
  {192,1064,96,54},{192,1118,16,2},{272,1118,16,2},
}

-- The top eight rows widen by two pixels per side along the sloped corners.
for row=0,7 do
  roofs[#roofs+1]={207-row*2,1056+row,66+row*4,1}
end

return {
  roofs=roofs, details=roofs, warmRoofs=true, finishRoofs=roofs,
  protect={{160,256,64,64},{32,544,128,96},{192,1056,96,96}},
  lights={{164,286,56},{36,574,120}}, fences={},
  tintTrim={{112,304,16,16},{80,656,16,16},{144,880,16,16}},
  ledgeSnow={{32,176,192,8},{32,264,96,8},{32,520,128,8},
    {160,680,64,8},{224,808,64,8},{32,840,96,8},{144,840,72,8},
    {224,912,64,8},{32,944,32,8},{72,968,144,8},{224,976,64,8},
    {96,1064,80,8}},
}
