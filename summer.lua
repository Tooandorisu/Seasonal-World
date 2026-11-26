local mod = ...
local Ponds = assert(load(mod:read("summer_ponds.lua"), "@seasonal_world/summer_ponds.lua"))(mod)
local Grass = assert(load(mod:read("summer_grass.lua"), "@seasonal_world/summer_grass.lua"))(mod)
local Pennants = assert(load(mod:read("summer_pennants.lua"), "@seasonal_world/summer_pennants.lua"))(mod)
local Butterflies = assert(load(mod:read("summer_butterflies.lua"), "@seasonal_world/summer_butterflies.lua"))(mod)
local Picnics = assert(load(mod:read("summer_picnics.lua"), "@seasonal_world/summer_picnics.lua"))(mod)
local Kites = assert(load(mod:read("summer_kites.lua"), "@seasonal_world/summer_kites.lua"))(mod)
local Fireflies = assert(load(mod:read("summer_fireflies.lua"), "@seasonal_world/summer_fireflies.lua"))(mod)
local Summer = {
  fireflySites = Fireflies.sites,
  spinPicnicWheel = Picnics.spin,
  kiteRoutes = Kites.routes,
  ridePastKites = Kites.ride,
  -- Each stretch of water has its own glint pattern in map-local coordinates.
  maps = {PALLET_TOWN = 1, ROUTE_21 = 2, CINNABAR_ISLAND = 3, ROUTE_20 = 4, ROUTE_19 = 5},
}
for id, site in pairs(Ponds.sites) do Summer.maps[id] = site.salt end
for id, spots in pairs(Ponds.fishingSpots) do Summer.maps[id] = spots.salt end
for id, route in pairs(Grass.routes) do Summer.maps[id] = route.salt end
for id, street in pairs(Pennants.streets) do Summer.maps[id] = street.salt end
for id, patches in pairs(Butterflies.meadows) do Summer.maps[id] = patches.salt end
for id, sites in pairs(Picnics.sites) do Summer.maps[id] = sites.salt end
for id, sites in pairs(Kites.routes) do Summer.maps[id] = sites.salt end
for id, sites in pairs(Fireflies.sites) do Summer.maps[id] = sites.salt end

local stands = {
  ROUTE_5 = {{12,21,0x39,0,0}, {16,28,0x39,1,2}},
  ROUTE_11 = {{3,6,0x39,1,1}, {48,11,0x2c,0,4}},
  VERMILION_DOCK = {{16,1,0x0a,2,3}},
}
Summer.maps.ROUTE_5, Summer.maps.ROUTE_11, Summer.maps.VERMILION_DOCK = 40, 41, 42

local standSheet, standFrames
local function drawStands(g, map, sites, camX, camY, x0, y0, x1, y1, now)
  for _, site in ipairs(sites) do
    local x, y, tile, color, offset = site[1], site[2], site[3], site[4], site[5]
    local tx, ty = x * 2, y * 2
    if x + 1 >= x0 and x - 1 <= x1 and y >= y0 and y - 1 <= y1
        and map:tileAt(tx, ty) == tile and map:tileAt(tx+1, ty) == tile
        and map:tileAt(tx, ty+1) == tile and map:tileAt(tx+1, ty+1) == tile then
      if not standSheet then
        standSheet = mod.assets:image("summer_lemonade.png")
        standSheet:setFilter("nearest", "nearest")
        standFrames = {}
        for row = 0, 2 do
          standFrames[row] = {}
          for col = 0, 5 do standFrames[row][col] = g.newQuad(col*24, row*24, 24, 24, 144, 72) end
        end
      end
      local frame = now and math.floor(now * 2 + offset) % 6 or 0
      g.setColor(1, 1, 1, 1)
      g.draw(standSheet, standFrames[color][frame], x*16 - 4 - camX, y*16 - 8 - camY)
    end
  end
end

local plants = {{3, 4}, {10, 12}, {15, 12}, {16, 14}, {9, 15}}
local sheet, upright, leaning, towel
local failed = false

local function loadArt(g)
  sheet = mod.assets:image("summer_details.png")
  sheet:setFilter("nearest", "nearest")
  upright = g.newQuad(0, 0, 16, 16, 48, 16)
  leaning = g.newQuad(16, 0, 16, 16, 48, 16)
  towel = g.newQuad(32, 0, 16, 16, 48, 16)
end

local function onOpenGround(map, x, y)
  local tx, ty = x * 2, y * 2
  return map:tileAt(tx, ty) == 0x39 and map:tileAt(tx + 1, ty) == 0x39
     and map:tileAt(tx, ty + 1) == 0x39 and map:tileAt(tx + 1, ty + 1) == 0x39
end

