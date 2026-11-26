local mod = ...
local Winter = {maps={
  PALLET_TOWN=true, ROUTE_1=true, VIRIDIAN_CITY=true, ROUTE_2=true, VIRIDIAN_FOREST=true,
  PEWTER_CITY=true, ROUTE_3=true, ROUTE_4=true,
  CERULEAN_CITY=true, ROUTE_24=true, ROUTE_25=true,
  ROUTE_9=true, ROUTE_10=true, LAVENDER_TOWN=true,
  ROUTE_12=true, ROUTE_11=true, VERMILION_CITY=true,
  ROUTE_5=true, SAFFRON_CITY=true, ROUTE_6=true,
  ROUTE_7=true, ROUTE_8=true, CELADON_CITY=true,
  FUCHSIA_CITY=true, ROUTE_22=true, ROUTE_23=true, INDIGO_PLATEAU=true, VERMILION_DOCK=true,
  ROUTE_13=true, ROUTE_14=true, ROUTE_15=true,
}}
local safariMaps={SAFARI_ZONE_CENTER=true, SAFARI_ZONE_EAST=true,
  SAFARI_ZONE_NORTH=true, SAFARI_ZONE_WEST=true}
for id in pairs(safariMaps) do Winter.maps[id]=true end
local bankMaps={ROUTE_16=true, ROUTE_17=true, ROUTE_18=true,
  ROUTE_19=true, ROUTE_20=true, CINNABAR_ISLAND=true, ROUTE_21=true}
for id in pairs(bankMaps) do Winter.maps[id]=true end
local sheet, frames

local function loadArt(g)
  sheet = mod.assets:image("late_winter.png")
  sheet:setFilter("nearest", "nearest")
  frames = {}
  for stage=0,2 do
    frames[stage]={}
    for style=0,11 do
      frames[stage][style]=g.newQuad(style*8,stage*8,8,8,96,24)
    end
  end
end

-- Fence posts in the overworld tileset have a rail above a pair of post bases.
local function besideFence(map,x,y)
  local bottom = y % 2 == 0 and y-1 or y+2
  if bottom<1 or bottom>=map.heightCells*2 then return false end
  return map:tileAt(x,bottom)==0x55 and map:tileAt(x,bottom-1)==0x0e
end

local function grassEdge(map,x,y)
  local w,h=map.widthCells*2,map.heightCells*2
  return (x>0 and map:tileAt(x-1,y)~=0x52) or (x+1<w and map:tileAt(x+1,y)~=0x52)
      or (y>0 and map:tileAt(x,y-1)~=0x52) or (y+1<h and map:tileAt(x,y+1)~=0x52)
end

-- The clearing below the two-cell tree north-west of the southern Trainer Tips sign.
local function forestShelter(map)
  return map:tileAt(34,85)==0x36 and map:tileAt(35,85)==0x30
      and map:tileAt(34,86)==0x30 and map:tileAt(35,86)==0x30
end

-- Hand-stepped outlines keep the last patch contiguous as it shrinks.
local patchRows={
  {{1,10,8},{0,15,10},{2,14,12},{5,10,14}},
  {{2,8,8},{1,12,10},{4,10,12}},
  {{4,5,8},{3,8,10},{5,5,12}},
}
local function forestPatch(g,cx,cy,stage)
  local left,top=17*16-cx,43*16-cy-7
  for _,row in ipairs(patchRows[stage+1]) do
    g.setColor(.64,.76,.80,1)
    g.rectangle("fill",left+row[1],top+row[3],row[2],2)
    g.setColor(.88,.93,.91,1)
    g.rectangle("fill",left+row[1],top+row[3],row[2]-1,1)
  end
end

-- Recesses below a rock face and the two sides of vertical cliffs shelter snow.
local function rockEdge(map,x,y)
  return (y>0 and map:tileAt(x,y-1)==0x37)
      or (x>0 and map:tileAt(x-1,y)==0x24)
      or (x+1<map.widthCells*2 and map:tileAt(x+1,y)==0x27)
end

local function foothillSnow(map,x,y,tile,stage,seed)
  if tile~=0x23 and tile~=0x2c and tile~=0x39 and tile~=0x52 then return end
  local cellX,cellY=math.floor(x/2),math.floor(y/2)
  if not map:isWalkableCell(cellX,cellY) then return end
  if rockEdge(map,x,y) then return seed%4 end
  if stage==2 then return end
  if tile==0x23 and stage>0 then return end
  if seed < 54-stage*34 then return seed%4+(tile==0x52 and 4 or 0) end
end

