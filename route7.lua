local roofs={
  {192,128,96,30}, -- Saffron gate
  {64,160,64,30},  -- Underground Path
}

return {
  roofs=roofs, details=roofs, warmRoofs=true, finishRoofs=roofs,
  protect={{192,128,96,64},{64,160,64,64}},
  lights={{196,158,88},{68,190,56}}, fences={},
  tintTrim={{48,208,16,16}},
  -- The northwest warp shares its cell with two fence posts.
  entranceSnow={{176,160,16,16},{288,144,16,32}},
  ledgeSnow={{32,112,96,8},{32,176,32,8},{128,176,64,8}},
}
