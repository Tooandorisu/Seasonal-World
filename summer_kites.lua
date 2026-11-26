local mod = ...
local Kites = {}
local diamond, swallow, carp = 0, 1, 2

-- The peg is on bare ground. The sign of lean places the kite east or west of it.
Kites.routes = {
  ROUTE_7 = {salt = 31,
    {x=2,  y=9,  ground=0x39, style=swallow, lean= 1, phase=0.6},
    {x=7,  y=14, ground=0x39, style=diamond, lean= 1, phase=1.8},
  },
  CELADON_CITY = {salt = 32,
    {x=40, y=14, ground=0x39, style=diamond, lean=-1, phase=0.0}, -- Pokémon Center
    {x=1,  y=18, ground=0x39, style=carp,    lean= 1, phase=1.4}, -- western exit
  },
  ROUTE_16 = {salt = 33,
    {x=15, y=11, ground=0x39, style=swallow, lean=-1, phase=0.8}, -- western gate doors
    {x=7,  y=17, ground=0x39, style=diamond, lean= 1, phase=1.6},
  },
  ROUTE_17 = {salt = 34,
    {x=18, y=44,  ground=0x2c, style=carp,    lean=-1, phase=1.0},
    {x=9,  y=62,  ground=0x39, style=diamond, lean= 1, phase=0.4},
    {x=6,  y=87,  ground=0x39, style=swallow, lean=-1, phase=2.0},
    {x=10, y=139, ground=0x39, style=carp,    lean= 1, phase=0.2},
  },
  ROUTE_18 = {salt = 35,
    {x=7,  y=5,  ground=0x39, style=swallow, lean= 1, phase=1.2},
    {x=43, y=6,  ground=0x39, style=diamond, lean=-1, phase=2.2}, -- Fuchsia side of the gate
  },
}

local function onGround(map, site)
  local x, y, tile = site.x * 2, site.y * 2, site.ground
  return map:tileAt(x, y) == tile and map:tileAt(x + 1, y) == tile
     and map:tileAt(x, y + 1) == tile and map:tileAt(x + 1, y + 1) == tile
end

local gustDuration = 2.8
local gusts = {}

function Kites.ride(map, x, y)
  if not map.tileAt or mod.options:get("summer_motion") == false then return end
  for _, site in ipairs(Kites.routes[map.id]) do
    local dx, dy = x - site.x, y - site.y
    if dx * dx + dy * dy <= 9 and onGround(map, site) then
      local now = love.timer.getTime()
      local start = gusts[site]
      if not start or now < start or now - start >= gustDuration then gusts[site] = now end
    end
  end
end

local function liftLevel(site, now)
  local start = gusts[site]
  if not start then return 0 end
  local age = now and now - start
  if not age or age < 0 or age >= gustDuration then
    gusts[site] = nil
    return 0
  end
  -- A quick rise, a short taut hold, then a slower return to the breeze.
  local t = math.min(1, age / 0.55, (gustDuration - age) / 1.7)
  return math.floor(5 * t * t * (3 - 2 * t) + 0.5)
end

local sheet
local quads = {}
local function pose(g, style, level, phase)
  if not sheet then
    sheet = mod.assets:image("summer_kites.png")
    sheet:setFilter("nearest", "nearest")
  end
  local row = style * 6 + level
  local key = row * 12 + phase
  if not quads[key] then quads[key] = g.newQuad(phase * 40, row * 56, 40, 56, 480, 1008) end
  return quads[key]
end

function Kites.draw(g, map, sites, camX, camY, x0, y0, x1, y1, now)
  for _, site in ipairs(sites) do
    local x, y = site.x * 16 + 8, site.y * 16 + 11
    local left = x - (site.lean == 1 and 9 or 31)
    if left < (x1 + 1) * 16 and left + 40 > x0 * 16
        and y - 52 < (y1 + 1) * 16 and y + 4 > y0 * 16 and onGround(map, site) then
      local phase = now and math.floor((now + site.phase) * 5) % 12 or 0
      local quad = pose(g, site.style, liftLevel(site, now), phase)
      g.setColor(1, 1, 1, 1)
      g.draw(sheet, quad, x - camX, y - camY, 0, site.lean, 1, 9, 52)
    end
  end
end

return Kites
