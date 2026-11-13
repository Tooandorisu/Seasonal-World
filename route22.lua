-- The gate roof can extend four cells north of its map. The bottom
-- bound sits above the first row of windows.
local roofs={{32,-64,192,98}}

return {
  roofs=roofs, details=roofs, warmRoofs=true, snowDarkRoof=true,
  finishRoofs=roofs, finishRoofMode=0,
  protect={{32,0,192,96}},
  tintTrim={{112,176,16,16}},
  lights={}, fences={}, ledgeSnow={},
}
