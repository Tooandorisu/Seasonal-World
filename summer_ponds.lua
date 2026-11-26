local mod = ...
local Ponds = {}

-- Each destination is the centre of an open-water cell near a walkable bank.
Ponds.sites = {
  FUCHSIA_CITY       = {x = 30, y = 22, waterX = 32, waterY = 21, ground = 0x2c, salt = 6},
  SAFARI_ZONE_CENTER = {x = 20, y = 14, waterX = 19, waterY = 13, ground = 0x30, salt = 7},
  SAFARI_ZONE_EAST   = {x = 16, y =  9, waterX = 17, waterY = 11, ground = 0x30, salt = 8},
  SAFARI_ZONE_NORTH  = {x =  8, y = 17, waterX =  6, waterY = 18, ground = 0x30, salt = 9},
  SAFARI_ZONE_WEST   = {x =  6, y =  9, waterX =  5, waterY = 11, ground = 0x30, salt = 10},
}

-- Open water beside the piers. Each float has its own offset in seconds.
Ponds.fishingSpots = {
  ROUTE_12 = {salt = 14,
    {13, 107, 0.0}, -- southern end of the boardwalk
    {11,  81, 2.1}, -- south of the Super Rod house
    {13,  63, 4.4}, -- Sport Fishing sign
    { 7,  39, 1.2}, -- northern fishing platforms
  },
  VERMILION_CITY = {salt = 15,
    { 4,  5, 1.7}, -- inlet beside the Old Rod house
    {20, 29, 4.9}, -- east of the S.S. Anne boarding pier
  },
}

local sheet, reeds, perched, broadWings, narrowWings

local function loadArt(g)
  sheet = mod.assets:image("summer_ponds.png")
  sheet:setFilter("nearest", "nearest")
  reeds       = g.newQuad( 0, 0, 16, 16, 64, 16)
  perched     = g.newQuad(16, 0, 16, 16, 64, 16)
  broadWings  = g.newQuad(32, 0, 16, 16, 64, 16)
  narrowWings = g.newQuad(48, 0, 16, 16, 64, 16)
end

local function cellMatches(map, x, y, tile)
  local tx, ty = x * 2, y * 2
  return map:tileAt(tx, ty) == tile and map:tileAt(tx + 1, ty) == tile
     and map:tileAt(tx, ty + 1) == tile and map:tileAt(tx + 1, ty + 1) == tile
end

local floatSheet, floatFrames
local function loadFloats(g)
  floatSheet = mod.assets:image("summer_floats.png")
  floatSheet:setFilter("nearest", "nearest")
  floatFrames = {}
  for i = 1, 8 do
    floatFrames[i] = g.newQuad((i - 1) * 16, 0, 16, 16, 128, 16)
  end
end

-- First a small tug, then the float slips under and rises tip first.
-- Frame zero leaves just the widening rings on the surface.
local sinkAt = 4.38
local tugFrames = {
  {3.72, 3}, {4.02, 1}, {4.23, 3}, {sinkAt, 4},
  {5.05, 0}, {5.28, 4}, {5.55, 3},
}

local function floatPose(age)
  if not age then return 1 end
  if age >= 3.5 and age < 5.55 then
    for _, step in ipairs(tugFrames) do
      if age < step[1] then return step[2] end
    end
  end
  local swell = age % 1.75
  return swell >= 0.62 and swell < 1.18 and 2 or 1
end

local function drawRipple(g, x, y, elapsed, strength)
  local progress = elapsed / 1.24
  if progress < 0 or progress >= 1 then return end
  g.setColor(1, 1, 1, strength * (1 - progress * progress))
  g.draw(floatSheet, floatFrames[5 + math.floor(progress * 4)], x, y)
end

function Ponds.drawFloats(g, map, spots, camX, camY, x0, y0, x1, y1, now)
  for _, spot in ipairs(spots) do
    local cx, cy = spot[1], spot[2]
    if cx >= x0 and cx <= x1 and cy >= y0 and cy <= y1 and cellMatches(map, cx, cy, 0x14) then
      if not floatSheet then loadFloats(g) end
      local x, y = cx * 16 - camX, cy * 16 - camY
      local age = now and (now + spot[3]) % 7
      if age then
        drawRipple(g, x, y, age - sinkAt, 1)
        drawRipple(g, x, y, age - sinkAt - 0.42, 0.76)
      end
      local pose = floatPose(age)
      if pose > 0 then
        g.setColor(1, 1, 1, 1)
        g.draw(floatSheet, floatFrames[pose], x, y)
      end
    end
  end
end

local function ease(t)
  return t * t * (3 - 2 * t)
end

local function flight(site, age, x, y, facing)
  local wx, wy = site.waterX * 16 + 8, site.waterY * 16 + 8
  if age >= 4 and age < 6.4 then
    local angle = 2 * math.pi * ease((age - 4) / 2.4)
    x = wx + facing * 5 * math.sin(angle)
    y = wy - 2 * (1 - math.cos(angle))
    if math.cos(angle) < 0 then facing = -facing end
  else
    local u
    if age < 4 then
      u = ease((age - 2.7) / 1.3)
    else
      u = ease((8 - age) / 1.6)
      facing = -facing
    end
    x = x + (wx - x) * u
    y = y + (wy - y) * u - 3 * math.sin(math.pi * u)
  end
  local pose = math.floor((age - 2.7) * 8) % 2 == 0 and broadWings or narrowWings
  return math.floor(x + 0.5), math.floor(y + 0.5), facing, pose
end

function Ponds.draw(g, map, site, camX, camY, x0, y0, x1, y1, now)
  -- Keep flying wings in view even if the camera has passed the reed.
  if x1 < math.min(site.x, site.waterX) - 1 or x0 > math.max(site.x, site.waterX) + 1
      or y1 < math.min(site.y, site.waterY) - 1 or y0 > math.max(site.y, site.waterY) + 1 then return end
  if not cellMatches(map, site.x, site.y, site.ground)
      or not cellMatches(map, site.waterX, site.waterY, 0x14) then return end
  if not sheet then loadArt(g) end
  g.setColor(1, 1, 1, 1)
  local bankX, bankY = site.x * 16, site.y * 16
  g.draw(sheet, reeds, bankX - camX, bankY - camY)
  local x, y = bankX + 9, bankY + 2
  local facing = site.waterX > site.x and 1 or -1
  local pose = perched
  if now then
    local age = (now + site.salt * 1.37) % 8
    if age >= 2.7 then x, y, facing, pose = flight(site, age, x, y, facing) end
  end
  g.draw(sheet, pose, x - camX, y - camY, 0, facing, 1, 8, 8)
end

return Ponds
