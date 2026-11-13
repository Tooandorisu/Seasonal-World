-- Identify live foliage from the player's own OVERWORLD tileset. Block $0F
-- is the engine's tree-wall block. No tree graphics are shipped or replaced.
local Foliage = {}

function Foliage.regions(map,camX,camY,w,h,skipSideBorder)
  local route23=map.id=="ROUTE_23"
  local safari=(map.id or ""):match("^SAFARI_ZONE_")~=nil
  local forest=map.id=="VIRIDIAN_FOREST" or safari
  local plateauAtlas=map.id=="INDIGO_PLATEAU" or route23
  local blocks=map.tileset and map.tileset.blocks
  -- Route 23's border block also supplies the four live tiles used for
  -- its isolated trees. The nearby rock tiles are a separate graphic.
  local wall=map.id~="INDIGO_PLATEAU" and blocks and blocks[(forest and 0x02 or 0x0f)+1]
  if (not wall and not plateauAtlas) or type(map.tileAt)~="function" then return {} end
  local ids={}
  for _,id in ipairs(wall or {}) do ids[id]=true end
  if forest then
    -- The path corner is only part of the tree immediately next to its base.
    ids[0x30]=nil
  end
  if safari then
    -- Low shrubs use a separate metatile from the large forest trees.
    for i=9,16 do
      local tile=blocks[0x7c+1] and blocks[0x7c+1][i]
      if tile then ids[tile]=true end
    end
  end
  local regions={}
  local maxTX,maxTY=(map.widthCells or 0)*2-1,(map.heightCells or 0)*2-1
  local x0,x1=math.floor(camX/8),math.floor((camX+w-1)/8)
  local y0,y1=math.floor(camY/8),math.floor((camY+h-1)/8)
  for ty=y0,y1 do
    local first
    for tx=x0,x1+1 do
      local leafy=false
      if tx<=x1 then
        local outside=tx<0 or ty<0 or tx>maxTX or ty>maxTY
        -- Border-fill trees are drawn before connected-map strips. Include
        -- their visible pixels; later route strips still draw normally.
        if plateauAtlas then
          leafy=not skipSideBorder and ty>=0 and ty<=maxTY and (tx<0 or tx>maxTX)
          if route23 and not outside then leafy=ids[map:tileAt(tx,ty)]==true end
        else
          leafy=(outside and not skipSideBorder) or (not outside and ids[map:tileAt(tx,ty)]==true)
        end
        if forest and not leafy and not outside and tx>0 then
          leafy=map:tileAt(tx,ty)==0x30 and map:tileAt(tx-1,ty)==0x36
        end
        -- Frost the existing bright grass blades, not a solid white tile.
        -- Keep the live encounter/grass grid untouched and re-read it so
        -- cut grass immediately stops using the foliage overlay.
        if not leafy and not outside and map.isGrassCell then
          leafy=map:isGrassCell(math.floor(tx/2),math.floor(ty/2))==true
        end
        -- Cut bushes use a separate atlas graphic; keep them live so the
        -- snow disappears immediately when the player cuts one down.
        if not leafy and not outside and not plateauAtlas and not forest and map.cellTile and map.isWalkableCell then
          local cx,cy=math.floor(tx/2),math.floor(ty/2)
          leafy=map:cellTile(cx,cy)==0x3d and not map:isWalkableCell(cx,cy)
        end
      end
      if leafy and first==nil then first=tx end
      if not leafy and first~=nil then
        regions[#regions+1]={first*8,ty*8,(tx-first)*8,8}
        first=nil
      end
    end
  end
  return regions
end

local effect=[[
extern float forestPalette;
vec4 effect(vec4 color, Image image, vec2 uv, vec2 pixel) {
  vec4 c=Texel(image,uv);
  bool green=c.g>c.r*1.08 && c.g>c.b*1.08;
  float brightness=dot(c.rgb,vec3(0.299,0.587,0.114));
  // Follow the atlas's existing lit leaf shapes, never a screen/world grid.
  // No dark-pixel fill: branch contours and gaps between crowns stay intact.
  float minLight=mix(0.58,0.48,forestPalette);
  if (green && c.g>0.70 && brightness>minLight) {
    float light=smoothstep(minLight,0.90,brightness);
    c.rgb=mix(vec3(0.84,0.91,0.96),vec3(0.98,0.99,1.0),light);
  }
  return c*color;
}
]]

local canvas,shader,cw,ch,failed
function Foliage.draw(g,map,camX,camY,w,h,warn,skipSideBorder)
  if failed then return end
  local regions=Foliage.regions(map,camX,camY,w,h,skipSideBorder)
  if #regions==0 then return end
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
    g.setScissor()
    g.setColor(1,1,1,1)
    g.setBlendMode("alpha","premultiplied")
    g.setCanvas(canvas)
    g.clear(0,0,0,0)
    shader:send("forestPalette",(map.id=="VIRIDIAN_FOREST" or (map.id or ""):match("^SAFARI_ZONE_")) and 1 or 0)
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
  end)
  g.setCanvas(source)
  g.pop()
  if not ok then
    failed=true
    if canvas and canvas.release then canvas:release() end
    if shader and shader.release then shader:release() end
    canvas,shader=nil,nil
    warn("Foliage snow could not be drawn: %s. Disable SNOW COVER and report this error.",tostring(err))
  end
end

return Foliage
