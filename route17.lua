return {
  lights={}, fences={}, details={}, ledgeSnow={},
  -- Rail tiles share walkable cells with the path. Tint the ground there
  -- without replacing the original rails or their end posts.
  preserveCellTiles={[0x10]=true,[0x21]=true},
  tintTrim={{144,816,16,16},{144,1008,16,16},{144,1200,16,16},
    {144,1392,16,16},{144,1776,16,16},{144,2256,16,16}},
}
