local mod = ...
local Calendar = assert(load(mod:read("calendar.lua"), "@seasonal_world/calendar.lua"))()
local Winter = assert(load(mod:read("winter.lua"), "@seasonal_world/winter.lua"))()
local Trees = assert(load(mod:read("trees.lua"), "@seasonal_world/trees.lua"))()
local Viridian = assert(load(mod:read("viridian.lua"), "@seasonal_world/viridian.lua"))()
local Pewter = assert(load(mod:read("pewter.lua"), "@seasonal_world/pewter.lua"))()
local Cerulean = assert(load(mod:read("cerulean.lua"), "@seasonal_world/cerulean.lua"))()
local Vermilion = assert(load(mod:read("vermilion.lua"), "@seasonal_world/vermilion.lua"))()
local Tower = assert(load(mod:read("tower.lua"), "@seasonal_world/tower.lua"))()
local hasVersion,GameVersion=pcall(require,"src.core.GameVersion")
local Lavender = assert(load(mod:read("lavender.lua"), "@seasonal_world/lavender.lua"))()
local Celadon = assert(load(mod:read("celadon.lua"), "@seasonal_world/celadon.lua"))()
local Fuchsia = assert(load(mod:read("fuchsia.lua"), "@seasonal_world/fuchsia.lua"))()
local Saffron = assert(load(mod:read("saffron.lua"), "@seasonal_world/saffron.lua"))()
local Cinnabar = assert(load(mod:read("cinnabar.lua"), "@seasonal_world/cinnabar.lua"))()
local Indigo = assert(load(mod:read("indigo.lua"), "@seasonal_world/indigo.lua"))()
local Route23 = assert(load(mod:read("route23.lua"), "@seasonal_world/route23.lua"))()
local Route22 = assert(load(mod:read("route22.lua"), "@seasonal_world/route22.lua"))()
local Route1 = assert(load(mod:read("route1.lua"), "@seasonal_world/route1.lua"))()
local Route2 = assert(load(mod:read("route2.lua"), "@seasonal_world/route2.lua"))()
local Route3 = assert(load(mod:read("route3.lua"), "@seasonal_world/route3.lua"))()
local Route4 = assert(load(mod:read("route4.lua"), "@seasonal_world/route4.lua"))()
local Route5 = assert(load(mod:read("route5.lua"), "@seasonal_world/route5.lua"))()
local Route6 = assert(load(mod:read("route6.lua"), "@seasonal_world/route6.lua"))()
local Route7 = assert(load(mod:read("route7.lua"), "@seasonal_world/route7.lua"))()
local Route8 = assert(load(mod:read("route8.lua"), "@seasonal_world/route8.lua"))()
local Route9 = assert(load(mod:read("route9.lua"), "@seasonal_world/route9.lua"))()
local Route10 = assert(load(mod:read("route10.lua"), "@seasonal_world/route10.lua"))()
local Route11 = assert(load(mod:read("route11.lua"), "@seasonal_world/route11.lua"))()
local Route12 = assert(load(mod:read("route12.lua"), "@seasonal_world/route12.lua"))()
local Route13 = assert(load(mod:read("route13.lua"), "@seasonal_world/route13.lua"))()
local Route14 = assert(load(mod:read("route14.lua"), "@seasonal_world/route14.lua"))()
local Route15 = assert(load(mod:read("route15.lua"), "@seasonal_world/route15.lua"))()
local Route16 = assert(load(mod:read("route16.lua"), "@seasonal_world/route16.lua"))()
local Route17 = assert(load(mod:read("route17.lua"), "@seasonal_world/route17.lua"))()
local Route18 = assert(load(mod:read("route18.lua"), "@seasonal_world/route18.lua"))()
local Route19 = assert(load(mod:read("route19.lua"), "@seasonal_world/route19.lua"))()
local Route20 = assert(load(mod:read("route20.lua"), "@seasonal_world/route20.lua"))()
local Route21 = assert(load(mod:read("route21.lua"), "@seasonal_world/route21.lua"))()
local Route24 = assert(load(mod:read("route24.lua"), "@seasonal_world/route24.lua"))()
local Route25 = assert(load(mod:read("route25.lua"), "@seasonal_world/route25.lua"))()
local ViridianForest = assert(load(mod:read("viridian_forest.lua"), "@seasonal_world/viridian_forest.lua"))()
local Safari = assert(load(mod:read("safari.lua"), "@seasonal_world/safari.lua"))()
local Dock = assert(load(mod:read("dock.lua"), "@seasonal_world/dock.lua"))()
local Cities = {VIRIDIAN_CITY=Viridian, PEWTER_CITY=Pewter, CERULEAN_CITY=Cerulean, VERMILION_CITY=Vermilion, VERMILION_DOCK=Dock, LAVENDER_TOWN=Lavender, CELADON_CITY=Celadon, FUCHSIA_CITY=Fuchsia, SAFFRON_CITY=Saffron, CINNABAR_ISLAND=Cinnabar, INDIGO_PLATEAU=Indigo, ROUTE_23=Route23, ROUTE_22=Route22}
local AdaptiveCities = {CINNABAR_ISLAND=Cinnabar, INDIGO_PLATEAU=Indigo, ROUTE_4=Route4, ROUTE_19=Route19}
Cities.ROUTE_1 = Route1
Cities.ROUTE_2 = Route2
Cities.ROUTE_3 = Route3
Cities.ROUTE_4 = Route4
Cities.ROUTE_5 = Route5
Cities.ROUTE_6 = Route6
Cities.ROUTE_7 = Route7
Cities.ROUTE_8 = Route8
Cities.ROUTE_9 = Route9
Cities.ROUTE_10 = Route10
Cities.ROUTE_11 = Route11
Cities.ROUTE_12 = Route12
Cities.ROUTE_13 = Route13
Cities.ROUTE_14 = Route14
Cities.ROUTE_15 = Route15
Cities.ROUTE_16 = Route16
Cities.ROUTE_17 = Route17
Cities.ROUTE_18 = Route18
Cities.ROUTE_19 = Route19
Cities.ROUTE_20 = Route20
Cities.ROUTE_21 = Route21
Cities.ROUTE_24 = Route24
Cities.ROUTE_25 = Route25
Cities.VIRIDIAN_FOREST = ViridianForest
for id,layout in pairs(Safari) do Cities[id]=layout end
local PreviewNeighbors = {
  INDIGO_PLATEAU={ROUTE_23=true},
  ROUTE_23={INDIGO_PLATEAU=true, ROUTE_22=true},
  ROUTE_22={ROUTE_23=true, VIRIDIAN_CITY=true},
  VIRIDIAN_CITY={ROUTE_22=true, ROUTE_1=true, ROUTE_2=true},
  ROUTE_1={VIRIDIAN_CITY=true, PALLET_TOWN=true},
  ROUTE_2={VIRIDIAN_CITY=true, PEWTER_CITY=true},
  PEWTER_CITY={ROUTE_2=true, ROUTE_3=true},
  ROUTE_3={PEWTER_CITY=true, ROUTE_4=true},
  ROUTE_4={ROUTE_3=true, CERULEAN_CITY=true},
  CERULEAN_CITY={ROUTE_4=true, ROUTE_5=true, ROUTE_9=true, ROUTE_24=true},
  ROUTE_24={CERULEAN_CITY=true, ROUTE_25=true},
  ROUTE_25={ROUTE_24=true},
  ROUTE_9={CERULEAN_CITY=true, ROUTE_10=true},
  ROUTE_10={ROUTE_9=true, LAVENDER_TOWN=true},
  ROUTE_5={CERULEAN_CITY=true, SAFFRON_CITY=true},
  SAFFRON_CITY={ROUTE_5=true, ROUTE_6=true, ROUTE_7=true, ROUTE_8=true},
  ROUTE_6={SAFFRON_CITY=true, VERMILION_CITY=true},
  VERMILION_CITY={ROUTE_6=true, ROUTE_11=true},
  ROUTE_11={VERMILION_CITY=true, ROUTE_12=true},
  ROUTE_12={LAVENDER_TOWN=true, ROUTE_11=true, ROUTE_13=true},
  ROUTE_13={ROUTE_12=true, ROUTE_14=true},
  ROUTE_14={ROUTE_13=true, ROUTE_15=true},
  ROUTE_15={ROUTE_14=true, FUCHSIA_CITY=true},
  FUCHSIA_CITY={ROUTE_15=true, ROUTE_18=true, ROUTE_19=true},
  ROUTE_7={CELADON_CITY=true, SAFFRON_CITY=true},
  CELADON_CITY={ROUTE_7=true, ROUTE_16=true},
  ROUTE_16={CELADON_CITY=true, ROUTE_17=true},
  ROUTE_17={ROUTE_16=true, ROUTE_18=true},
  ROUTE_18={ROUTE_17=true, FUCHSIA_CITY=true},
  ROUTE_19={FUCHSIA_CITY=true, ROUTE_20=true},
  ROUTE_20={ROUTE_19=true, CINNABAR_ISLAND=true},
  CINNABAR_ISLAND={ROUTE_20=true, ROUTE_21=true},
  ROUTE_21={PALLET_TOWN=true, CINNABAR_ISLAND=true},
  ROUTE_8={SAFFRON_CITY=true, LAVENDER_TOWN=true, ROUTE_10=true, ROUTE_12=true},
  LAVENDER_TOWN={ROUTE_8=true, ROUTE_10=true, ROUTE_12=true},
  PALLET_TOWN={ROUTE_1=true, ROUTE_21=true},
}
local northSouthTreeNeighbors = {
  ROUTE_5={"CERULEAN_CITY","SAFFRON_CITY"},
  ROUTE_6={"SAFFRON_CITY","VERMILION_CITY"},
  ROUTE_21={"PALLET_TOWN","CINNABAR_ISLAND"},
}
local PalletLights = {{64,73,64},{192,73,64},{160,158,96}}
local Foliage = assert(load(mod:read("foliage.lua"), "@seasonal_world/foliage.lua"))()
local Surfaces = assert(load(mod:read("surfaces.lua"), "@seasonal_world/surfaces.lua"))()
local Overworld = require("src.world.OverworldController")
local Renderer = require("src.render.Renderer")
local Pipelines = require("src.render.Pipelines")
local Tilt = require("src.render.Tilt")
local Game = require("src.core.Game")
local TileRenderer = require("src.render.TileRenderer")
local TextBox = require("src.render.TextBox")

