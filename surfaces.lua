-- Small snow caps on fixed stone scenery and native wooden fence posts.
local Surfaces = {}
local buildings = {
  PALLET_TOWN={{64,32,64,64},{192,32,64,64},{160,128,96,64}},
  LAVENDER_TOWN={{32,32,64,64},{192,0,96,64},{224,80,16,16},
    {96,128,64,32},{224,160,64,64},{32,192,64,32},{96,192,64,32}},
  VERMILION_CITY={{96,0,64,64},{160,0,64,64},{224,0,64,64},{320,0,64,64},
    {128,160,64,64},{224,160,64,64},{352,160,64,64},
    {128,256,96,64},{352,256,64,64}},
  CERULEAN_CITY={{128,160,96,32},{224,160,96,32},{416,160,96,32},{544,160,96,32},
    {192,224,96,32},{288,224,64,64},{384,256,128,64},
    {192,352,64,64},{384,352,64,64},{288,384,96,32},{448,384,96,32}},
  PEWTER_CITY={{160,32,128,96},{288,32,96,64},{448,192,64,32},
    {192,224,96,64},{352,224,64,64},{192,352,64,64},{96,448,64,32}},
  VIRIDIAN_CITY={{320,128,64,32},{320,224,64,32},{352,352,64,64},
    {448,256,64,64},{448,64,96,64}},
}
-- Only flat wooden decks, not the vertical mooring faces beneath them.
local deckAreas={
  CERULEAN_CITY={{320,0,32,64}},
  CELADON_CITY={{352,256,32,32}},
  VERMILION_CITY={{480,256,32,192},{288,416,224,32},{288,448,32,128}},
}
-- PLATEAU atlas: wall lip, paired column tops, and the lower half of
-- their cap. The brown vertical masonry uses different tiles.
local indigoTrim={[0x0d]=true,[0x20]=true,[0x21]=true,[0x2e]=true,[0x2f]=true}
local function buildingAt(map,x,y,extra)
  for _,r in ipairs(extra or {}) do
    if x>=r[1] and y>=r[2] and x<r[1]+r[3] and y<r[2]+r[4] then return true end
  end
  for _,r in ipairs(buildings[map.id] or {}) do
    if x>=r[1] and y>=r[2] and x<r[1]+r[3] and y<r[2]+r[4] then return true end
  end
  return false
end

