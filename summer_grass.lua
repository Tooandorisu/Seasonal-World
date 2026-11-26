local mod = ...
local Grass = {}

-- Each row lists the native grass cells with seed heads along the field edge.
Grass.routes = {
  ROUTE_15 = {salt = 11, rows = {
    {y = 8, 22, 33, 47, 56},
    {y = 9, 18, 20, 23, 30, 32, 35, 46, 49, 52, 54, 57},
  }},
  ROUTE_14 = {salt = 12, rows = {
    {y = 18, 4, 6, 9},
    {y = 20, 4, 9},
    {y = 22, 9},
    {y = 23, 4, 6, 8},
  }},
  ROUTE_13 = {salt = 13, rows = {
    {y = 4, 39, 42, 45, 47},
    {y = 5, 38},
    {y = 6, 47},
    {y = 7, 38, 40, 43, 45, 47},
  }},
}

local sheet, poses
local function loadArt(g)
  sheet = mod.assets:image("summer_grass.png")
  sheet:setFilter("nearest", "nearest")
  poses = {}
  for i = 0, 5 do
    poses[i] = g.newQuad(i * 16, 0, 16, 16, 96, 16)
  end
end

local function fullGrassCell(map, x, y, tile)
  local tx, ty = x * 2, y * 2
  return map:isGrassCell(x, y) and map:tileAt(tx, ty) == tile
     and map:tileAt(tx + 1, ty) == tile and map:tileAt(tx + 1, ty + 1) == tile
end

local function windPose(now, x, y, salt)
  if not now then return 0 end
  -- The same gust reaches each tuft a little later to the east and north.
  local age = (now - (x - y) * 0.23 - salt * 0.67) % 6
  if age < 0.28 then return 1 end
  if age < 0.94 then return 2 end
  if age < 1.38 then return 1 end
  return 0
end

function Grass.draw(g, map, route, camX, camY, x0, y0, x1, y1, now)
  local tile = map.tileset and map.tileset.grassTile
  if not tile or not map.isGrassCell then return end
  g.setColor(1, 1, 1, 1)
  for _, row in ipairs(route.rows) do
    local y = row.y
    if y >= y0 and y <= y1 then
      for _, x in ipairs(row) do
        if x >= x0 and x <= x1 and fullGrassCell(map, x, y, tile) then
          if not sheet then loadArt(g) end
          local variety = (math.floor(x / 2) + y + route.salt) % 2
          local pose = windPose(now, x, y, route.salt)
          g.draw(sheet, poses[variety * 3 + pose], x * 16 - camX, y * 16 - camY)
        end
      end
    end
  end
end

return Grass
