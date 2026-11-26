-- Protect actor blits only while the flat spring pass draws Route 12 or Lavender.
local mod = ...
local hasSprites, Sprites = pcall(require, "src.render.SpriteRenderer")
local hasAssets, Assets = pcall(require, "src.render.Assets")
local hasPalette, Palette = pcall(require, "src.render.PaletteFX")
if not (hasSprites and hasAssets and hasPalette and type(Sprites.draw) == "function"
    and type(Sprites.resolveImage) == "function" and type(Sprites.invalidate) == "function") then
  return pcall
end

local function isReleased(object, method)
  if not object or not object[method] then return false end
  local ok, message = pcall(object[method], object)
  return not ok and type(message) == "string"
    and message:find("Cannot use object after it has been released", 1, true) ~= nil
end

local function drawTexture(sprite)
  local def = sprite.def
  if def.gbaArt or (def.trueColor and Palette.honorsTrueColor()) then return sprite.image end
  if not sprite.objColors then
    if Palette.usesGbcPack() then
      local colors, group = Palette.spriteObp(def, sprite.seed)
      return colors and Sprites.obpImage(def.image, colors, group) or sprite.image
    end
    -- OG Red draws the DMG bake outside the post-zone redraw pass.
    if Palette.usesSpriteObp() and not Palette.spriteRedrawPassActive() then
      return Sprites.obpImage(def.image, Palette.dmgObj())
    end
  end
  return sprite:resolveImage()
end

local function reloadSheet(source)
  local image = Assets.image(source)
  if not isReleased(image, "getDimensions") then return image end
  local key = Assets.resolve(source)
  if not Assets.isComposed(source) and not Assets.isComposed(key) then
    -- Unregistering a nonexistent compositor evicts just this cache entry.
    -- The normal resolver will pick the active mod override and its DPI again.
    Assets.compose(key, nil)
    return Assets.image(source)
  end
  -- Preserve the provider for sheets built in memory.
  return love.graphics.newImage(Assets.imageData(source))
end

local cropped = {"halfFrames", "bottomFrames"}
local function restore(sprite)
  local texture = drawTexture(sprite)
  local sheetLost = isReleased(sprite.image, "getDimensions")
  local bakeLost = texture ~= sprite.image and isReleased(texture, "getDimensions")
  if sheetLost then sprite.image = reloadSheet(sprite.def.image) end
  if sheetLost or bakeLost then Sprites.invalidate() end

  local frameLost = false
  for frame, quad in pairs(sprite.frames) do
    if isReleased(quad, "getViewport") then
      local columns = sprite.frameColumns or 1
      local slot = (sprite.frameOffset or 0) + frame
      local w, h = sprite.frameWidth, sprite.frameHeight
      sprite.frames[frame] = love.graphics.newQuad((slot % columns) * w,
        math.floor(slot / columns) * h, w, h, sprite.image:getDimensions())
      frameLost = true
    end
  end
  for _, field in ipairs(cropped) do
    for frame, quad in pairs(sprite[field] or {}) do
      if isReleased(quad, "getViewport") then
        sprite[field][frame] = nil -- the engine lazily creates the crop on the next draw
        frameLost = true
      end
    end
  end
  return sheetLost and "sheet" or bakeLost and "palette texture" or frameLost and "frame"
end

return function(drawWorld, world, ...)
  local draw = Sprites.draw
  local function checkedDraw(sprite, ...)
    local ok, err = pcall(draw, sprite, ...)
    if ok then return err end
    if type(err) ~= "string" or not sprite.def or not sprite.frames or not
        err:match("src/render/SpriteRenderer%.lua:%d+: Cannot use object after it has been released%.?$") then
      error(err, 0)
    end
    local repaired, kind = pcall(restore, sprite)
    if not repaired then mod.log:warn("Sprite recovery in %s: %s", world.map.id, tostring(kind)) end
    if not repaired or not kind then error(err, 0) end
    mod.log:info("Rebuilt sprite %s for %s in %s.", kind, tostring(sprite.seed or sprite.def.image), world.map.id)
    return draw(sprite, ...)
  end
  Sprites.draw = checkedDraw
  local ok, err = pcall(drawWorld, world, ...)
  if Sprites.draw == checkedDraw then Sprites.draw = draw end
  return ok, err
end
