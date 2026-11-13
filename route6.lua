local roofs={
  {128,32,96,30},   -- Saffron gate
  {256,160,64,30},  -- Underground Path
}

return {
  roofs=roofs, details=roofs, warmRoofs=true, finishRoofs=roofs,
  protect={{128,32,96,96},{256,160,64,64}},
  lights={{132,62,88},{260,190,56}}, fences={},
  tintTrim={{304,240,16,16}},
  -- The two north warps are on flat ground above the gate.
  entranceSnow={{144,16,32,16}},
  ledgeSnow={{0,112,128,8},{224,112,96,8},{0,176,256,8}},
}
