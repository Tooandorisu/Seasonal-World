local function layout(roofs,lights,protect)
  return {
    roofs=roofs, details=roofs, finishRoofs=roofs, finishRoofMode=0,
    lights=lights, protect=protect, fences={}, ledgeSnow={}, snowNorthBorder=true,
  }
end

local native = layout(
  {{16,0,288,30},{112,30,96,32}},
  {{16,29,80},{112,61,96},{224,29,80}},
  {{0,0,320,64},{96,64,128,32}}
)
-- The original entrance columns rise into the roof line. Keep their
-- masonry protected and cool only the pale cap above each carved head.
native.tintTrim = {{96,24,16,24},{208,24,16,24}}

-- TileShift extends the roof above the map and places a plinth across
-- the next row below the doors. Protect that row from ground snow.
local expanded = layout(
  {{16,0,72,30},{88,-16,160,64},{248,0,56,30}},
  {{88,47,160}},
  {{0,0,320,64},{88,64,160,32},{128,96,64,16}}
)
expanded.northBorderRoof = expanded.roofs[2]

function native.forMap(map,provider,game)
  local roofs=provider and provider.roofs
  if roofs and type(roofs.cells)=="function" and map.def then
    local ok,cells=pcall(roofs.cells,roofs,game,map.def)
    if ok and cells and cells.rows then
      for _,entry in ipairs(cells.rows[-1] or {}) do
        if entry.role=="gen1_whole_native_indigo_league" then return expanded end
      end
    end
  end
  return native
end

return native
