local mod = ...
local Picnics = {}
local red, blue, green = 0, 1, 2

-- The right half of each blanket holds the pinwheel. Both halves must still be open ground.
Picnics.sites = {
  ROUTE_4 = {salt = 25,
    {x=14, y=8,  ground=0x39, cloth=red,   phase=0.4}, -- Mt. Moon Pokémon Center
    {x=87, y=10, ground=0x39, cloth=blue,  phase=3.7}, -- Cerulean approach
  },
  ROUTE_3 = {salt = 26,
    {x=2,  y=8, ground=0x2c, cloth=red,   phase=1.3}, -- Pewter approach
    {x=56, y=9, ground=0x2c, cloth=green, phase=4.1}, -- route sign
  },
  PEWTER_CITY = {salt = 27,
    {x=12, y=28, ground=0x2c, cloth=blue, phase=2.6}, -- Pokémon Center
    {x=20, y=8,  ground=0x2c, cloth=red,  phase=5.0}, -- museum lawn
  },
  ROUTE_2 = {salt = 28,
    {x=5, y=8,  ground=0x39, cloth=green, phase=2.0}, -- north of the forest gate
    {x=2, y=46, ground=0x39, cloth=blue,  phase=4.7}, -- south of the forest gate
  },
  VIRIDIAN_FOREST = {salt = 29,
    {x=18, y=43, ground=0x30, cloth=green, phase=0.9}, -- southern clearing
    {x=25, y=19, ground=0x30, cloth=red,   phase=4.3}, -- eastern Trainer Tips sign
  },
  VIRIDIAN_CITY = {salt = 30,
    {x=22, y=28, ground=0x2c, cloth=blue,  phase=1.6}, -- Pokémon Center
    {x=22, y=4,  ground=0x39, cloth=green, phase=5.2}, -- northern lane
  },
}

local sheet, blankets, wheels
local function loadArt(g)
  sheet = mod.assets:image("summer_picnics.png")
  sheet:setFilter("nearest", "nearest")
  blankets, wheels = {}, {}
  for color = 0, 2 do
    blankets[color] = g.newQuad(0, color * 16, 32, 16, 240, 48)
    local frames = {}
    for i = 0, 15 do frames[i] = g.newQuad(32 + 13 * i, color * 16, 13, 13, 240, 48) end
    wheels[color] = frames
  end
end

local function onGround(map, site)
  for ty = site.y * 2, site.y * 2 + 1 do
    for tx = site.x * 2, site.x * 2 + 3 do
      if map:tileAt(tx, ty) ~= site.ground then return false end
    end
  end
  return true
end

local pushDuration = 2.4
local pushedAt = {}

function Picnics.spin(map, cellX, cellY)
  local sites = Picnics.sites[map.id]
  if not sites or not map.tileAt or mod.options:get("summer_motion") == false then return end
  for _, site in ipairs(sites) do
    if cellX == site.x + 1 and cellY == site.y and onGround(map, site) then
      local now = love.timer.getTime()
      local previous = pushedAt[site]
      if not previous or now < previous or now - previous >= pushDuration then pushedAt[site] = now end
      return
    end
  end
end

local function wheelFrame(site, now)
  if not now then
    pushedAt[site] = nil
    return 0
  end
  -- One turn in the breeze, followed by a pause. A tap adds three full turns
  -- so the wheel settles back into the same breeze without a jump.
  local t = math.min(((now + site.phase) % 6) / 2.1, 1)
  local turns = t * t * (3 - 2 * t)
  local start = pushedAt[site]
  if start then
    local age = (now - start) / pushDuration
    if age >= 0 and age < 1 then turns = turns + 3 * age * (2 - age)
    else pushedAt[site] = nil end
  end
  return math.floor(turns * 16 + 0.5) % 16
end

function Picnics.draw(g, map, sites, camX, camY, x0, y0, x1, y1, now)
  for _, site in ipairs(sites) do
    if site.x <= x1 and site.x + 1 >= x0 and site.y >= y0 and site.y <= y1 and onGround(map, site) then
      if not sheet then loadArt(g) end
      local x, y = site.x * 16 - camX, site.y * 16 - camY
      g.setColor(1, 1, 1, 1)
      g.draw(sheet, blankets[site.cloth], x, y)
      g.draw(sheet, wheels[site.cloth][wheelFrame(site, now)], x + 19, y)
    end
  end
end

return Picnics