-- Small icicles below the museum's front eave, on the wall above the doors.
local museumIce={{22,4},{24,7},{27,5},{30,8},{33,4}}
local function museumEave(g,map,cx,cy,x0,x1,stage)
  for _,icicle in ipairs(museumIce) do
    local tx,length=icicle[1],icicle[2]-stage*3
    if length>0 and tx>=x0 and tx<=x1 and map:tileAt(tx,10)==0x17 and map:tileAt(tx,11)==0x22 then
      local x,y=tx*8+2-cx,11*8-cy
      g.setColor(.65,.81,.88,1)
      g.rectangle("fill",x,y,3,math.min(length,3))
      g.rectangle("fill",x+1,y,1,length)
      g.setColor(.92,.97,.98,1)
      g.rectangle("fill",x,y,2,1)
    end
  end
end

-- Frost follows the outside planks of Nugget Bridge on both connected maps.
local function riversideSnow(map,x,y,tile,stage,seed)
  if tile==0x3c then
    if map.id=="ROUTE_25" then return end
    local left = x>0 and map:tileAt(x-1,y)
    local right = x+1<map.widthCells*2 and map:tileAt(x+1,y)
    if left==0x2b or left==0x3b or right==0x2a or right==0x3a then
      if y%8 < 7-stage*2 then return 8+(y%4) end
    end
    return
  end
  if tile~=0x23 and tile~=0x2c and tile~=0x39 and tile~=0x52 then return end
  if not map:isWalkableCell(math.floor(x/2),math.floor(y/2)) then return end
  -- The strip of garden below the fence west of Bill's cottage.
  if map.id=="ROUTE_25" and x>=80 and x<=83 and y==8
      and map:tileAt(x,y-1)==0x55 and map:tileAt(x,y-2)==0x0e then
    if x<=83-stage then return x%4 end
  end
  if stage==2 or (stage==1 and tile==0x23) then return end
  if seed<56-stage*31 then return seed%4+(tile==0x52 and 4 or 0) end
end

-- Two strips of snow below the raised ground at Pokémon Tower's entrance.
local function lavenderSnow(map,x,y,tile,stage,seed)
  if tile~=0x30 and tile~=0x39 and tile~=0x2c and tile~=0x23 then return end
  if not map:isWalkableCell(math.floor(x/2),math.floor(y/2)) then return end
  if y==12 and map:tileAt(x,y-1)==0x37 then
    if (x>=24+stage and x<=27) or (x>=30 and x<=33-stage) then return x%4 end
  end
  if stage==2 or (stage==1 and (tile==0x23 or tile==0x30)) then return end
  if seed<55-stage*30 then return seed%4 end
end

-- Trace the plank edge against open water. The surviving streaks get shorter
-- at each thaw and stay anchored to the same planks while the camera moves.
local function pierSnow(map,x,y,tile,stage,seed)
  if tile==0x3c then
    if not map:isWalkableCell(math.floor(x/2),math.floor(y/2)) then return end
    local w,h=map.widthCells*2,map.heightCells*2
    local length=7-stage*2
    if y%8<length and ((x>0 and map:tileAt(x-1,y)==0x14)
        or (x+1<w and map:tileAt(x+1,y)==0x14)) then return 8+y%4 end
    if x%8<length and ((y>0 and map:tileAt(x,y-1)==0x14)
        or (y+1<h and map:tileAt(x,y+1)==0x14)) then return 8+x%4 end
    return
  end
  if stage==2 or (tile~=0x23 and tile~=0x2c and tile~=0x39 and tile~=0x52) then return end
  if stage==1 and tile==0x23 then return end
  if seed<54-stage*32 and map:isWalkableCell(math.floor(x/2),math.floor(y/2)) then
    return seed%4+(tile==0x52 and 4 or 0)
  end
end

-- On the road through Saffron, snow retreats to the foot of building corners.
local function streetSnow(map,x,y,tile,stage,seed)
  if tile~=0x20 and tile~=0x23 and tile~=0x2c and tile~=0x39 and tile~=0x52 then return end
  local cx,cy=math.floor(x/2),math.floor(y/2)
  if not map:isWalkableCell(cx,cy) then return end
  if cy>0 then
    local wall=map:tileAt(x,cy*2-1)
    if wall==0x1b or wall==0x1c then return end
    if y%2==0 then
      if wall==0x4e or wall==0x4f then return x%4 end
      if wall==0x1a and (stage==0 or (stage==1 and x%2==0)) then return x%4 end
    end
  end
  if stage==2 or (stage==1 and (tile==0x20 or tile==0x23)) then return end
  if seed<53-stage*29 then return seed%4+(tile==0x52 and 4 or 0) end
end

