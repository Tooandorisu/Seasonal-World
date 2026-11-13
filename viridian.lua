-- Authored decoration positions; terrain snow uses the player's live map.
-- No extracted maps or graphics are included in this mod.
local City = {}
City.lights = {
  {352,382,64}, -- Pokemon Center
  {448,286,64}, -- Poke Mart
  {320,142,64}, -- nickname house
  {320,238,64}, -- school
  {448,94,96},  -- Gym
}
-- Roof-only bounds and grass-topped ledges, checked against the city layout.
-- Recolour green pixels inside them; leave roof outlines and brown ledges.
City.details = {
  {352,352,64,30}, {448,256,64,30},
  {320,128,64,14}, {320,224,64,14}, {448,64,96,30},
  {384,128,192,32}, {64,416,512,32},
}
-- Snow on green overhangs just below the roof plane, including corner
-- awnings the roof-only rectangles missed. Stay above door faces.
for _,r in ipairs(City.lights) do
  City.details[#City.details+1]={r[1],r[2],r[3],4}
  City.details[#City.details+1]={r[1],r[2]+4,14,6}
  City.details[#City.details+1]={r[1]+r[3]-14,r[2]+4,14,6}
end
City.fences = {{320,208,256},{320,272,64},{64,496,256},{352,496,224}}
-- Narrow grassy lips above the brown ledge faces. Use full ground snow here
-- so neutral-coloured grass stipple is removed as well as green pixels.
City.ledgeSnow = {{384,144,192,8},{48,432,528,8},{48,280,16,8}}
function City.safeLedges(map,layout,allowWarp)
  layout=layout or City
  local result={}
  -- Hand-placed grassy lips can cross a pond on the same map row. Clip
  -- against the live water grid rather than painting one long white band.
  if type(map.isWaterCell)~="function" then return result end
  local treeIds={}
  local forest=map.id=="VIRIDIAN_FOREST"
  local treeWall=map.tileset and map.tileset.blocks and map.tileset.blocks[(forest and 0x02 or 0x0f)+1]
  for _,id in ipairs(treeWall or {}) do treeIds[id]=true end
  if forest then treeIds[0x30]=nil end -- path corner shared by tree blocks
  for _,r in ipairs(layout.ledgeSnow) do
    -- Split at atlas-tile boundaries so opaque snow cannot erase even half
    -- a crown where the live map puts a tree into a grassy ledge block.
    local tx0,tx1=math.floor(r[1]/8),math.floor((r[1]+r[3]-1)/8)
    local ty0,ty1=math.floor(r[2]/8),math.floor((r[2]+r[4]-1)/8)
    for ty=ty0,ty1 do for tx=tx0,tx1 do
      local cx,cy=math.floor(tx/2),math.floor(ty/2)
      local tree=type(map.tileAt)=="function" and treeIds[map:tileAt(tx,ty)]
      local bush=map.cellTile and map:cellTile(cx,cy)==0x3d
      if not tree and not bush and not map:isWaterCell(cx,cy)
          and not (map.signAtCell and map:signAtCell(cx,cy))
          and not (map.warpAtCell and map:warpAtCell(cx,cy) and not allowWarp) then
        local x0,y0=math.max(r[1],tx*8),math.max(r[2],ty*8)
        local x1,y1=math.min(r[1]+r[3],(tx+1)*8),math.min(r[2]+r[4],(ty+1)*8)
        result[#result+1]={x0,y0,x1-x0,y1-y0}
      end
    end end
  end
  return result
end
local detailEffect = [[
extern float lightGreenOnly;
vec4 effect(vec4 color, Image image, vec2 uv, vec2 pixel) {
  vec4 c = Texel(image, uv);
  float brightness=dot(c.rgb,vec3(0.299,0.587,0.114));
  bool sceneryGreen = lightGreenOnly < 0.5
    && c.g > c.r * 1.08 && c.g > c.b * 1.08;
  // Ground around fixed scenery may be almost white with only a tiny
  // green bias. A relative 8% threshold misses that remaining tint.
  bool paleGrass = lightGreenOnly > 0.5 && brightness > 0.48
    && c.g > max(c.r,c.b) + 0.008;
  if (sceneryGreen || paleGrass) {
    float shade = clamp((c.r + c.g + c.b) / 3.0, 0.0, 1.0);
    c.rgb = mix(vec3(0.75, 0.86, 0.94), vec3(0.96, 0.99, 1.0),
      smoothstep(0.10, 0.70, shade));
  }
  return c * color;
}
]]

-- Recolour grey/lilac and Cerulean blue roofs only inside explicit roof,
-- fascia and corner-awning bounds. Never apply this pass to water.
City.roofEffect = [[
extern float warmRoofs;
extern float snowDarkRoof;
extern float purpleOnly;
vec4 effect(vec4 color, Image image, vec2 uv, vec2 pixel) {
  vec4 c = Texel(image,uv);
  float brightness = dot(c.rgb,vec3(0.299,0.587,0.114));
  float chroma = max(c.r,max(c.g,c.b))-min(c.r,min(c.g,c.b));
  bool warmRoof = warmRoofs > 0.5 && c.r > c.b+0.02 && c.r >= c.g-0.02;
  bool blueRoof = c.b > c.r*1.08 && c.b > c.g*1.03;
  bool purpleRoof=c.b>c.g+0.01 && c.r>c.g+0.008;
  bool greenRoof=c.g>c.r*1.08 && c.g>c.b*1.08;
  bool selected=purpleOnly>1.5 ? (purpleRoof || blueRoof || greenRoof || warmRoof)
    : (purpleOnly>0.5 ? purpleRoof : (chroma<0.22 || blueRoof || warmRoof));
  if (snowDarkRoof > 0.5 && selected && brightness > 0.15 && brightness <= 0.28) {
    // Keep the slate pattern visible while lightening its broad dark panels.
    c.rgb = mix(vec3(0.79,0.88,0.94),vec3(0.91,0.96,0.99),
      smoothstep(0.15,0.28,brightness));
  } else if (selected && brightness > 0.28 && brightness < 0.94) {
    c.rgb = mix(vec3(0.78,0.87,0.94),vec3(0.98,0.99,1.0),
      smoothstep(0.28,0.90,brightness));
  } else if (selected && brightness > 0.08 && brightness <= 0.28) {
    // Retain dark roof seams, but remove their residual lilac tint.
    c.rgb=vec3(brightness*0.85,brightness*0.98,brightness*1.08);
  }
  return c*color;
}
]]

function City.snowCell(map,x,y,layout)
  for _,r in ipairs(layout and layout.protect or {}) do
    if x*16<r[1]+r[3] and (x+1)*16>r[1] and y*16<r[2]+r[4] and (y+1)*16>r[2] then return false end
  end
  if not map:isWalkableCell(x,y) then return false end
  if map.isWaterCell and map:isWaterCell(x,y) then return false end
  if layout and layout.preserveCellTiles and map.tileAt then
    for ty=y*2,y*2+1 do
      for tx=x*2,x*2+1 do
        if layout.preserveCellTiles[map:tileAt(tx,ty)] then return false end
      end
    end
  end
  -- Keep the original texture for the separate surface recolour.
  if layout and layout.preserveSurfaceBlock and map.cellTile and map.tileset then
    local surface=map.tileset.blocks and map.tileset.blocks[layout.preserveSurfaceBlock+1]
    if surface and map:cellTile(x,y)==surface[1] then return false end
  end
  -- Keep encounter grass recognisable; ordinary garden grass is recoloured.
  if map.isGrassCell and map:isGrassCell(x,y) then return false end
  if map.warpAtCell and map:warpAtCell(x,y) then return false end
  if map.signAtCell and map:signAtCell(x,y) then return false end
  return true
end

local function spans(map,camX,camY,w,h,layout)
  local rows = {}
  local width,height = map.widthCells or 0,map.heightCells or 0
  local minX,maxX=math.max(0,math.floor(camX/16)),math.min(width-1,math.floor((camX+w-1)/16))
  local minY,maxY=math.max(0,math.floor(camY/16)),math.min(height-1,math.floor((camY+h-1)/16))
  for y=minY,maxY do
    local first
    for x=minX,maxX+1 do
      local eligible=x<=maxX and City.snowCell(map,x,y,layout)
      if eligible and not first then first=x end
      if not eligible and first then
        rows[#rows+1]={first*16,y*16,(x-first)*16,16}
        first=nil
      end
    end
  end
  return rows
end

local canvas,shader,detailShader,roofShader,canvasW,canvasH,failed
function City.draw(g,map,camX,camY,w,h,effect,warn,layout,preview)
  layout=layout or City
  if failed then return end
  if type(map.isWalkableCell)~="function" then return end
  local source=g.getCanvas()
  if not source then return end
  g.push("all")
  local ok,err=pcall(function()
    if not shader then shader=g.newShader(effect) end
    if not detailShader then detailShader=g.newShader(detailEffect) end
    if not canvas or canvasW~=w or canvasH~=h then
      if canvas and canvas.release then canvas:release() end
      canvas=nil
      canvas=g.newCanvas(w,h)
      canvas:setFilter("nearest","nearest")
      canvasW,canvasH=w,h
    end
    g.origin()
    g.setScissor()
    g.setColor(1,1,1,1)
    g.setBlendMode("alpha","premultiplied")
    g.setCanvas(canvas)
    g.clear(0,0,0,0)
    shader:send("bedOrigin",{camX,camY})
    g.setShader(shader)
    g.draw(source,0,0)
    g.setCanvas(source)
    g.setShader()
    local function blitRects(rectangles)
      for _,r in ipairs(rectangles) do
        local x0,y0=math.max(0,r[1]-camX),math.max(0,r[2]-camY)
        local x1,y1=math.min(w,r[1]+r[3]-camX),math.min(h,r[2]+r[4]-camY)
        if x1>x0 and y1>y0 then
          g.setScissor(x0,y0,x1-x0,y1-y0)
          g.draw(canvas,0,0)
        end
      end
    end
    -- Read collision state afresh: Cut trees and story changes are not cached.
    blitRects(spans(map,camX,camY,w,h,layout))
    if layout.snowNorthBorder and camY<0 and not preview then
      -- The north edge is scenery beyond the map. Snow it with the same
      -- texture as the ground, leaving space for any overhanging roof.
      local roof=layout.northBorderRoof
      local borderBottom=roof and roof[2] or 0
      blitRects({{camX,camY,w,borderBottom-camY}})
      if roof then
        local roofRight=roof[1]+roof[3]
        blitRects({{camX,borderBottom,roof[1]-camX,-borderBottom},
          {roofRight,borderBottom,camX+w-roofRight,-borderBottom}})
      end
    end
    blitRects(City.safeLedges(map,layout))
    if layout.entranceSnow then
      blitRects(City.safeLedges(map,{ledgeSnow=layout.entranceSnow},true))
    end
    -- A second live pass handles scenery the walk grid excludes. The source
    -- is still the world canvas; our intermediate is always a different one.
    g.setScissor()
    g.setCanvas(canvas)
    g.clear(0,0,0,0)
    detailShader:send("lightGreenOnly",0)
    g.setShader(detailShader)
    g.draw(source,0,0)
    g.setCanvas(source)
    g.setShader()
    blitRects(layout.details)
    if layout.tintTrim then
      g.setScissor()
      g.setCanvas(canvas)
      g.clear(0,0,0,0)
      detailShader:send("lightGreenOnly",1)
      g.setShader(detailShader)
      g.draw(source,0,0)
      g.setCanvas(source)
      g.setShader()
      blitRects(layout.tintTrim)
    end
    if layout.roofs then
      if not roofShader then roofShader=g.newShader(City.roofEffect) end
      g.setScissor()
      g.setCanvas(canvas)
      g.clear(0,0,0,0)
      roofShader:send("purpleOnly",0)
      roofShader:send("warmRoofs",layout.warmRoofs and 1 or 0)
      roofShader:send("snowDarkRoof",layout.snowDarkRoof and 1 or 0)
      g.setShader(roofShader)
      g.draw(source,0,0)
      g.setCanvas(source)
      g.setShader()
      blitRects(layout.roofs)
      local extraRoofs=layout.purpleRoofs or layout.finishRoofs
      if extraRoofs and not preview and not (layout.deferPurple or layout.deferColour) then
        g.setScissor();g.setCanvas(canvas);g.clear(0,0,0,0)
        roofShader:send("purpleOnly",layout.finishRoofMode or (layout.finishRoofs and 2 or 1));g.setShader(roofShader);g.draw(source,0,0)
        g.setCanvas(source);g.setShader();blitRects(extraRoofs)
      end
    end
    g.setScissor()
    g.setColor(.96,.99,1,1)
    for _,r in ipairs(layout.fences) do
      for x=r[1],r[1]+r[3]-8,8 do
        -- The post's dark top starts two pixels below the block boundary.
        -- Seat a thicker cap on it instead of a tiny floating highlight.
        g.rectangle("fill",x+1-camX,r[2]+2-camY,6,2)
        g.rectangle("fill",x+2-camX,r[2]+1-camY,4,1)
      end
    end
    for _,r in ipairs(layout.lights) do
      g.rectangle("fill",r[1]+1-camX,r[2]-2-camY,r[3]-2,2)
    end
    for _,r in ipairs(layout.snowCaps or {}) do
      g.rectangle("fill",r[1]-camX,r[2]-camY,r[3],r[4])
    end
  end)
  g.setCanvas(source)
  g.pop()
  if not ok then
    failed=true
    if canvas and canvas.release then canvas:release() end
    if shader and shader.release then shader:release() end
    if detailShader and detailShader.release then detailShader:release() end
    if roofShader and roofShader.release then roofShader:release() end
    canvas,shader,detailShader,roofShader=nil,nil,nil,nil
    warn("City snow could not be drawn: %s. Disable SNOW COVER and report this error.",tostring(err))
  end
end

-- TileShift may replay a roof continuation during neighbour drawing. Finish
-- the tower after all terrain/continuations and before any actor is drawn.
function City.drawRoofFinish(g,camX,camY,w,h,warn,layout)
  local rectangles=layout.purpleRoofs or layout.finishRoofs
  if failed or not rectangles or not canvas or not roofShader then return end
  local source=g.getCanvas()
  if not source or canvasW~=w or canvasH~=h then return end
  g.push("all")
  local ok,err=pcall(function()
    g.origin();g.setScissor();g.setColor(1,1,1,1);g.setBlendMode("alpha","premultiplied")
    g.setCanvas(canvas);g.clear(0,0,0,0)
    roofShader:send("purpleOnly",layout.finishRoofMode or (layout.finishRoofs and 2 or 1));roofShader:send("warmRoofs",layout.warmRoofs and 1 or 0)
    roofShader:send("snowDarkRoof",layout.snowDarkRoof and 1 or 0)
    g.setShader(roofShader);g.draw(source,0,0)
    g.setCanvas(source);g.setShader()
    for _,r in ipairs(rectangles) do
      local x0,y0=math.max(0,r[1]-camX),math.max(0,r[2]-camY)
      local x1,y1=math.min(w,r[1]+r[3]-camX),math.min(h,r[2]+r[4]-camY)
      if x1>x0 and y1>y0 then g.setScissor(x0,y0,x1-x0,y1-y0);g.draw(canvas,0,0) end
    end
  end)
  g.setCanvas(source);g.pop()
  if not ok then
    failed=true
    if canvas and canvas.release then canvas:release() end
    if shader and shader.release then shader:release() end
    if detailShader and detailShader.release then detailShader:release() end
    if roofShader and roofShader.release then roofShader:release() end
    canvas,shader,detailShader,roofShader=nil,nil,nil,nil
    warn("Roof finish could not be drawn: %s",tostring(err))
  end
end
return City
