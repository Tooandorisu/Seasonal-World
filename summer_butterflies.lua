local mod = ...
local Butterflies = {}
local blue, amber = 0, 1

-- Each bed fits on two adjoining native cells. The offset staggers nearby flights.
Butterflies.meadows = {
  ROUTE_10 = {salt = 20,
    {x=8,  y=70, tile=0x39, color=blue,  offset=0.0}, -- Lavender entrance
    {x=12, y=55, tile=0x39, color=amber, offset=3.1}, -- south of Rock Tunnel
    {x=10, y=22, tile=0x2c, color=blue,  offset=5.4}, -- Pokémon Center
  },
  ROUTE_9 = {salt = 21,
    {x=54, y=8, tile=0x39, color=amber, offset=1.7}, -- eastern approach
    {x=26, y=8, tile=0x2c, color=blue,  offset=4.2}, -- route sign
    {x=3,  y=8, tile=0x2c, color=amber, offset=6.6}, -- Cerulean entrance
  },
  CERULEAN_CITY = {salt = 22,
    {x=16, y=17, tile=0x2c, color=blue,  offset=0.8}, -- Pokémon Center
    {x=23, y=4,  tile=0x2c, color=amber, offset=4.9}, -- Nugget Bridge approach
  },
  ROUTE_24 = {salt = 23,
    {x=13, y=32, tile=0x2c, color=blue,  offset=2.3}, -- bank beside Nugget Bridge
    {x=8,  y=13, tile=0x2c, color=amber, offset=6.0}, -- north end of the bridge
  },
  ROUTE_25 = {salt = 24,
    {x=3,  y=6, tile=0x2c, color=amber, offset=3.6}, -- western bend
    {x=42, y=2, tile=0x39, color=blue,  offset=1.2}, -- Bill's house
  },
}

local sheet, palettes
local function loadArt(g)
  sheet = mod.assets:image("summer_butterflies.png")
  sheet:setFilter("nearest", "nearest")
  palettes = {}
  for color = 0, 1 do
    local beds, wings = {}, {}
    for i = 0, 2 do beds[i] = g.newQuad(i * 32, color * 16, 32, 16, 176, 32) end
    for i = 0, 4 do wings[i] = g.newQuad(96 + i * 16, color * 16, 16, 16, 176, 32) end
    palettes[color] = {beds=beds, wings=wings}
  end
end

local function groundMatches(map, patch)
  for ty = patch.y * 2, patch.y * 2 + 1 do
    for tx = patch.x * 2, patch.x * 2 + 3 do
      if map:tileAt(tx, ty) ~= patch.tile then return false end
    end
  end
  return true
end

-- Coordinates are the butterfly's feet on the two bent flower heads.
local beats = {2, 3, 4, 3}
local function pose(age)
  if age < 2 then
    return 1, age >= 1.0 and age < 1.45 and 1 or 0, 7, 10, 1
  elseif age >= 4 and age < 6 then
    return 2, age >= 5.0 and age < 5.45 and 1 or 0, 24, 8, -1
  end
  local back = age >= 6
  local t = (age - (back and 6 or 2)) / 2
  local u = t * t * (3 - 2 * t)
  if back then u = 1 - u end
  local lift = math.sin(math.pi * t) * ((back and 7 or 11) + 2 * math.sin(4 * math.pi * t))
  local x = math.floor(7 + 17 * u + 0.5)
  local y = math.floor(10 - 2 * u - lift + 0.5)
  local bed = 0
  if t < 0.07 then bed = back and 2 or 1
  elseif t >= 0.93 then bed = back and 1 or 2 end
  return bed, beats[math.floor(t * 20) % 4 + 1], x, y, back and -1 or 1
end

function Butterflies.draw(g, map, patches, camX, camY, x0, y0, x1, y1, now)
  for _, patch in ipairs(patches) do
    -- The higher arc extends one cell above the flowers.
    if patch.x <= x1 and patch.x + 1 >= x0 and patch.y >= y0 and patch.y - 1 <= y1
        and groundMatches(map, patch) then
      if not sheet then loadArt(g) end
      local art = palettes[patch.color]
      local bed, wings, footX, footY, facing = pose(now and (now + patch.offset) % 8 or 0)
      local x, y = patch.x * 16 - camX, patch.y * 16 - camY
      g.setColor(1, 1, 1, 1)
      g.draw(sheet, art.beds[bed], x, y)
      g.draw(sheet, art.wings[wings], x + footX, y + footY, 0, facing, 1, 8, 12)
    end
  end
end

return Butterflies
