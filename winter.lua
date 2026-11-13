-- Original snow overlay for the vanilla Pallet layout, in world pixels.
-- It is drawn by TileRenderer before people and Pokemon, never over them.
local Winter = {}
local buildings = {
  {64, 48, 64, 48}, {192, 48, 64, 48}, -- houses, including roofs
  {160, 128, 96, 64},                  -- lab, including roof
}
local masks = {
  {48, 80, 16, 16}, {176, 80, 16, 16}, -- house signs
  {64, 160, 64, 32},                  -- central flower bed
  {64, 144, 64, 16},                  -- actual central fence and sign
  {64, 224, 64, 64},                 -- pond and its visible bank
  {160, 208, 96, 16},                 -- actual south-east fence and sign
  {160, 224, 128, 32},                -- entire south-east flower bed
  {0, 272, 32, 16},                  -- south-west boundary stones
  {128, 272, 192, 16},                -- southern boundary east of pond
}

function Winter.groundAt(x, y)
  -- The north edge of Pallet has three grass strips between the
  -- boundary stones. The center opening is encounter grass.
  if y >= 0 and y < 16 then
    return (x >= 0 and x < 48) or (x >= 64 and x < 144) or (x >= 208 and x < 304)
  end
  -- Start at the inside of the west boundary stones, not a tile further
  -- into town. The pond mask follows its bank rather than a wide box.
  if x < 16 or x >= 304 or y < 32 or y >= 288 then return false end
  for _, r in ipairs(buildings) do
    -- Protect the full building rectangle. Guessed sloping cutouts painted
    -- opaque ground snow over roof outlines in the device playtest.
    if x >= r[1] and y >= r[2] and x < r[1]+r[3] and y < r[2]+r[4] then
      return false
    end
  end
  for _, r in ipairs(masks) do
    if x >= r[1] and y >= r[2] and x < r[1]+r[3] and y < r[2]+r[4] then
      return false
    end
  end
  return true
end

local function paint(g)
  -- Opaque snow base: no transparent gaps for green grass to show through.
  -- Small deterministic white accents retain a quiet pixel texture.
  for y = 0, 286, 2 do
    for x = 0, 302, 2 do
      if Winter.groundAt(x, y) then
        local n = (x * 17 + y * 31 + math.floor(x/2) * math.floor(y/2) * 7) % 19
        g.setColor(.91, .96, .99, 1)
        g.rectangle("fill", x, y, 2, 2)
        if n % 3 == 0 then
          g.setColor(.99, 1, 1, 1)
          g.rectangle("fill", x, y, 1, 1)
        end
      end
    end
  end
  -- Small caps on both flower-bed fences; leave the sign faces clear.
  g.setColor(.96, .99, 1, 1)
  for _, fence in ipairs({{160,208,96,208,224}, {64,144,64,112,128}}) do
    for x = fence[1], fence[1]+fence[3]-8, 8 do
      if x < fence[4] or x >= fence[5] then
        g.rectangle("fill", x+2, fence[2]+1, 4, 1)
        g.rectangle("fill", x+3, fence[2], 2, 1)
      end
    end
  end
  -- Roof-top snow follows stepped roof slopes, leaving windows and doors.
  for _, roof in ipairs({{64,48,64,71}, {192,48,64,71}, {160,128,96,156}}) do
    local x, y, w = roof[1], roof[2], roof[3]
    g.setColor(.75, .86, .94, 1)
    g.rectangle("fill", x+12, y+1, w-24, 6)
    g.setColor(.96, .99, 1, 1)
    g.rectangle("fill", x+16, y, w-32, 4)
    g.rectangle("fill", x+12, y+4, w-24, 2)
    g.rectangle("fill", x+8, y+6, 8, 2)
    g.rectangle("fill", x+w-16, y+6, 8, 2)
    -- Irregular snow along eaves, above the existing coloured bulbs.
    local eave = roof[4]
    g.rectangle("fill", x+1, eave, w-2, 2)
    -- Keep the lab's lower light string clear of dangling snow/icicles.
    if w == 64 then
      for i = 4, w-5, 11 do
        g.rectangle("fill", x+i, eave+2, 2, 2+(i%3))
      end
    end
  end
end

