local function layout(center)
  local city = {lights={}, details={}, roofs={}, protect={}, fences={}, ledgeSnow={}, tintTrim={}}
  local buildings = {
    {64,0,96,64,30},   -- Pokémon Mansion
    {224,0,96,64,30},  -- Gym
    {64,96,96,64,30},  -- Pokémon Lab
    center,
    {224,128,64,64,30}, -- Mart
  }
  for _,b in ipairs(buildings) do
    local x,y,w,h,roof = b[1],b[2],b[3],b[4],b[5]
    city.protect[#city.protect+1] = {x,y,w,h}
    city.lights[#city.lights+1] = {x,y+roof,w}
    local bounds = {{x,y,w,roof}}
    if b ~= center or w == 64 then
      bounds[#bounds+1] = {x,y+roof,w,4}
      bounds[#bounds+1] = {x,y+roof+4,14,6}
      bounds[#bounds+1] = {x+w-14,y+roof+4,14,6}
    end
    for _,r in ipairs(bounds) do
      city.details[#city.details+1] = r
      city.roofs[#city.roofs+1] = r
    end
  end
  for _,p in ipairs({{9,5},{16,11},{12,11},{9,11},{13,3}}) do
    city.tintTrim[#city.tintTrim+1] = {p[1]*16,p[2]*16,16,16}
  end
  city.warmRoofs = true
  city.finishRoofs = city.roofs
  return city
end

local compact = layout({160,128,64,64,30})
local expanded = layout({144,112,80,80,44})
-- The expanded roof starts partway down its top row. Cool the ground
-- visible through those transparent margins without painting over the roof.
expanded.tintTrim[#expanded.tintTrim+1] = {144,112,80,16}

function compact.forMap(map,provider,game)
  local roofs = provider and provider.roofs
  if roofs and type(roofs.cells) == "function" and map.def then
    local ok,cells = pcall(roofs.cells,roofs,game,map.def)
    if ok and cells then
      for _,entry in ipairs((cells.rows or {})[7] or {}) do
        if entry.role == "larger_center" and entry.x == 11 then return expanded end
      end
    end
  end
  return compact
end

return compact
