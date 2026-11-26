local mod = ...
local Fireflies = {}

-- Each fern is rooted on one native cell. The phase offsets stagger nearby colonies.
Fireflies.sites = {
  ROUTE_1 = {salt = 36,
    {x=8,  y=34,  ground=0x2c, fern=0, phase=1.6}, -- Pallet approach
    {x=7,  y=27,  ground=0x39, fern=1, phase=0.4}, -- two cells west of the sign
    {x=12, y=14,  ground=0x39, fern=0, phase=3.8},
  },
  ROUTE_22 = {salt = 37,
    {x=35, y=9,   ground=0x2c, fern=1, phase=2.3}, -- Viridian approach
    {x=8,  y=8,   ground=0x2c, fern=0, phase=5.0}, -- League gate
  },
  ROUTE_23 = {salt = 38,
    {x=10, y=134, ground=0x23, fern=2, phase=1.0}, -- first badge guard
    {x=8,  y=61,  ground=0x2c, fern=0, phase=4.5},
    {x=5,  y=33,  ground=0x2c, fern=1, phase=2.9}, -- Victory Road entrance
  },
  INDIGO_PLATEAU = {salt = 39,
    {x=7,  y=6,   ground=0x23, fern=2, phase=0.0}, -- west of the League doors
    {x=12, y=15,  ground=0x23, fern=2, phase=3.3}, -- eastern side of the approach
  },
}

local sheet, ferns, lights
local function loadArt(g)
  sheet = mod.assets:image("summer_fireflies.png")
  sheet:setFilter("nearest", "nearest")
  ferns, lights = {}, {}
  for i = 0, 2 do ferns[i] = g.newQuad(i * 16, 0, 16, 16, 112, 48) end
  for color = 0, 1 do
    lights[color] = {}
    for glow = 0, 6 do lights[color][glow] = g.newQuad(glow * 16, (1 + color) * 16, 16, 16, 112, 48) end
  end
end

local function dusk(date)
  if mod.options:get("mode") == "summer" then return 1 end
  if not date or type(date.hour) ~= "number" then return 0 end
  local hour = date.hour + (date.min or 0) / 60
  if hour < 6 then return math.min(1, (6 - hour) / 2) end
  return math.min(1, math.max(0, (hour - 18) / 2))
end

local function grounded(map, site)
  local x, y, t = site.x * 2, site.y * 2, site.ground
  return map:tileAt(x, y) == t and map:tileAt(x + 1, y) == t
     and map:tileAt(x, y + 1) == t and map:tileAt(x + 1, y + 1) == t
end

local function playerPosition(player, neighbor)
  if not player then return end
  local x = player.px or (player.cellX and player.cellX * 16)
  local y = player.py or (player.cellY and player.cellY * 16)
  if x and y then return x - (neighbor and neighbor.ox or 0), y - (neighbor and neighbor.oy or 0) end
end

local flies = {
  {x=3,  y=9,  offset=0.00, height=12, color=0},
  {x=8,  y=5,  offset=0.35, height=15, color=1},
  {x=13, y=10, offset=0.70, height=11, color=0},
}
local tau = 2 * math.pi
local function round(v) return math.floor(v + 0.5) end

function Fireflies.draw(g, map, sites, camX, camY, x0, y0, x1, y1, now, date, player, neighbor)
  local twilight = dusk(date)
  local px, py = playerPosition(player, neighbor)
  for _, site in ipairs(sites) do
    if site.x + 1 >= x0 and site.x - 1 <= x1 and site.y >= y0
        and site.y - 2 <= y1 and grounded(map, site) then
      if not sheet then loadArt(g) end
      local wx, wy = site.x * 16, site.y * 16
      local x, y = wx - camX, wy - camY
      g.setColor(1, 1, 1, 1)
      g.draw(sheet, ferns[site.fern], x, y)
      local near = 0
      if now and twilight > 0 and px and py then
        local distance = math.sqrt((px - wx)^2 + (py - wy)^2)
        near = math.max(0, math.min(1, (64 - distance) / 48))
      end
      for _, fly in ipairs(flies) do
        local dx, dy, glow = 0, 0, 4 * twilight
        if now and twilight > 0 then
          local angle = tau * (((now + site.phase) / 6.8 + fly.offset) % 1)
          local arc = (1 - math.cos(angle)) * 0.5
          dy = -round(twilight * arc * (4 + near * fly.height))
          dx = round(twilight * arc * (2 + 5 * near) * math.sin(angle * 2 + fly.offset * tau))
          glow = twilight * (2 + 2 * (1 - math.cos(angle + 0.6)))
        end
        g.draw(sheet, lights[fly.color][round(glow)], x + fly.x + dx - 8, y + fly.y + dy - 8)
      end
    end
  end
end

return Fireflies