-- Recolour the live bed rather than covering its flowers with white boxes.
-- Copy each small region to a different target, so the GPU never reads
-- from the same canvas it is writing. The original flower animation survives.
local beds = {{x=160,y=224,w=128,h=32}, {x=64,y=160,w=64,h=32}}
local bedCanvases, bedShader, bedFailed = {}, nil, false
local bedEffect = [[
extern vec2 bedOrigin;
vec4 effect(vec4 color, Image image, vec2 uv, vec2 pixel) {
  vec4 c = Texel(image, uv);
  vec2 world = floor(pixel) + bedOrigin;
  vec2 cell = floor(world / 2.0) * 2.0;
  float grain = mod(cell.x * 17.0 + cell.y * 31.0
    + mod(cell.x / 2.0, 19.0) * mod(cell.y / 2.0, 19.0) * 7.0, 19.0);
  float accent = step(mod(grain, 3.0), 0.5)
    * step(mod(world.x, 2.0), 0.5) * step(mod(world.y, 2.0), 0.5);
  bool flower = c.r > 0.6 && c.r > c.g * 1.06 && c.r > c.b * 1.02;
  // Preserve the colourful petals/centres. All remaining bed background,
  // including the grey/brown stipple, receives the same opaque snow tone.
  if (!flower) {
    c.rgb = mix(vec3(0.91, 0.96, 0.99), vec3(0.99, 1.0, 1.0), accent);
  }
  return c * color;
}
]]
Winter.effect = bedEffect

function Winter.drawFlowerBed(g, camX, camY, warn)
  if bedFailed then return end
  local source = g.getCanvas()
  if not source then return end
  g.push("all")
  local ok, err = pcall(function()
    if not bedShader then bedShader = g.newShader(bedEffect) end
    g.origin()
    if g.setScissor then g.setScissor() end
    g.setBlendMode("alpha", "premultiplied")
    g.setColor(1, 1, 1, 1)
    for i, bed in ipairs(beds) do
      if not bedCanvases[i] then
        bedCanvases[i] = g.newCanvas(bed.w, bed.h)
        bedCanvases[i]:setFilter("nearest", "nearest")
      end
      g.setCanvas(bedCanvases[i])
      g.clear(0, 0, 0, 0)
      bedShader:send("bedOrigin", {bed.x, bed.y})
      g.setShader(bedShader)
      g.draw(source, camX-bed.x, camY-bed.y)
      g.setCanvas(source)
      g.setShader()
      g.draw(bedCanvases[i], bed.x-camX, bed.y-camY)
    end
  end)
  g.setCanvas(source)
  g.pop()
  if not ok then
    bedFailed = true
    for _, canvas in pairs(bedCanvases) do
      if canvas.release then canvas:release() end
    end
    if bedShader and bedShader.release then bedShader:release() end
    bedCanvases, bedShader = {}, nil
    warn("Flower-bed snow could not be drawn: %s. Disable SNOW COVER and report this error.", tostring(err))
  end
end

local cached, failed
function Winter.draw(g, camX, camY, warn)
  if failed then return end
  local originalTarget = g.getCanvas()
  local building
  g.push("all")
  local ok, err = pcall(function()
    g.origin()
    g.setShader()
    g.setBlendMode("alpha")
    if not cached then
      -- One 320x288 transparent canvas; all snow drawing is cached once.
      -- Restore the target explicitly as well as the graphics attributes.
      local target = g.getCanvas()
      local made = g.newCanvas(320, 288)
      building = made
      made:setFilter("nearest", "nearest")
      g.setCanvas(made)
      if g.setScissor then g.setScissor() end
      g.clear(0, 0, 0, 0)
      paint(g)
      g.setCanvas(target)
      cached = made
      building = nil
    end
    -- Canvas pixels already carry alpha, so use premultiplied blending.
    g.setBlendMode("alpha", "premultiplied")
    g.setColor(1, 1, 1, 1)
    g.draw(cached, -camX, -camY)
  end)
  g.setCanvas(originalTarget)
  g.pop()
  if not ok then
    if building and building.release then building:release() end
    failed = true
    warn("Snow cover could not be drawn: %s. Turn SNOW COVER off and report this error.", tostring(err))
  end
end

return Winter