-- Trace banks against live water tiles on Cycling Road and the southern coast.
local function bankSnow(map,x,y,tile,stage,seed)
  local length=6-stage*2
  if tile==0x32 and x+1<map.widthCells*2 and map:tileAt(x+1,y)==0x14
      or tile==0x54 and x>0 and map:tileAt(x-1,y)==0x14 then
    if y%6<length then return 8+y%4 end
    return
  end
  -- At the Route 19 beach the sand meets the water directly. In Yellow
  -- this shore lies two cells farther south than in Red and Blue.
  local beach=map.id=="ROUTE_19" and tile==0x39
  if (tile==0x33 or beach) and y+1<map.heightCells*2 and map:tileAt(x,y+1)==0x14 then
    if x%6<length then return 8+x%4 end
    return
  end
  if stage==2 or (tile~=0x2c and tile~=0x39 and tile~=0x52) then return end
  if stage==1 and tile==0x39 then return end
  if seed<54-stage*30 and map:isWalkableCell(math.floor(x/2),math.floor(y/2)) then
    return seed%4+(tile==0x52 and 4 or 0)
  end
end

-- Forest tileset roof ridges have distinct end caps and a matching row below.
local function safariRidge(map,x,y,tile,stage)
  if tile~=0x08 and tile~=0x09 and tile~=0x0c then return end
  if y+1>=map.heightCells*2 or map:tileAt(x,y+1)~=tile+0x10 then return end
  if stage==0 or tile~=0x09 then return 8+x%4 end
  if stage==1 and ((x>0 and map:tileAt(x-1,y)==0x08)
      or (x+1<map.widthCells*2 and map:tileAt(x+1,y)==0x0c)) then return 8+x%4 end
end

-- Snow settles on the ground below the fence maze and the low ledges.
local function trailSnow(map,x,y,tile,stage,seed)
  if tile~=0x23 and tile~=0x2c and tile~=0x39 and tile~=0x52 then return end
  if not map:isWalkableCell(math.floor(x/2),math.floor(y/2)) then return end
  if y>0 and y%2==0 and (besideFence(map,x,y) or map:tileAt(x,y-1)==0x37) then
    if x%8 < 8-stage*3 then return seed%4 end
    return
  end
  if stage==2 or (stage==1 and tile~=0x52) then return end
  if seed<56-stage*32 then return seed%4+(tile==0x52 and 4 or 0) end
end

-- Pale drifts collect below the stone walls along the League approach.
local function plateauSnow(map,x,y,tile,stage,seed)
  if tile~=0x23 and tile~=0x2c and tile~=0x2d and tile~=0x45 then return end
  local cx,cy=math.floor(x/2),math.floor(y/2)
  if not map:isWalkableCell(cx,cy) then return end
  if cy>0 then
    local wall=map:tileAt(x,cy*2-1)
    if wall==0x1b or wall==0x1c then return end
    if y%2==0 and wall==0x0e then
      if x%3 < 3-stage then return x%4 end
      return
    end
  end
  if stage<2 and seed<50-stage*30 then return seed%4+(tile==0x45 and 4 or 0) end
end

-- Fixed quay north of the S.S. Anne, including the thin lip above the water.
local function quaySnow(map,x,y,tile,stage,seed)
  if y>4 then return end
  if tile==0x3a and map:tileAt(x,y+1)==0x14 then
    if x%6 < 6-stage*2 then return 8+x%4 end
  elseif tile==0x0a and stage<2 and seed<50-stage*30 then
    return seed%4
  end
end

local pondEndWidths={4,3,1}

