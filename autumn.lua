local mod = ...
local Autumn = {}
-- Each site records the native terrain shared by the Red/Blue and Yellow maps.
Autumn.maps = {
  -- Rows 3–5 of the atlas hold red, gold and violet mushroom clusters.
  ROUTE_2 = {{2,46,0x39,3,0}, {5,8,0x39,4,3}},
  VIRIDIAN_FOREST = {{18,43,0x30,3,0}, {2,24,0x30,5,2}, {25,19,0x30,4,4}},
  PEWTER_CITY = {{13,28,0x2c,4,0}, {20,8,0x2c,5,2}},
  -- Rows 6–8 are carved harvest lanterns with different faces.
  ROUTE_3 = {{3,8,0x2c,6,0}, {29,9,0x2c,7,2}, {56,9,0x2c,8,3}},
  ROUTE_4 = {{16,6,0x39,7,0}, {87,10,0x39,6,4}},
  CERULEAN_CITY = {{22,18,0x39,6,0}, {13,29,0x2c,8,1}, {23,5,0x2c,7,4}},
  -- Pidgey foraging among autumn berries along the northern trail.
  ROUTE_24 = {{13,32,0x2c,9,0}, {8,13,0x2c,10,2}, {18,5,0x2c,11,4}},
  ROUTE_25 = {{3,8,0x39,10,1}, {22,8,0x2c,11,3}, {50,4,0x2c,9,0}},
  -- Flower offerings along the approach to Pokémon Tower.
  ROUTE_9 = {{3,8,0x2c,12,0}, {26,10,0x39,13,2}, {54,8,0x39,12,4}},
  ROUTE_10 = {{11,22,0x2c,13,0}, {12,54,0x39,12,2}, {8,70,0x39,14,4}},
  LAVENDER_TOWN = {{16,6,0x30,14,0}, {4,8,0x30,13,3}},
  -- Maple leaves turning in the open water beside the fishing piers.
  ROUTE_12 = {{13,107,0x14,15,1}, {11,81,0x14,16,3}, {13,63,0x14,15,0}, {7,39,0x14,16,2}},
  VERMILION_CITY = {{4,5,0x14,16,2}, {20,29,0x14,15,0}},
  -- Low apple branches above woven harvest baskets.
  ROUTE_13 = {{15,12,0x39,17,0}, {33,4,0x39,18,2}},
  ROUTE_14 = {{17,12,0x39,19,1}, {11,24,0x2c,17,3}, {10,40,0x2c,18,0}},
  ROUTE_15 = {{15,10,0x2c,17,0}, {39,8,0x39,18,2}, {53,12,0x39,19,4}},
  -- Paras nests in copper, golden and russet leaf litter.
  FUCHSIA_CITY = {{18,6,0x2c,20,0}, {26,28,0x39,21,2}},
  SAFARI_ZONE_CENTER = {{15,23,0x30,21,0}, {20,21,0x30,22,3}},
  SAFARI_ZONE_EAST = {{4,22,0x30,22,2}, {23,11,0x30,20,4}},
  SAFARI_ZONE_NORTH = {{20,33,0x30,20,0}, {33,6,0x30,21,2}},
  SAFARI_ZONE_WEST = {{9,14,0x30,21,3}, {5,6,0x30,22,1}},
  -- Chestnut handcarts in Saffron and on each of its four approach roads.
  ROUTE_5 = {{12,14,0x2c,27,0}, {8,10,0x2c,26,1}},
  ROUTE_6 = {{12,8,0x2c,28,1}, {7,28,0x2c,26,0}},
  ROUTE_7 = {{7,14,0x39,26,0}, {9,9,0x39,27,1}},
  ROUTE_8 = {{11,9,0x2c,28,1}, {46,9,0x2c,27,0}},
  SAFFRON_CITY = {{11,32,0x23,26,0}, {23,5,0x39,28,1}},
  -- Tiny shell boats carry autumn leaves as sails along the southern coast.
  ROUTE_19 = {{11,12,0x14,29,0}, {8,24,0x14,30,1}, {9,40,0x14,31,2}},
  ROUTE_20 = {{58,12,0x14,31,2}, {44,8,0x14,29,1}, {8,9,0x14,30,0}},
  ROUTE_21 = {{9,11,0x14,30,0}, {7,28,0x14,31,2}, {10,76,0x14,29,1}},
  CINNABAR_ISLAND = {{10,15,0x14,30,1}},
  -- Harvest wreaths mark the harbour paths and the approach to the League.
  ROUTE_11 = {{3,6,0x39,32,1}, {48,11,0x2c,32,0}},
  VERMILION_DOCK = {{16,1,0x0a,33,1}},
  ROUTE_22 = {{35,9,0x2c,32,0}, {8,8,0x2c,34,2}},
  ROUTE_23 = {{10,134,0x23,34,1}, {8,61,0x2c,32,2}, {5,33,0x2c,34,0}},
  INDIGO_PLATEAU = {{7,6,0x23,34,0}, {12,15,0x23,34,1}},
  PALLET_TOWN = {{1,6,0x2c,0,1}, {9,14,0x39,1,0}},
  ROUTE_1 = {{7,27,0x39,1,2}, {12,14,0x39,2,4}, {10,2,0x39,0,3}},
  VIRIDIAN_CITY = {{23,28,0x2c,2,0}, {22,4,0x39,1,3}},
}
-- These sites stir only after a bicycle step on the current map.
Autumn.cyclingRoutes = {
  ROUTE_16 = {{15,11,0x39,23}, {7,17,0x39,24}},
  ROUTE_17 = {{18,44,0x2c,24}, {9,62,0x39,23}, {6,87,0x39,25}, {10,139,0x39,24}},
  ROUTE_18 = {{7,5,0x39,25}, {43,6,0x39,23}},
  CELADON_CITY = {{40,14,0x39,24}, {1,18,0x39,25}},
}
for id, sites in pairs(Autumn.cyclingRoutes) do Autumn.maps[id] = sites end

