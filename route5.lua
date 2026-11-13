local roofs={
  {128,288,64,32},  -- Day Care
  {256,384,64,30},  -- Underground Path
  {96,480,128,30},  -- Saffron gate
}

return {
  roofs=roofs, details=roofs, warmRoofs=true, finishRoofs=roofs,
  protect={{128,288,64,64},{256,384,64,64},{96,480,128,64}},
  lights={{144,319,32},{260,414,56},{100,510,120}}, fences={},
  tintTrim={{272,464,16,16}},
  -- Both north gate warps are on open ground. The south warp is a doorway.
  entranceSnow={{144,464,32,16}},
  ledgeSnow={{96,48,128,8},{96,112,128,8},{96,176,128,8},
    {96,240,128,8},{96,368,128,8}},
}
