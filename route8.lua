local roofs={
  {32,128,96,30}, -- Saffron gate
  {192,32,64,14}, -- Underground Path
}

return {
  roofs=roofs, details=roofs, warmRoofs=true, finishRoofs=roofs,
  protect={{32,128,96,64},{192,32,64,32}},
  lights={{36,158,88},{196,46,56}}, fences={},
  tintTrim={{272,48,16,16}},
  -- These four warp cells contain only ground. The fence posts start below them.
  entranceSnow={{16,144,16,32},{128,144,16,32}},
  ledgeSnow={{288,48,64,8},{288,112,64,8}},
}