local function terrainMatches(map,x,y,tile)
  local tx,ty=x*2,y*2
  return map:tileAt(tx,ty)==tile and map:tileAt(tx+1,ty)==tile
      and map:tileAt(tx,ty+1)==tile and map:tileAt(tx+1,ty+1)==tile
end

function Autumn.hasChestnutCart(map,x,y)
  local cart=Autumn.maps.ROUTE_7[1]
  return map.id=="ROUTE_7" and x==cart[1] and y==cart[2] and map.tileAt
      and terrainMatches(map,x,y,cart[3])
end

local gustStart = {}
local gustDuration = 1.8

function Autumn.ride(map,x,y)
  if mod.options:get("autumn_motion") == false then return end
  local now = love.timer.getTime()
  for _,site in ipairs(Autumn.cyclingRoutes[map.id]) do
    local dx,dy = x-site[1],y-site[2]
    if dx*dx+dy*dy <= 9 then
      local began = gustStart[site]
      if not began or now < began or now-began >= gustDuration then gustStart[site]=now end
    end
  end
end

local function cyclingPose(site,time)
  local began = gustStart[site]
  if not began then return 0 end
  local age = time and time-began
  if not age or age < 0 or age >= gustDuration then
    gustStart[site]=nil
    return 0
  end
  return 1+math.floor(age*11/gustDuration)
end

local sheets, frames = {}, {}
local function loadArt(g, wreath)
  local first, last, height, image
  if wreath then
    first, last, height = 32, 34, 96
    image = mod.assets:image("autumn_wreaths.png")
  else
    first, last, height = 0, 31, 1024
    image = mod.assets:image("autumn_leaves.png")
  end
  image:setFilter("nearest", "nearest")
  for style=first,last do
    sheets[style]=image
    frames[style]={}
    for i=0,11 do frames[style][i]=g.newQuad(i*32,(style-first)*32,32,32,384,height) end
  end
end

local function proximityPose(x,y,px,py,time,offset)
  if not px or not py then return 0 end
  local distance = math.sqrt((px - x*16)^2 + (py - y*16)^2)
  local presence = math.min(1,math.max(0,(64-distance)/48))
  local hover = time and math.sin((time+offset)*2) or 0
  return math.floor(presence*(10+hover)+0.5)
end

local function drawVisible(g, map, xCam, yCam, width, height, player, neighbor)
  g.origin()
  g.setShader()
  g.setBlendMode("alpha")
  g.setColor(1,1,1,1)
  local time = mod.options:get("autumn_motion") ~= false and love.timer.getTime()
  local px = player and (player.px or (player.cellX and player.cellX*16))
  local py = player and (player.py or (player.cellY and player.cellY*16))
  if neighbor and px and py then px,py=px-neighbor.ox,py-neighbor.oy end
  for _,site in ipairs(Autumn.maps[map.id]) do
    local x,y,tile,style,offset = site[1],site[2],site[3],site[4],site[5]
    local left,top = x*16-8-xCam,y*16-16-yCam
    if left < width and top < height and left+32 > 0 and top+32 > 0
        and terrainMatches(map,x,y,tile) then
      if not sheets[style] then loadArt(g,style >= 32) end
      local pose
      if tile == 0x14 then
        pose = time and math.floor(((time + offset) % 4) * 3) or 0
      elseif style >= 26 then
        pose = time and math.floor(((time + offset) % 3) * 4) or 0
      elseif style >= 23 then
        pose=cyclingPose(site,time)
      elseif (style >= 12 and style <= 14) or style >= 20 then
        pose=proximityPose(x,y,px,py,time,offset)
      else
        pose=time and math.floor(((time+offset)%6)*4) or 0
        if pose >= 12 then pose=0 end
      end
      g.draw(sheets[style],frames[style][pose],left,top)
    end
  end
end

local failed = false
function Autumn.draw(g,map,camX,camY,width,height,player,neighbor)
  if failed or not Autumn.maps[map.id] or not map.tileAt then return end
  g.push("all")
  local ok,err=pcall(drawVisible,g,map,math.floor(camX),math.floor(camY),width,height,player,neighbor)
  g.pop()
  if not ok then
    failed=true
    mod.log:warn("Autumn scenery could not be drawn: %s", tostring(err))
  end
end
return Autumn