local function snowTile(map,x,y,stage)
  local tile = map:tileAt(x,y)
  local seed = (x*17 + y*31 + x*y*3) % 101
  if map.id=="CERULEAN_CITY" or map.id=="ROUTE_24" or map.id=="ROUTE_25" then
    return riversideSnow(map,x,y,tile,stage,seed)
  elseif map.id=="ROUTE_12" or map.id=="VERMILION_CITY" then
    return pierSnow(map,x,y,tile,stage,seed)
  elseif bankMaps[map.id] then
    return bankSnow(map,x,y,tile,stage,seed)
  elseif map.id=="ROUTE_13" or map.id=="ROUTE_14" or map.id=="ROUTE_15" then
    return trailSnow(map,x,y,tile,stage,seed)
  elseif map.id=="ROUTE_23" or map.id=="INDIGO_PLATEAU" then
    return plateauSnow(map,x,y,tile,stage,seed)
  elseif map.id=="VERMILION_DOCK" then
    return quaySnow(map,x,y,tile,stage,seed)
  elseif map.id=="CELADON_CITY" then
    -- The north lip of the pond west of Game Corner. The middle thaws first.
    if y==36 and x>=42 and x<=49 and tile==0x33 and map:tileAt(x,y+1)==0x14 then
      local distance=math.min(x-42,49-x)
      if distance < pondEndWidths[stage+1] then return 8+x%4 end
      return
    end
    return streetSnow(map,x,y,tile,stage,seed)
  elseif map.id=="ROUTE_5" or map.id=="ROUTE_6" or map.id=="SAFFRON_CITY"
      or map.id=="ROUTE_7" or map.id=="ROUTE_8" or map.id=="FUCHSIA_CITY" then
    return streetSnow(map,x,y,tile,stage,seed)
  elseif map.id=="LAVENDER_TOWN" then
    return lavenderSnow(map,x,y,tile,stage,seed)
  elseif map.id=="ROUTE_3" or map.id=="ROUTE_4" or map.id=="ROUTE_9" or map.id=="ROUTE_10" or map.id=="ROUTE_11" or map.id=="ROUTE_22" then
    return foothillSnow(map,x,y,tile,stage,seed)
  elseif map.id=="PEWTER_CITY" then
    if tile~=0x23 and tile~=0x2c and tile~=0x39 and tile~=0x52 then return end
    if stage==2 or (stage==1 and tile==0x23) then return end
    if seed<55-stage*29 and map:isWalkableCell(math.floor(x/2),math.floor(y/2)) then
      return seed%4+(tile==0x52 and 4 or 0)
    end
    return
  elseif map.id=="VIRIDIAN_CITY" then
    if tile~=0x2c and tile~=0x39 and tile~=0x23 then return end
    if besideFence(map,x,y) then return seed%4 end
    if stage>0 then return end
  elseif map.id=="VIRIDIAN_FOREST" or safariMaps[map.id] then
    if safariMaps[map.id] then
      local ridge=safariRidge(map,x,y,tile,stage)
      if ridge then return ridge end
      if tile==0x30 and math.floor(y/2)>0 then
        local wall=map:tileAt(x,2*math.floor(y/2)-1)
        if wall==0x3a or wall==0x3b then return end
      end
    end
    if stage==2 or (tile~=0x20 and tile~=0x34 and tile~=0x30) then return end
    if not map:isWalkableCell(math.floor(x/2),math.floor(y/2)) then return end
    if stage==1 and (tile==0x30 or seed>35) then return end
    if seed<65 then return seed%4 + (tile==0x30 and 0 or 4) end
    return
  elseif map.id=="ROUTE_2" and tile==0x52 and stage>0 and grassEdge(map,x,y) then
    return
  end
  -- The ridge and the eave of Oak's Lab. Check the live roof before painting.
  if map.id=="PALLET_TOWN" and x>=22 and x<=29 then
    if (y==16 and tile==0x53) or (y==19 and tile==0x17) then
      if stage==2 and (x==24 or x>=27) then return end
      return 8+(x%4)
    end
  end
  -- Leave signs, water, flowers and buildings clear. Grass tips keep their shape.
  if tile~=0x2c and tile~=0x39 and tile~=0x52 and not (map.id=="VIRIDIAN_CITY" and tile==0x23) then return end
  local drift = (math.floor(x/3)*11 + math.floor(y/2)*7) % 17
  if drift>=13-stage*4 or seed>=84-stage*16 then return end
  return seed%4 + (tile==0x52 and 4 or 0)
end

local function drawVisible(g,map,cx,cy,w,h,stage)
  g.origin()
  g.setShader()
  g.setBlendMode("alpha")
  g.setColor(1,1,1,1)
  local x0,x1=math.max(0,math.floor(cx/8)),math.min(map.widthCells*2-1,math.floor((cx+w-1)/8))
  local y0,y1=math.max(0,math.floor(cy/8)),math.min(map.heightCells*2-1,math.floor((cy+h-1)/8))
  for y=y0,y1 do
    for x=x0,x1 do
      local style=snowTile(map,x,y,stage)
      if style then
        if not sheet then loadArt(g) end
        g.draw(sheet,frames[stage][style],8*x-cx,8*y-cy)
      end
    end
  end
  if map.id=="PEWTER_CITY" and y0<=11 and y1>=11 then museumEave(g,map,cx,cy,x0,x1,stage) end
  if map.id=="VIRIDIAN_FOREST" and x0<=35 and x1>=34 and y0<=87 and y1>=86 and forestShelter(map) then
    forestPatch(g,cx,cy,stage)
  end
end

local failed=false
function Winter.draw(g,map,cx,cy,w,h,stage)
  if failed or not map.tileAt or not map.widthCells or not map.heightCells then return end
  g.push("all")
  local ok,err=pcall(drawVisible,g,map,math.floor(cx),math.floor(cy),w,h,stage)
  g.pop()
  if not ok then
    failed=true
    mod.log:warn("Late winter scenery could not be drawn: %s",tostring(err))
  end
end
return Winter
