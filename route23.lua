local roofs={
  {16,384,256,92},   -- Victory Road gateway roof above the two entrances
  {32,2240,192,64},  -- Route 22 Gate roof south of its entrance tiles
}

return {
  roofs=roofs, details=roofs, warmRoofs=true,
  protect={{0,384,288,128},{32,2240,192,64}},
  tintTrim={{0,368,16,96},{272,368,16,96}},
  entranceSnow={{112,2224,32,16}}, -- Flat paving on both Route 22 Gate warps
  lights={}, fences={}, ledgeSnow={},
}
