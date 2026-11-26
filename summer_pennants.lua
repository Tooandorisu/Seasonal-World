local mod = ...
local Pennants = {}

-- Two rows of native 8px tiles support each string. The small houses have sloped ends.
local broadRoof = {
  {0x12, 0x12, 0x12, 0x12, 0x12, 0x12},
  {0x17, 0x17, 0x17, 0x17, 0x17, 0x17},
}
local smallRoof = {
  {0x06, 0x07, 0x07, 0x07, 0x07, 0x08},
  {0x16, 0x17, 0x17, 0x17, 0x17, 0x18},
}
local gateWall = {
  {0x0a, 0x0a, 0x0a, 0x0a, 0x0a, 0x0a},
  {0x4b, 0x4b, 0x4b, 0x4b, 0x4b, 0x4b},
}
local teal, saffron, lilac = 0, 1, 2

Pennants.streets = {
  ROUTE_6 = {salt = 16,
    {tx=19, ty=10, support=gateWall,  color=saffron, phase=0.0}, -- Saffron gate
    {tx=33, ty=22, support=broadRoof, color=teal,    phase=2.3}, -- Underground Path
  },
  SAFFRON_CITY = {salt = 17,
    {tx=17, ty=54, support=broadRoof, color=saffron, phase=0.8}, -- Pokémon Center
    {tx=49, ty=18, support=broadRoof, color=teal,    phase=3.5}, -- Poké Mart
  },
  ROUTE_8 = {salt = 18,
    {tx=7,  ty=18, support=broadRoof, color=saffron, phase=1.5}, -- Saffron gate
    {tx=25, ty=4,  support=smallRoof, color=lilac,   phase=4.3}, -- Underground Path
  },
  LAVENDER_TOWN = {salt = 19,
    {tx=5,  ty=6,  support=broadRoof, color=lilac, phase=0.3}, -- Pokémon Center
    {tx=13, ty=16, support=smallRoof, color=lilac, phase=2.8}, -- Mr. Fuji's house
  },
}

local sheet, colors
local function loadArt(g)
  sheet = mod.assets:image("summer_pennants.png")
  sheet:setFilter("nearest", "nearest")
  colors = {}
  for palette = 0, 2 do
    local frames = {}
    for pose = 0, 8 do
      frames[pose] = g.newQuad(pose * 48, palette * 16, 48, 16, 432, 48)
    end
    colors[palette] = frames
  end
end

local function supportsPennants(map, site)
  for row, tiles in ipairs(site.support) do
    for col, tile in ipairs(tiles) do
      if map:tileAt(site.tx + col - 1, site.ty + row - 1) ~= tile then return false end
    end
  end
  return true
end

local function poseAt(now, phase)
  if now then
    local step = math.floor(((now + phase) % 5.6) / 0.22)
    if step < 8 then return step + 1 end
  end
  return 0
end

function Pennants.draw(g, map, street, camX, camY, x0, y0, x1, y1, now)
  for _, site in ipairs(street) do
    local x, y = site.tx * 8, site.ty * 8
    if x < (x1 + 1) * 16 and x + 48 > x0 * 16 and y < (y1 + 1) * 16 and y + 16 > y0 * 16
        and supportsPennants(map, site) then
      if not sheet then loadArt(g) end
      g.setColor(1, 1, 1, 1)
      g.draw(sheet, colors[site.color][poseAt(now, site.phase)], x - camX, y - camY)
    end
  end
end

return Pennants