function Surfaces.regions(map,camX,camY,w,h,protect,skipOutside)
  if type(map.tileAt)~="function" or type(map.isWalkableCell)~="function" then return {},{},{},{} end
  local blocks=map.tileset and map.tileset.blocks
  local route23=map.id=="ROUTE_23"
  local route22=map.id=="ROUTE_22"
  local route2=map.id=="ROUTE_2"
  local routeWithGate=map.id=="ROUTE_5" or map.id=="ROUTE_6" or map.id=="ROUTE_7" or map.id=="ROUTE_16" or map.id=="ROUTE_18"
  local route10=map.id=="ROUTE_10"
  local route12=map.id=="ROUTE_12"
  local route13=map.id=="ROUTE_13"
  local cyclingRoad=map.id=="ROUTE_17"
  local seaRoute=map.id=="ROUTE_19" or map.id=="ROUTE_20" or map.id=="ROUTE_21"
  local nuggetBridge=map.id=="ROUTE_24"
  local route25=map.id=="ROUTE_25"
  local coastalPaving=map.id=="ROUTE_14" or map.id=="ROUTE_15" or route25
  local openDeck=route12 or route13 or map.id=="ROUTE_20" or map.id=="ROUTE_21" or nuggetBridge or route25
  local mountainRoute=map.id=="ROUTE_3" or map.id=="ROUTE_4" or map.id=="ROUTE_8" or map.id=="ROUTE_9"
    or route10 or map.id=="ROUTE_11" or route25
  local safari=(map.id or ""):match("^SAFARI_ZONE_")~=nil
  local forest=map.id=="VIRIDIAN_FOREST" or safari
  local plateauAtlas=map.id=="INDIGO_PLATEAU" or route23
  local fence=not plateauAtlas and not forest and blocks and blocks[0x77+1]
  local stoneTops={}
  if plateauAtlas and blocks then
    -- PLATEAU has its own atlas. Only cap the statue heads and the
    -- exposed column tops, so tall masonry keeps its continuous face.
    for _,source in ipairs({{0x43,1,2},{0x42,3,4},{0x29,9,10}}) do
      local block=blocks[source[1]+1]
      if block then
        for i=source[2],source[3] do
          if block[i] then stoneTops[block[i]]=true end
        end
      end
    end
  end
  local fenceIds={}
  local cliffIds={}
  -- Block $2C is the repeating flat brown plateau surface in supported cities.
  -- Select its live tile IDs, not neighbouring vertical cliff-face tiles.
  local plateau=(route22 or mountainRoute or route12 or seaRoute or nuggetBridge or map.id=="VIRIDIAN_CITY" or map.id=="PEWTER_CITY" or map.id=="CERULEAN_CITY" or map.id=="LAVENDER_TOWN" or map.id=="FUCHSIA_CITY") and blocks and blocks[0x2c+1]
  for _,id in ipairs(plateau or {}) do cliffIds[id]=true end
  -- Cerulean's private courtyards are flat paving, not vertical walls.
  local paving=(route22 or route2 or route10 or coastalPaving or map.id=="CERULEAN_CITY" or map.id=="CELADON_CITY" or map.id=="FUCHSIA_CITY" or map.id=="SAFFRON_CITY") and blocks and blocks[0x55+1]
  local pavingIds={}
  for _,id in ipairs(paving or {}) do cliffIds[id]=true; pavingIds[id]=true end
  local entryIds={}
  local entry=map.id=="VERMILION_CITY" and blocks and blocks[0x05+1]
  for _,i in ipairs({5,7}) do if entry and entry[i] then entryIds[entry[i]]=true end end
  local bridgeIds={}
  local bridge=(openDeck or deckAreas[map.id]) and blocks and blocks[0x54+1]
  for _,id in ipairs(bridge or {}) do bridgeIds[id]=true end
  -- The lower half of block $77 contains the fence; this row is each post's
  -- upper 8px tile. Vertical fences use the same live atlas tiles.
  for i=9,12 do if fence and fence[i]~=nil then fenceIds[fence[i]]=true end end
  local treeIds={}
  for _,id in ipairs((blocks and blocks[0x0f+1]) or {}) do treeIds[id]=true end
  local fences,stones,cliffs,trim={},{},{},{}
  local maxX,maxY=(map.widthCells or 0)*2-1,(map.heightCells or 0)*2-1
  for ty=math.floor(camY/8),math.floor((camY+h-1)/8) do
    for tx=math.floor(camX/8),math.floor((camX+w-1)/8) do
      local x,y=tx*8,ty*8
      local outside=tx<0 or ty<0 or tx>maxX or ty>maxY
      local cx,cy=math.floor(tx/2),math.floor(ty/2)
      local tile=(not outside or (not skipOutside and (route22 or mountainRoute or map.id=="LAVENDER_TOWN"))) and map:tileAt(tx,ty)
      -- Flat courtyard back-door tiles may receive cosmetic snow; do not
      -- exempt actual building faces, other warp tiles, signs or water.
      local deck=false
      local entryMark=tile and entryIds[tile] and x>=288 and x<320 and y>=512 and y<544
      if tile and (bridgeIds[tile] or entryMark) then
        deck=openDeck and not outside
        for _,r in ipairs(deckAreas[map.id] or {}) do
          if x>=r[1] and x<r[1]+r[3] and y>=r[2] and y<r[2]+r[4] then deck=true; break end
        end
      end
      local pavedEntrance=(tile and pavingIds[tile]) or deck
      -- The Safari exits share the same plain path tile as the interior.
      local safariPath=safari and tile==0x30
      -- The inaccessible original sign at (15,23) sits on flat plateau
      -- tiles. Recolour only that native flat surface, never a sign graphic.
      local flatSignFloor=map.id=="FUCHSIA_CITY" and cx==15 and cy==23 and tile and cliffIds[tile]
      local safe=outside or (not (map.isWaterCell and map:isWaterCell(cx,cy))
        and not (map.signAtCell and map:signAtCell(cx,cy) and not flatSignFloor)
        and not (map.warpAtCell and map:warpAtCell(cx,cy) and not (pavedEntrance or safariPath)))
      if safe and not (outside and skipOutside) and not buildingAt(map,x,y,protect) then
        local solid=outside or not map:isWalkableCell(cx,cy)
        local leafy=tile and treeIds[tile]
        local bush=map.cellTile and map:cellTile(cx,cy)==0x3d
        local grass=map.isGrassCell and map:isGrassCell(cx,cy)
        -- Route 23 also has wide, stippled terrace tops ($03). Use
        -- colour-only snow so their pattern survives at the map seam.
        if safari and tile==0x2e then
          -- Safari terraces use a different tile from OVERWORLD plateaus.
          cliffs[#cliffs+1]={x,y,8,8}
          trim[#trim+1]={x,y,8,8}
        elseif safari and not outside and not grass then
          -- Recolour the ground in mixed tiles beside posts and cliff corners.
          trim[#trim+1]={x,y,8,8}
        elseif plateauAtlas and tile and (indigoTrim[tile] or (route23 and tile==0x03)) then
          trim[#trim+1]={x,y,8,8}
        elseif cyclingRoad and not outside and not leafy and not bush and not grass then
          trim[#trim+1]={x,y,8,8}
        elseif (route22 or route2 or routeWithGate or mountainRoute or route13 or seaRoute or nuggetBridge or coastalPaving or map.id=="ROUTE_1" or map.id=="CERULEAN_CITY" or map.id=="VERMILION_CITY" or map.id=="LAVENDER_TOWN" or map.id=="CELADON_CITY" or map.id=="FUCHSIA_CITY" or map.id=="SAFFRON_CITY" or map.id=="CINNABAR_ISLAND") and not outside and not leafy and not bush and not grass
            and (solid or (tile and (fenceIds[tile] or cliffIds[tile]))) then
          trim[#trim+1]={x,y,8,8}
        end
        if tile and (cliffIds[tile] or deck) then
          cliffs[#cliffs+1]={x,y,8,8}
        elseif tile and fenceIds[tile] then
          fences[#fences+1]={x,y,8,8}
        elseif (plateauAtlas and tile and stoneTops[tile])
            or (forest and (tile==0x02 or tile==0x03))
            or (not plateauAtlas and not forest and solid) then
          stones[#stones+1]={x,y,8,8}
        end
      end
    end
  end
  return fences,stones,cliffs,trim
end

local effect=[[
extern float kind;
extern vec2 bedOrigin;
vec4 effect(vec4 color, Image image, vec2 uv, vec2 pixel) {
  vec4 c=Texel(image,uv);
  vec2 world=floor(pixel)+bedOrigin;
  float brightness=dot(c.rgb,vec3(0.299,0.587,0.114));
  bool cap=false;
  if (kind<1.5) {
    bool wood=c.r>c.b*1.25 && c.g>c.b*1.10 && c.r>=c.g*0.85 && brightness>0.28;
    cap=wood && mod(world.y,8.0)<5.0;
  } else if (kind<2.5) {
    float chroma=max(c.r,max(c.g,c.b))-min(c.r,min(c.g,c.b));
    bool stone=chroma<0.22 && brightness>0.42 && brightness<0.94;
    cap=stone && mod(world.y,16.0)<7.0;
  } else if (kind<3.5) {
    // Brown surface pixels only; retain its original dark/white texture.
    cap=c.r>c.b*1.25 && c.g>c.b*1.10 && c.r>=c.g*0.85 && brightness>0.20;
  } else {
    // Pale ground showing around non-walkable scenery. This is colour-only,
    // with tree/bush/encounter-grass tiles omitted by the live selection.
    cap=brightness>0.48 && c.g>max(c.r,c.b)+0.008;
  }
  if (cap) c.rgb=mix(vec3(0.84,0.91,0.96),vec3(0.98,0.99,1.0),
    smoothstep(0.28,0.85,brightness));
  return c*color;
}
]]

local canvas,shader,cw,ch,failed
function Surfaces.draw(g,map,camX,camY,w,h,warn,protect,skipOutside)
  if failed then return end
  local fences,stones,cliffs,trim=Surfaces.regions(map,camX,camY,w,h,protect,skipOutside)
  if #fences==0 and #stones==0 and #cliffs==0 and #trim==0 then return end
  local source=g.getCanvas()
  if not source then return end
  g.push("all")
  local ok,err=pcall(function()
    if not shader then shader=g.newShader(effect) end
    if not canvas or cw~=w or ch~=h then
      if canvas and canvas.release then canvas:release() end
      canvas=nil
      canvas=g.newCanvas(w,h)
      canvas:setFilter("nearest","nearest")
      cw,ch=w,h
    end
    g.origin()
    g.setColor(1,1,1,1)
    g.setBlendMode("alpha","premultiplied")
    shader:send("bedOrigin",{camX,camY})
    for kind,regions in ipairs({fences,stones,cliffs,trim}) do
      if #regions>0 then
        g.setScissor()
        g.setCanvas(canvas)
        g.clear(0,0,0,0)
        shader:send("kind",kind)
        g.setShader(shader)
        g.draw(source,0,0)
        g.setCanvas(source)
        g.setShader()
        for _,r in ipairs(regions) do
          local x0,y0=math.max(0,r[1]-camX),math.max(0,r[2]-camY)
          local x1,y1=math.min(w,r[1]+r[3]-camX),math.min(h,r[2]+r[4]-camY)
          if x1>x0 and y1>y0 then
            g.setScissor(x0,y0,x1-x0,y1-y0)
            g.draw(canvas,0,0)
          end
        end
      end
    end
  end)
  g.setCanvas(source)
  g.pop()
  if not ok then
    failed=true
    if canvas and canvas.release then canvas:release() end
    if shader and shader.release then shader:release() end
    canvas,shader=nil,nil
    warn("Stone/fence snow could not be drawn: %s. Disable SNOW COVER and report this error.",tostring(err))
  end
end

return Surfaces