mod.options:define(assert(load(mod:read("options.lua"), "@seasonal_world/options.lua"))())

-- Local date, cached for one second. No network or game-save clock involved.
local date, checkedAt
local function season()
  local now = love.timer.getTime()
  if checkedAt == nil or now < checkedAt or now - checkedAt >= 1 then
    local ok, value = pcall(os.date, "*t")
    date = ok and value or nil
    checkedAt = now
  end
  return Calendar.season(mod.options:get("mode"), date)
end

local colors = {{1, .24, .22}, {1, .85, .24}, {.25, .8, 1}, {.5, 1, .4}}
local function lights(g, x, y, length, tick)
  g.setColor(.14, .23, .16, 1)
  g.rectangle("fill", x, y, length, 1)
  for i = 0, math.floor((length - 1) / 5) do
    local c = colors[(i % #colors) + 1]
    local bright = ((i + tick) % 3 == 0) and .65 or 1
    g.setColor(c[1] * bright, c[2] * bright, c[3] * bright, 1)
    g.rectangle("fill", x + i * 5, y + 1, 2, 2)
  end
end

local function tree(g, x, y, tick)
  -- Stepped pixel silhouette, shaded branches and broken snow caps.
  g.setColor(.88, .94, .97, .9)
  g.rectangle("fill", x - 10, y - 1, 23, 3)
  g.rectangle("fill", x - 7, y + 2, 17, 1)
  g.setColor(.22, .14, .09, 1)
  g.rectangle("fill", x - 2, y - 8, 5, 9)
  g.setColor(.52, .32, .16, 1)
  g.rectangle("fill", x - 1, y - 7, 2, 7)
  for tier = 0, 2 do
    local top = y - 29 + tier * 8
    local tip = 1 + tier * 2
    for row = 0, 8 do
      local half = tip + math.floor(row * .85)
      g.setColor(.04, .20, .13, 1)
      g.rectangle("fill", x - half, top + row, half * 2 + 1, 1)
      if row > 0 then
        g.setColor(.10, .43, .24, 1)
        g.rectangle("fill", x - half + 1, top + row, half, 1)
        g.setColor(.07, .32, .18, 1)
        g.rectangle("fill", x + 1, top + row, half, 1)
      end
    end
    g.setColor(.93, .97, 1, 1)
    g.rectangle("fill", x - tip, top + 1, tip + 2, 1)
    g.rectangle("fill", x - tip - 3, top + 5, 4, 1)
    g.rectangle("fill", x + tip, top + 6, 3, 1)
  end
  for i, p in ipairs({{-2,-23},{3,-18},{-5,-14},{5,-10},{-8,-7},{0,-8},{8,-5}}) do
    local c = colors[(i + tick) % #colors + 1]
    g.setColor(c[1], c[2], c[3], 1)
    g.rectangle("fill", x + p[1], y + p[2], 2, 2)
  end
  g.setColor(.67, .40, .08, 1)
  g.rectangle("fill", x - 1, y - 34, 3, 6)
  g.rectangle("fill", x - 3, y - 32, 7, 2)
  g.setColor(1, .9, .35, 1)
  g.rectangle("fill", x, y - 34, 1, 5)
  g.rectangle("fill", x - 2, y - 32, 5, 1)
  -- Small outlined presents with horizontal and vertical ribbon.
  for i, p in ipairs({{6,-4,7,6},{-11,-3,6,5}}) do
    local px, py, pw, ph = x+p[1], y+p[2], p[3], p[4]
    g.setColor(.25, .12, .14, 1)
    g.rectangle("fill", px-1, py-1, pw+2, ph+2)
    if i == 1 then g.setColor(.8, .14, .22, 1) else g.setColor(.20, .40, .78, 1) end
    g.rectangle("fill", px, py, pw, ph)
    g.setColor(1, .84, .35, 1)
    g.rectangle("fill", px+math.floor(pw/2), py, 1, ph)
    g.rectangle("fill", px, py+2, pw, 1)
  end
end

local function environmentActive(map)
  return map and (map.id == "PALLET_TOWN" or Cities[map.id]) and season() == "christmas"
    and not Pipelines.worldPipeline() and not Tilt.active()
end

local function eligible(ow,map)
  if not ow or not environmentActive(map or ow.map) then return false end
  -- This prototype uses flat-world pixel coordinates. Do not draw 2D
  -- ornaments into a 3D pipeline or a tilted/alternate world canvas.
  if Pipelines.worldPipeline() or Tilt.active() then return false end
  if not ow.camera then return false end
  -- The engine already decides whether to draw the world behind a menu.
  -- Keep its seasonal layers whenever that world pass actually runs.
  -- Only exclude the special battle-background use of the overworld.
  if Game.worldBgBattleInStack and Game.worldBgBattleInStack(Game.stack) then return false end
  return true
end

local function drawDecorations(ow)
  if not eligible(ow) then return end
  local g = love.graphics
  local w, h = Renderer:worldViewSize()
  local t = love.timer.getTime()
  local tick = math.floor(t * 2)
  local cx, cy = ow.camera.x, ow.camera.y
  g.push("all")
  local ok, err = pcall(function()
    g.origin()
    g.setShader()
    g.setBlendMode("alpha")
    -- Eaves aligned from the first device playtest. The houses start one
    -- tile further right than the 0.0.1 strings; the lab's X was correct.
    local rows=ow.map.id=="PALLET_TOWN" and PalletLights or Cities[ow.map.id].lights
    for _,row in ipairs(rows) do
      lights(g,row[1]-cx,row[2]-cy,row[3],tick)
    end
    if ow.map.id=="ROUTE_1" or ow.map.id=="ROUTE_2" or ow.map.id=="ROUTE_3"
        or ow.map.id=="ROUTE_4" or ow.map.id=="CERULEAN_CITY"
        or ow.map.id=="ROUTE_5" or ow.map.id=="SAFFRON_CITY"
        or ow.map.id=="ROUTE_6" or ow.map.id=="VERMILION_CITY"
        or ow.map.id=="ROUTE_7" or ow.map.id=="CELADON_CITY"
        or ow.map.id=="ROUTE_8" or ow.map.id=="LAVENDER_TOWN"
        or ow.map.id=="ROUTE_9" or ow.map.id=="ROUTE_10"
        or ow.map.id=="ROUTE_11" or ow.map.id=="ROUTE_12" or ow.map.id=="ROUTE_13"
        or ow.map.id=="ROUTE_14" or ow.map.id=="ROUTE_15" or ow.map.id=="FUCHSIA_CITY"
        or ow.map.id=="ROUTE_16" or ow.map.id=="ROUTE_17" or ow.map.id=="ROUTE_18"
        or ow.map.id=="ROUTE_19" or ow.map.id=="ROUTE_20" or ow.map.id=="CINNABAR_ISLAND"
        or ow.map.id=="ROUTE_21" or ow.map.id=="ROUTE_24" or ow.map.id=="ROUTE_25" then
      for _,neighbor in ipairs(ow.neighbors or {}) do
        local id=neighbor.map.id
        local layout=PreviewNeighbors[ow.map.id][id] and Cities[id]
        local adaptive=layout and AdaptiveCities[id]
        if adaptive then
          local other=mod.find and mod:find("tileshift")
          layout=adaptive.forMap(neighbor.map,other and other.exports,
            hasVersion and GameVersion.get and GameVersion.get() or "red")
        end
        local adjacentLights=id=="PALLET_TOWN" and PalletLights or layout and layout.lights
        for _,row in ipairs(adjacentLights or {}) do
          local x,y=row[1]+neighbor.ox-cx,row[2]+neighbor.oy-cy
          if x<w and x+row[3]>0 and y<h and y+6>0 then lights(g,x,y,row[3],tick) end
        end
      end
    end
    if mod.options:get("snow") ~= false then
      g.setColor(.95, .98, 1, .85)
      local count = math.min(100, math.ceil(w * h / 900))
      for i = 1, count do
        local x = (i * 47 + math.sin(t * .6 + i) * 5 - cx * .15) % w
        local y = (i * 29 + t * (9 + i % 7) - cy * .15) % h
        g.rectangle("fill", math.floor(x), math.floor(y), 1, (i % 5 == 0) and 2 or 1)
      end
    end
  end)
  g.pop()
  if not ok then
    mod.log:warn("Christmas drawing failed: %s. Disable Seasonal World and report this error.", tostring(err))
  end
end

-- Interleave tree art with the engine's Y-sorted character draws. A tree
-- shares the depth of its solid base cell, so people south of it draw last.
local function drawTreeAt(ow, location, offsetX, offsetY)
  local g = love.graphics
  g.push("all")
  local ok, err = pcall(function()
    g.origin()
    g.setShader()
    g.setBlendMode("alpha")
    tree(g, location.x * 16 + 8 + offsetX - ow.camera.x,
      (location.y + 1) * 16 + offsetY - ow.camera.y,
      math.floor(love.timer.getTime() * 2))
  end)
  g.pop()
  if not ok then mod.log:warn("Christmas tree drawing failed: %s", tostring(err)) end
end

-- Keep vanilla/peer collision decisions and only add our tree's base cell.
-- This applies to ordinary player and NPC movement, not scripted teleports.
mod.hooks:wrap("movement.collision", function(next, allowed, ctx)
  local result = next(allowed, ctx)
  if result and environmentActive(ctx.map) and Trees.at(ctx.toX, ctx.toY, ctx.map) then
    ctx.reason = "seasonal_tree"
    return false
  end
  return result
end)

-- The normal A-button dispatch calls interact only when the player can
-- interact. Empty scenery cells otherwise have no NPC target for world.talk.
local previousInteract = Overworld.interact
if type(previousInteract) == "function" then
  Overworld.interact = function(self, ...)
    local top = Game.stack and Game.stack.top and Game.stack:top()
    if top == self and eligible(self) and self.player and self.player.facingCell then
      local x, y = self.player:facingCell()
      local target = Trees.at(x, y, self.map)
      if target and Game.stack and Game.stack.push then
        Game.stack:push(TextBox.new(Game, target.message))
        return
      end
    end
    return previousInteract(self, ...)
  end
end

-- Render in the world pass, before the engine draws dialogue and menus.
-- Delegates to the method already installed so other wrappers still run.
local activeWorld
-- The engine redraws its moving ship after terrain. Apply dock snow after
-- that pass and before actors, so the snow travels with the ship snapshot.
local previousShip=Overworld.drawShipAnim
local dockShipPass=type(previousShip)=="function"
if dockShipPass then
  Overworld.drawShipAnim=function(self,camX,camY,...)
    previousShip(self,camX,camY,...)
    if activeWorld==self and eligible(self) and mod.options:get("cover")~=false then
      local w,h=Renderer:worldViewSize()
      local city=Cities[self.map.id]
      if self.map.id=="VERMILION_DOCK" then
        Dock.draw(love.graphics,self.map,camX,camY,w,h,
          function(...) mod.log:warn(...) end,self.shipAnim)
      elseif city and (city.purpleRoofs or city.finishRoofs) then
        Viridian.drawRoofFinish(love.graphics,camX,camY,w,h,
          function(...) mod.log:warn(...) end,city)
      end
    end
  end
end
local function warn(...) mod.log:warn(...) end
-- Connected maps are drawn in their own camera coordinates. Apply snow to
-- each visible map body so snow reaches both sides of the route seams.
local function drawPreview(renderer,camX,camY)
  local map=renderer.map
  if not activeWorld or not map or map==activeWorld.map
      or mod.options:get("cover")==false then return end
  local root=activeWorld.map
  if map.id=="VERMILION_DOCK" then
    if not eligible(activeWorld,map) then return end
    local w,h=Renderer:worldViewSize()
    Dock.draw(love.graphics,map,camX,camY,w,h,warn)
    return
  end
  local neighbors=PreviewNeighbors[root.id]
  if not neighbors or not neighbors[map.id] or not eligible(activeWorld,map) then return end
  local w,h=Renderer:worldViewSize()
  if camX+w<=0 or camY+h<=0 or camX>=map.widthCells*16 or camY>=map.heightCells*16 then return end
  local layout=Cities[map.id]
  local adaptive=AdaptiveCities[map.id]
  if adaptive then
    local other=mod.find and mod:find("tileshift")
    layout=adaptive.forMap(map,other and other.exports,
      hasVersion and GameVersion.get and GameVersion.get() or "red")
  end
  local g=love.graphics
  if map.id=="PALLET_TOWN" then
    Winter.draw(g,camX,camY,warn)
    Winter.drawFlowerBed(g,camX,camY,warn)
  else
    Viridian.draw(g,map,camX,camY,w,h,Winter.effect,warn,layout,true)
  end
  -- Both sides of this seam share the active map's border fill. Only
  -- include the neighbor's side strips when its edges line up with ours.
  local alignedSides=camX==activeWorld.camera.x and map.widthCells==root.widthCells
    and (map.id=="INDIGO_PLATEAU" or map.id=="ROUTE_23")
  Foliage.draw(g,map,camX,camY,w,h,warn,not alignedSides)
  Surfaces.draw(g,map,camX,camY,w,h,warn,layout and layout.protect,true)
end
local previousMapOnly=TileRenderer.drawMapOnly
if type(previousMapOnly)=="function" then
  TileRenderer.drawMapOnly=function(self,camX,camY,...)
    previousMapOnly(self,camX,camY,...)
    drawPreview(self,camX,camY)
  end
end
local previousTiles = TileRenderer.draw
if type(previousTiles) == "function" then
  TileRenderer.draw = function(self, camX, camY, ...)
    previousTiles(self, camX, camY, ...)
    drawPreview(self,camX,camY)
    if activeWorld and self.map == activeWorld.map and eligible(activeWorld)
        and mod.options:get("cover") ~= false then
      local city=Cities[self.map.id]
      if city and city.finishRoofs then city.deferColour=dockShipPass end
      if self.map.id=="LAVENDER_TOWN" then
        local other=mod.find and mod:find("tileshift")
        Lavender.deferPurple=dockShipPass
        Tower.prepare(Lavender,self.map,other and other.exports,
          hasVersion and GameVersion.get and GameVersion.get() or "red")
      end
      if activeWorld.map.id=="VERMILION_DOCK" then
        if not dockShipPass then
          local w,h=Renderer:worldViewSize()
          Dock.draw(love.graphics,self.map,camX,camY,w,h,
            function(...) mod.log:warn(...) end)
        end
        return
      end
      if activeWorld.map.id == "PALLET_TOWN" then
        Winter.draw(love.graphics, camX, camY, function(...) mod.log:warn(...) end)
        Winter.drawFlowerBed(love.graphics, camX, camY, function(...) mod.log:warn(...) end)
      else
        local w,h=Renderer:worldViewSize()
        Viridian.draw(love.graphics,self.map,camX,camY,w,h,Winter.effect,
          function(...) mod.log:warn(...) end, Cities[self.map.id])
      end
      local w,h=Renderer:worldViewSize()
      Foliage.draw(love.graphics,self.map,camX,camY,w,h,
        function(...) mod.log:warn(...) end)
      Surfaces.draw(love.graphics,self.map,camX,camY,w,h,
        function(...) mod.log:warn(...) end, Cities[self.map.id] and Cities[self.map.id].protect)
    end
  end
else
  mod.log:warn("Snow cover is unavailable on this engine build. Other decorations remain enabled.")
end
local previousDraw = Overworld.drawWorld
if type(previousDraw) == "function" then
  Overworld.drawWorld = function(self, ...)
    local previousWorld = activeWorld
    activeWorld = self
    local locations = Trees.forMap(self.map)
    local visible = eligible(self)
    local treeMap
    local offsetX, offsetY = 0, 0
    local treeNeighbor = self.map.id == "ROUTE_23" and "INDIGO_PLATEAU"
      or self.map.id == "ROUTE_1" and "PALLET_TOWN"
      or (self.map.id == "ROUTE_2" or self.map.id == "ROUTE_3") and "PEWTER_CITY"
      or (self.map.id == "ROUTE_4" or self.map.id == "ROUTE_24") and "CERULEAN_CITY"
      or (self.map.id == "ROUTE_15" or self.map.id == "ROUTE_18"
        or self.map.id == "ROUTE_19") and "FUCHSIA_CITY"
      or self.map.id == "ROUTE_16" and "CELADON_CITY"
      or self.map.id == "ROUTE_20" and "CINNABAR_ISLAND"
      or (self.map.id == "ROUTE_8" or self.map.id == "ROUTE_10"
        or self.map.id == "ROUTE_12") and "LAVENDER_TOWN"
    local northSouth = northSouthTreeNeighbors[self.map.id]
    if visible and northSouth then
      local _, viewHeight = Renderer:worldViewSize()
      local center = self.camera.y + viewHeight / 2
      treeNeighbor = center < self.map.heightCells * 8 and northSouth[1] or northSouth[2]
    end
    if visible and treeNeighbor then
      for _, neighbor in ipairs(self.neighbors or {}) do
        if neighbor.map.id == treeNeighbor then
          treeMap = neighbor.map
          locations = Trees.forMap(treeMap)
          offsetX, offsetY = neighbor.ox, neighbor.oy
          break
        end
      end
    end
    local nextTree = 1
    local function treesThrough(depth)
      while locations[nextTree] and locations[nextTree].y * 16 + offsetY <= depth do
        drawTreeAt(self, locations[nextTree], offsetX, offsetY)
        nextTree = nextTree + 1
      end
    end
    local patched = {}
    local function sortWithTrees(entity, actorOffsetY)
      if type(entity.draw) ~= "function" then return end
      local original = entity.draw
      patched[#patched + 1] = { entity = entity, own = rawget(entity, "draw") }
      entity.draw = function(actor, ...)
        treesThrough((actor.py or (actor.cellY or 0) * 16) + actorOffsetY)
        return original(actor, ...)
      end
    end
    if visible then
      local layout = AdaptiveCities[self.map.id]
      if layout then
        local other = mod.find and mod:find("tileshift")
        Cities[self.map.id] = layout.forMap(self.map, other and other.exports,
          hasVersion and GameVersion.get and GameVersion.get() or "red")
      end
      if treeMap and #locations > 0 then
        for _, ghost in ipairs(self.ghosts or {}) do
          if ghost.map == treeMap then sortWithTrees(ghost.npc, ghost.oy) end
        end
      end
      for _, entity in ipairs(self.entities or {}) do sortWithTrees(entity, 0) end
    end
    local ok, err = pcall(previousDraw, self, ...)
    -- Always restore inherited/instance methods, including engine failures.
    for _, patch in ipairs(patched) do patch.entity.draw = patch.own end
    activeWorld = previousWorld
    if not ok then error(err, 0) end
    if visible then treesThrough(math.huge) end
    drawDecorations(self)
  end
else
  mod.log:warn("Overworld drawing is unavailable. Disable Seasonal World on this engine build.")
end

mod.exports.currentSeason = season
mod.log:info("Seasonal World 1.0.0-rc.1 loaded. Kanto towns, all 25 numbered routes, Indigo Plateau, Viridian Forest, Vermilion Dock, and Safari Zone. Set SEASON to CHRISTMAS TEST for a preview.")