local function drawLandmarks(g, map, camX, camY, x0, y0, x1, y1, now)
  if map.id ~= "PALLET_TOWN" and map.id ~= "ROUTE_19" then return end
  if not sheet then loadArt(g) end
  g.setColor(1, 1, 1, 1)
  if map.id == "PALLET_TOWN" then
    for _, plant in ipairs(plants) do
      local x, y = plant[1], plant[2]
      if x >= x0 and x <= x1 and y >= y0 and y <= y1 and onOpenGround(map, x, y) then
        local inBreeze = now and (now - x * 0.16 - y * 0.08) % 4.8 < 1.25
        g.draw(sheet, inBreeze and leaning or upright, x * 16 - camX, y * 16 - camY)
      end
    end
  else
    -- The sand reaches row 9 in Red/Blue and row 11 in Yellow.
    local x = 9
    if x < x0 or x > x1 then return end
    for y = 9, 11, 2 do
      if y >= y0 and y <= y1 and onOpenGround(map, x, y)
          and map:tileAt(x * 2, (y + 1) * 2) == 0x14 then
        g.draw(sheet, towel, x * 16 - camX, y * 16 - camY)
        return
      end
    end
  end
end

local function drawGlints(g, map, camX, camY, x0, y0, x1, y1, now)
  -- One possible reflection per 32px square. Its whole shape fits on one live water tile.
  local salt = Summer.maps[map.id]
  for row = math.floor(y0 / 2), math.floor(y1 / 2) do
    for col = math.floor(x0 / 2), math.floor(x1 / 2) do
      local seed = (col * 17 + row * 31 + col * row * 7 + salt * 19) % 97
      local age = (now + seed * 0.157) % 5.8
      if age < 1.6 then
        local tx = col * 4 + seed % 4
        local ty = row * 4 + math.floor(seed / 4) % 4
        if tx >= x0 * 2 and tx <= x1 * 2 + 1 and ty >= y0 * 2 and ty <= y1 * 2 + 1
            and map:tileAt(tx, ty) == 0x14 then
          local light = math.sin(math.pi * age / 1.6) ^ 2
          local x, y = tx * 8 + 4 - camX, ty * 8 + 4 - camY
          g.setColor(0.72, 0.92, 1, 0.60 * light)
          g.rectangle("fill", x - 2, y, 5, 1)
          g.setColor(1, 0.98, 0.81, 0.90 * light)
          g.rectangle("fill", x - 1, y, 3, 1)
          if light > 0.55 then
            g.setColor(1, 0.98, 0.81, (light - 0.55) * 1.8)
            g.rectangle("fill", x, y - 1, 1, 3)
          end
        end
      end
    end
  end
end

local function drawVisible(g, map, camX, camY, x0, y0, x1, y1, casting, date, player, neighbor)
  g.origin()
  g.setShader()
  g.setBlendMode("alpha")
  local now
  if mod.options:get("summer_motion") ~= false then
    now = love.timer.getTime()
    drawGlints(g, map, camX, camY, x0, y0, x1, y1, now)
  end
  drawLandmarks(g, map, camX, camY, x0, y0, x1, y1, now)
  if stands[map.id] then drawStands(g, map, stands[map.id], camX, camY, x0, y0, x1, y1, now) end
  local pond = Ponds.sites[map.id]
  if pond then Ponds.draw(g, map, pond, camX, camY, x0, y0, x1, y1, now) end
  local spots = Ponds.fishingSpots[map.id]
  if spots and not casting then Ponds.drawFloats(g, map, spots, camX, camY, x0, y0, x1, y1, now) end
  local route = Grass.routes[map.id]
  if route then Grass.draw(g, map, route, camX, camY, x0, y0, x1, y1, now) end
  local street = Pennants.streets[map.id]
  if street then Pennants.draw(g, map, street, camX, camY, x0, y0, x1, y1, now) end
  local patches = Butterflies.meadows[map.id]
  if patches then Butterflies.draw(g, map, patches, camX, camY, x0, y0, x1, y1, now) end
  local picnics = Picnics.sites[map.id]
  if picnics then Picnics.draw(g, map, picnics, camX, camY, x0, y0, x1, y1, now) end
  local kites = Kites.routes[map.id]
  if kites then Kites.draw(g, map, kites, camX, camY, x0, y0, x1, y1, now) end
  local ferns = Fireflies.sites[map.id]
  if ferns then Fireflies.draw(g, map, ferns, camX, camY, x0, y0, x1, y1, now, date, player, neighbor) end
end

function Summer.draw(g, map, camX, camY, width, height, casting, date, player, neighbor)
  if failed or not Summer.maps[map.id] or not map.tileAt then return end
  camX, camY = math.floor(camX), math.floor(camY)
  local x0, y0 = math.max(0, math.floor(camX / 16)), math.max(0, math.floor(camY / 16))
  local x1 = math.min(map.widthCells - 1, math.floor((camX + width - 1) / 16))
  local y1 = math.min(map.heightCells - 1, math.floor((camY + height - 1) / 16))
  if x0 > x1 or y0 > y1 then return end
  g.push("all")
  local ok, err = pcall(drawVisible, g, map, camX, camY, x0, y0, x1, y1, casting == true, date, player, neighbor)
  g.pop()
  if not ok then
    failed = true
    mod.log:warn("Summer scenery could not be drawn: %s", tostring(err))
  end
end

return Summer
