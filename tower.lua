-- Read optional TileShift ImageData once per map/style revision. No ROM art
-- or TileShift assets are copied; this only measures the live purple roof.
local Tower={}
local cachedMap,cachedProvider,cachedRevision,cachedStyle,cachedGame
local function purple(r,g,b,a)
  return (a or 1)>0.5 and b>g+0.04 and r>g+0.015
end
function Tower.prepare(layout,map,provider,game)
  local state=provider and provider.state
  local revision=state and state.revision
  local style=state and state.style
  game=game or "red"
  if cachedMap==map and cachedProvider==provider and cachedRevision==revision
      and cachedStyle==style and cachedGame==game then return end
  cachedMap,cachedProvider,cachedRevision,cachedStyle,cachedGame=map,provider,revision,style,game
  layout.protect={{192,-128,96,192},{224,80,16,16}}
  layout.purpleRoofs={{192,-160,96,160}}
  layout.roofMeasured=false
  layout.lights[6]=nil
  if state and style=="original" then
    layout.protect={{192,0,96,64},{224,80,16,16}}
    layout.lights[6]={192,12,96}
    return
  end
  if not state or style~="gen3" or not map.def then return end
  -- Older providers may expose no readable roof ImageData. A bounded,
  -- purple-only pass remains safe; do not guess a new eave/light position.
  layout.purpleRoofs={{192,-160,96,224}}
  layout.protect={{192,-128,96,192},{224,80,16,16}}
  layout.lights[6]=nil
  local minX,minY,maxX,maxY,centerY
  local function scan(data,ox,oy,sx,sy,w,h,coverage)
    if not data or type(data.getPixel)~="function" or type(data.getDimensions)~="function" then return end
    local dw,dh=data:getDimensions()
    sx,sy=sx or 0,sy or 0;w,h=w or dw,h or dh
    for y=sy,math.min(dh-1,sy+h-1) do for x=sx,math.min(dw-1,sx+w-1) do
      local q=math.floor(y/16)*2+math.floor(x/16)
      if not coverage or coverage[q] then
        local r,g,b,a=data:getPixel(x,y)
        local wx,wy=ox+x,oy+y
        if wx>=160 and wx<320 and wy>=-192 and wy<96 and purple(r,g,b,a) then
          minX=math.min(minX or wx,wx);maxX=math.max(maxX or wx,wx)
          minY=math.min(minY or wy,wy);maxY=math.max(maxY or wy,wy)
          -- Corner awnings can extend below the central roof's eave.
          if wx>=216 and wx<264 then centerY=math.max(centerY or wy,wy) end
        end
      end
    end end
  end
  local ok=pcall(function()
    if type(state.replacements)=="function" then
      local art=state:replacements(game,map.def.tileset,map.def)
      for by=0,2 do for bx=6,8 do
        local id=map.def.blocks[by*map.def.width+bx+1]
        local row=art and art[id]
        if type(row)=="table" then
          if row.positionRows then row=row.positionRows[by*map.def.width+bx] or row
          elseif row.positions then row=row.positions[bx..":"..by] or row end
        end
        if row then
          local data=type(row)=="table" and row.image or row
          scan(data,bx*32,by*32,0,0,32,32,type(row)=="table" and row.coverage)
        end
      end end
    end
    local roofs=provider.roofs
    if roofs and type(roofs.cells)=="function" then
      local cells=roofs:cells(game,map.def)
      for _,line in pairs(cells and cells.rows or {}) do
        for _,entry in ipairs(line) do
          if entry.x>=10 and entry.x<=19 and entry.y<=5
              and tostring(entry.role or ""):find("tower",1,true) then
            scan(entry.data,entry.x*16,entry.y*16)
          end
        end
      end
    end
  end)
  if not ok or not minX or not centerY or maxX-minX<16 then return end
  layout.roofMeasured=true
  layout.purpleRoofs={{minX-1,minY-1,maxX-minX+3,maxY-minY+3}}
  -- Align protection to the full native continuation and measured roof.
  -- The colour-only roof pass below changes no facade/window pixels.
  local x0=math.floor(math.min(176,minX-1)/8)*8
  local y0=math.floor(math.min(-16,minY-1)/8)*8
  local x1=math.ceil(math.max(288,maxX+2)/8)*8
  layout.protect={{x0,y0,x1-x0,64-y0},{224,80,16,16}}
  layout.lights[6]={minX,centerY+1,maxX-minX+1}
end
return Tower
