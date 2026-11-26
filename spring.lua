local mod = ...
local Spring = {
  -- Planting styles for outdoor maps that share visible boundaries.
  connectedPetalMaps = {
    PALLET_TOWN = "primroses", ROUTE_1 = "trees", VIRIDIAN_CITY = "trees",
    ROUTE_2 = "trees", PEWTER_CITY = "trees",
    ROUTE_3 = "wildflowers", ROUTE_4 = "wildflowers", CERULEAN_CITY = "wildflowers",
    ROUTE_24 = "wildflowers", ROUTE_25 = "wildflowers",
    ROUTE_5 = "wildflowers", ROUTE_6 = "wildflowers", VERMILION_CITY = "wildflowers",
    ROUTE_11 = "wildflowers",
    ROUTE_12 = "wildflowers", LAVENDER_TOWN = "wildflowers",
    ROUTE_9 = "wildflowers", ROUTE_10 = "wildflowers",
    ROUTE_8 = "wildflowers", SAFFRON_CITY = "wildflowers",
    ROUTE_7 = "wildflowers", CELADON_CITY = "wildflowers",
    ROUTE_16 = "wildflowers", ROUTE_17 = "downhill",
    ROUTE_18 = "wildflowers", FUCHSIA_CITY = "wildflowers",
    ROUTE_13 = "wildflowers", ROUTE_14 = "wildflowers", ROUTE_15 = "wildflowers",
    ROUTE_19 = "wildflowers", ROUTE_20 = "wildflowers", CINNABAR_ISLAND = "wildflowers",
    ROUTE_21 = "wildflowers", ROUTE_22 = "wildflowers", ROUTE_23 = "wildflowers",
    INDIGO_PLATEAU = "terraces",
  },
  maps = {
    -- These areas are reached through warps.
    VIRIDIAN_FOREST = true, VERMILION_DOCK = true,
    SAFARI_ZONE_CENTER = true, SAFARI_ZONE_EAST = true,
    SAFARI_ZONE_NORTH = true, SAFARI_ZONE_WEST = true,
  },
}

for id in pairs(Spring.connectedPetalMaps) do Spring.maps[id] = true end

local image, pink, gold, blossoms
local failed = false

local function loadFlowers(g)
  image = mod.assets:image("spring_blooms.png")
  image:setFilter("nearest", "nearest")
  pink = g.newQuad(0, 0, 8, 8, 32, 16)
  gold = g.newQuad(8, 0, 8, 8, 32, 16)
  blossoms = g.newQuad(16, 0, 16, 16, 32, 16)
end

local function grassEdge(map, x, y)
  return not (map:isGrassCell(x - 1, y) and map:isGrassCell(x + 1, y)
    and map:isGrassCell(x, y - 1) and map:isGrassCell(x, y + 1))
end

-- Use map-local cell coordinates so crossing a boundary keeps each plant in place.
local function variation(x, y)
  return (x * 23 + y * 37 + x * y * 3) % 101
end

local function matchesCrown(map, tx, ty, first, crown, i)
  return crown and first == crown[i] and map:tileAt(tx + 1, ty) == crown[i + 1]
    and map:tileAt(tx, ty + 1) == crown[i + 4]
    and map:tileAt(tx + 1, ty + 1) == crown[i + 5]
end

-- Each row stores one x coordinate, or a set of x coordinates for a planted strip.
local vergeRows = {
  [0x2c] = { -- short grass along banks and at the route entrances
    CERULEAN_CITY = {[0] = 24, [2] = 23, [4] = 25, [5] = 23},
    ROUTE_24 = {[4] = 18, [6] = 17, [13] = 14, [16] = 13, [18] = 15,
                [23] = 14, [28] = 13, [31] = 14, [34] = 13},
    ROUTE_25 = {[4] = 51, [5] = 1, [6] = 54, [7] = 50},
    ROUTE_5 = {[0] = 6, [1] = 15, [2] = 10, [28] = 18},
    ROUTE_6 = {[9] = 18, [10] = 15, [28] = 6, [29] = 7, [30] = 4, [33] = 14, [34] = 11},
    ROUTE_9 = {
      [2] = 19, [3] = 48, [4] = 22, [6] = {[8] = true, [13] = true}, [8] = 1,
      [10] = 28, [11] = 3, [12] = {[14] = true, [36] = true}, [14] = 50,
    },
    ROUTE_10 = {
      [7] = 14, [8] = 3, [10] = 9, [12] = 12, [14] = 13, [16] = 14,
      [19] = 9, [20] = 6, [21] = 14, [22] = 12, [24] = 11, [28] = 5,
      [53] = 15, [58] = 14, [60] = 17, [62] = 7, [63] = 12, [65] = 15,
    },
    ROUTE_11 = {[4] = 51, [5] = 46, [6] = 48, [10] = 53, [12] = 49},
    ROUTE_12 = {[61] = 2, [63] = 3, [87] = 4, [89] = 7, [99] = 6, [104] = 8},
    ROUTE_13 = {[3] = 41, [4] = 48, [6] = 37, [8] = 44, [15] = 12},
    ROUTE_14 = {
      [12] = 14, [17] = 11, [19] = 14, [23] = 11, [24] = 7, [26] = 4,
      [28] = 15, [32] = 5, [34] = 16, [36] = 11, [38] = 6, [42] = 14,
      [44] = 4, [45] = 9, [48] = {[3] = true, [15] = true},
    },
    ROUTE_15 = {
      [3] = 7, [5] = 12, [6] = {[6] = true, [17] = true, [27] = true, [42] = true, [55] = true},
      [10] = 11, [11] = 6, [12] = 12,
    },
    ROUTE_8 = {[2] = 30, [3] = 38, [4] = 5, [5] = 44, [6] = 52, [7] = 54,
               [9] = 51, [12] = 49, [13] = 9, [14] = 7},
    SAFFRON_CITY = {[15] = 1, [21] = 38},
    CELADON_CITY = {
      [1] = 27, [2] = 22, [3] = 32, [5] = 47, [7] = 48, [16] = 21,
      [30] = {[6] = true, [10] = true, [13] = true, [17] = true},
      [32] = {[8] = true, [14] = true}, [33] = 11, [34] = 15,
    },
    ROUTE_16 = {[2] = 6, [3] = 10, [6] = 13, [7] = 25, [8] = {[29] = true, [33] = true},
                [13] = 4, [15] = 15, [17] = 10},
    ROUTE_17 = {[0] = 1, [3] = 13, [5] = 17, [28] = 18, [40] = 1, [60] = 18,
                [76] = 1, [88] = 1, [108] = 1, [119] = 18},
    ROUTE_18 = {[10] = 42, [11] = 35, [13] = 48, [14] = 42, [16] = 45},
    ROUTE_21 = {[1] = 9, [2] = 17, [3] = 8, [4] = 2, [5] = 18,
                [6] = 15, [8] = 16, [11] = 2, [12] = 0},
    ROUTE_22 = {
      [2] = {[30] = true, [34] = true}, [6] = {[17] = true, [32] = true, [38] = true},
      [7] = 36, [8] = {[5] = true, [10] = true}, [10] = 35,
      [12] = {[7] = true, [15] = true, [22] = true, [33] = true},
    },
    FUCHSIA_CITY = {
      [4] = 15, [5] = 22, [8] = 16, [10] = 13, [11] = 26, [14] = 7,
      [17] = 33, [18] = {[1] = true, [14] = true}, [22] = 29, [23] = 33,
      [26] = 22, [30] = 12, [32] = 27,
    },
  },
  [0x39] = { -- tufted ground beside buildings and the Vermilion waterfront
    ROUTE_5 = {[16] = 8, [18] = 13, [19] = 7, [20] = 13, [22] = 8, [29] = 16},
    ROUTE_6 = {[12] = 15, [15] = 16},
    ROUTE_9 = {
      [6] = {[22] = true, [38] = true}, [7] = {[23] = true, [50] = true},
      [8] = {[7] = true, [54] = true}, [9] = {[12] = true, [35] = true, [58] = true},
      [10] = 47, [11] = 26, [14] = 14, [15] = 19,
    },
    ROUTE_10 = {
      [4] = {[5] = true, [12] = true}, [18] = 5, [19] = 3,
      [54] = {[3] = true, [10] = true}, [55] = 12, [56] = 8, [57] = 4, [70] = 8,
    },
    ROUTE_11 = {[2] = 1, [6] = 5, [7] = 2},
    ROUTE_12 = {[0] = 9, [2] = 8, [62] = 7, [76] = 9, [77] = 14, [78] = 9},
    ROUTE_13 = {
      [2] = 8, [4] = {[2] = true, [17] = true, [29] = true}, [5] = 25,
      [6] = {[7] = true, [22] = true, [30] = true},
      [8] = {[5] = true, [16] = true, [26] = true},
      [10] = {[13] = true, [32] = true}, [11] = 35, [12] = {[19] = true, [34] = true},
    },
    ROUTE_14 = {[4] = 17, [6] = 6, [8] = 10, [10] = 16, [12] = 8, [13] = 16, [15] = 6},
    ROUTE_15 = {
      [8] = {[1] = true, [38] = true}, [9] = {[4] = true, [40] = true},
      [12] = {[17] = true, [26] = true, [44] = true, [55] = true},
      [13] = {[21] = true, [38] = true, [50] = true, [58] = true},
    },
    ROUTE_8 = {[2] = 17, [5] = 18, [8] = 57, [10] = 20},
    ROUTE_7 = {[2] = 2, [3] = 5, [5] = 6, [6] = 11, [7] = 15, [8] = 9,
               [12] = 3, [13] = 8, [14] = 4, [15] = 7},
    SAFFRON_CITY = {
      [0] = 19, [2] = 17,
      [4] = {[25] = true, [28] = true, [32] = true, [35] = true},
      [8] = 22, [9] = 16, [16] = 15, [17] = 14, [18] = {[1] = true, [38] = true},
      [19] = 14, [20] = 15, [26] = 26, [28] = 24, [32] = 22, [34] = 22,
    },
    CELADON_CITY = {
      [14] = {[28] = true, [33] = true}, [18] = 1,
      [20] = {[27] = true, [32] = true, [34] = true, [41] = true},
    },
    ROUTE_16 = {[8] = {[5] = true, [9] = true}, [10] = 14, [12] = 19, [13] = 21, [16] = 4},
    ROUTE_17 = {[110] = 4, [116] = 16, [119] = 6, [122] = 3},
    ROUTE_18 = {[1] = 7, [2] = 12, [3] = 30, [4] = 32, [5] = 41,
                [6] = {[44] = true, [49] = true}, [8] = 29, [9] = 26},
    -- Yellow's beach extends two cells farther south around the Summer Beach House.
    ROUTE_19 = {
      [0] = 9, [2] = 6, [4] = 11, [6] = {[5] = true, [12] = true}, [7] = 7,
      [8] = {[5] = true, [10] = true}, [9] = {[4] = true, [8] = true},
      [10] = {[7] = true, [13] = true}, [11] = {[4] = true, [10] = true},
    },
    ROUTE_20 = {[7] = 50, [10] = 56},
    ROUTE_22 = {[10] = {[3] = true, [9] = true, [13] = true}, [11] = 4},
    FUCHSIA_CITY = {
      [4] = {[16] = true, [20] = true}, [14] = 24, [16] = 38, [18] = 34,
      [26] = {[25] = true, [35] = true}, [28] = {[6] = true, [30] = true, [32] = true},
      [29] = 10, [31] = 34, [34] = 21,
    },
    VERMILION_CITY = {
      [1] = 18, [2] = 24, [4] = 17, [5] = 15, [6] = 12,
      [12] = 7, [13] = 6, [14] = 36, [15] = 28,
      [17] = 7, [19] = 21, [20] = 10, [21] = 8, [22] = 15, [23] = 13,
    },
  },
}

-- The Seafoam Islands use a different pair of ground tiles from Cinnabar and Lavender.
local diagonalFlowers = {
  LAVENDER_TOWN = {
    corner = 0x30, side = 0x39,
    rows = {[1] = 7, [3] = 6, [5] = 1, [6] = 13, [7] = 15, [8] = 1,
            [9] = 12, [10] = 5, [11] = 6, [14] = 7, [15] = 10},
  },
  ROUTE_10 = {
    corner = 0x30, side = 0x39,
    rows = {[31] = 15, [35] = 14, [38] = 15, [40] = 2, [41] = 8,
            [42] = 4, [43] = 7, [44] = 13, [45] = 10},
  },
  ROUTE_20 = {
    corner = 0x2c, side = 0x30,
    rows = {[2] = 57, [3] = 60, [4] = 54, [5] = 58, [6] = 47, [7] = 53,
            [8] = {[46] = true, [51] = true}, [9] = 54, [10] = 61, [11] = 60},
  },
  CINNABAR_ISLAND = {
    corner = 0x30, side = 0x39,
    rows = {
      [1] = 12, [3] = 10, [4] = {[5] = true, [16] = true}, [5] = {[7] = true, [14] = true},
      [6] = 11, [7] = 16, [9] = 19, [10] = 5, [11] = 18,
      [12] = {[8] = true, [17] = true}, [13] = {[11] = true, [14] = true},
    },
  },
}

local function plantedAt(rows, x, y)
  local row = rows and rows[y]
  return row == x or (type(row) == "table" and row[x])
end

-- Keep the banks separate from encounter grass so using Cut cannot plant
-- a new buttercup. Gardens mark the park entrance and the five houses.
local safariBeds = {
  SAFARI_ZONE_CENTER = {
    garden = {[18] = {[15] = true, [21] = true}, [19] = 20, [20] = 16,
              [21] = {[14] = true, [19] = true}, [23] = {[13] = true, [18] = true}},
    bank = {
      [7] = {[8] = true, [13] = true, [20] = true}, [8] = 22,
      [10] = {[16] = true, [22] = true}, [11] = {[13] = true, [22] = true},
      [14] = {[8] = true, [11] = true, [14] = true, [17] = true, [20] = true},
    },
  },
  SAFARI_ZONE_EAST = {
    garden = {[8] = 23, [9] = 28, [10] = {[23] = true, [27] = true}, [11] = 24},
    bank = {[9] = {[12] = true, [16] = true, [18] = true}, [10] = 20, [11] = 20, [15] = 10},
  },
  SAFARI_ZONE_NORTH = {
    garden = {[3] = 38, [4] = {[33] = true, [37] = true}, [5] = 32, [6] = 36},
    bank = {
      [9] = 12, [13] = {[4] = true, [7] = true}, [14] = 3, [17] = 8, [19] = 8,
      [20] = {[6] = true, [7] = true}, [30] = {[9] = true, [10] = true, [11] = true},
    },
  },
  SAFARI_ZONE_WEST = {
    garden = {[4] = {[2] = true, [5] = true}, [5] = 4, [6] = 7, [12] = 13, [13] = 11, [14] = 13},
    bank = {[9] = {[2] = true, [4] = true, [6] = true, [8] = true}, [12] = 10,
            [14] = {[3] = true, [8] = true}},
  },
}

local bankNeighbors = {{-1, 0}, {1, 0}, {0, -1}, {0, 1}}

local function safariFlower(map, x, y, _, seed)
  local beds = safariBeds[map.id]
  local garden = plantedAt(beds.garden, x, y)
  if not garden and not plantedAt(beds.bank, x, y) then return end
  local tx, ty = x * 2, y * 2
  -- Only a full cell of FOREST meadow ($30) can hold this flower.
  if map:tileAt(tx, ty) ~= 0x30 or map:tileAt(tx + 1, ty) ~= 0x30
      or map:tileAt(tx, ty + 1) ~= 0x30 or map:tileAt(tx + 1, ty + 1) ~= 0x30 then return end
  local dx, dy = 1 + seed % 7, 1 + math.floor(seed / 3) % 7
  if garden then return pink, dx, dy end
  if map.isWaterCell then
    for _, offset in ipairs(bankNeighbors) do
      local wx, wy = x + offset[1], y + offset[2]
      if map:isWaterCell(wx, wy) then return gold, dx, dy, wx, wy end
    end
  end
end

-- Map-local verges on the PLATEAU tileset. The League courtyard has
-- one pair of flowers on each terrace, just outside the statue columns.
local plateauVerges = {
  ROUTE_23 = {
    [22] = {[5] = true, [14] = true}, [23] = 9,
    [32] = 2, [33] = 6, [34] = 15, [36] = 17, [37] = 2, [39] = 6,
    [41] = 2, [44] = 7, [47] = 11, [49] = 3, [50] = 8,
    [58] = 13, [63] = 8, [68] = 10, [70] = 17,
    [104] = 10, [106] = 14, [108] = 18, [110] = 5, [111] = 15,
    [116] = 15, [118] = {[3] = true, [14] = true},
    [124] = 4, [126] = {[9] = true, [17] = true}, [132] = 2,
    [134] = {[5] = true, [12] = true}, [135] = 11,
  },
  INDIGO_PLATEAU = {
    [7] = {[7] = true, [12] = true}, [11] = {[7] = true, [12] = true},
    [15] = {[7] = true, [12] = true},
  },
}

local function plateauFlower(map, x, y, _, seed)
  if not plantedAt(plateauVerges[map.id], x, y) then return end
  local tx, ty = x * 2, y * 2
  local ground = map:tileAt(tx, ty)
  if ground ~= 0x23 and ground ~= 0x2c then return end
  -- Native soil is uniform, or has one freckled quarter on pale ground.
  -- The checkerboard path shares both ground tiles but alternates them.
  local lowerLeft = map:tileAt(tx, ty + 1)
  if (lowerLeft ~= ground and not (ground == 0x23 and lowerLeft == 0x2d))
      or map:tileAt(tx + 1, ty) ~= ground or map:tileAt(tx + 1, ty + 1) ~= ground then return end
  if map.id == "INDIGO_PLATEAU" then
    return y == 7 and gold or pink, 4, 4
  end
  return (x + y) % 3 == 0 and gold or pink, 1 + seed % 7, 1 + math.floor(seed / 3) % 7
end

local function vergeFlower(map, x, y, tx, ty, soil, seed)
  local sprite, dy
  if map.id == "ROUTE_3" and soil == 0x2c and seed < 35 and x >= 2 and x <= 7
      and (y == 8 or y == 11) then
    sprite = seed % 3 == 0 and gold or pink
    dy = y == 8 and 2 or 7
  else
    -- Mt. Moon's approaches use dry, tufted ground ($39) around the rock.
    local foothills = map.id == "ROUTE_4" and soil == 0x39 and seed < 29
        and x >= 4 and x <= 31 and y >= 4 and y <= 16
    if not (foothills or plantedAt(vergeRows[soil][map.id], x, y)) then return end
    if map.id == "SAFFRON_CITY" then
      sprite = gold
    elseif (map.id == "CELADON_CITY" and soil == 0x2c) or map.id == "FUCHSIA_CITY" then
      sprite = pink
    else
      sprite = (x + y) % 3 == 0 and gold or pink
    end
    dy = 1 + math.floor(seed / 3) % 7
  end
  -- Check all four live quarters to avoid rocks, signs, shore and doorsteps.
  if map:tileAt(tx + 1, ty) == soil and map:tileAt(tx, ty + 1) == soil
      and map:tileAt(tx + 1, ty + 1) == soil then
    return sprite, 1 + seed % 7, dy
  end
end

local function outdoorFlower(map, x, y, crown, seed)
  -- Cycling Road has long, continuous flower beds beside its rails.
  if seed >= (map.id == "ROUTE_17" and 35 or 72) then return end
  local tx, ty = x * 2, y * 2
  local first = map:tileAt(tx, ty)
  local plot = diagonalFlowers[map.id]
  if plot and first == plot.corner and plantedAt(plot.rows, x, y)
      and map:tileAt(tx + 1, ty) == plot.side and map:tileAt(tx, ty + 1) == plot.side
      and map:tileAt(tx + 1, ty + 1) == plot.corner then
    local sprig = map.id == "ROUTE_10" and gold or pink
    return sprig, 1 + seed % 7, 1 + math.floor(seed / 3) % 7
  end
  if map.id == "LAVENDER_TOWN" then return end
  -- The native flower beds pair an animated flower ($03) with an empty
  -- grassy quarter ($2C) across the diagonal. Plant in that free quarter.
  if first == 0x03 or first == 0x2c then
    local opposite = map:tileAt(tx + 1, ty + 1)
    local sprig = seed % 3 == 0 and gold or pink
    if first == 0x03 and opposite == 0x2c then return sprig, 8, 8 end
    if first == 0x2c and opposite == 0x03 then return sprig, 0, 0 end
  end
  if first == 0x2c or first == 0x39 then
    local sprite, dx, dy = vergeFlower(map, x, y, tx, ty, first, seed)
    if sprite then return sprite, dx, dy end
  end

  -- Match the full 16px crown from the live tree-wall block. A single
  -- shared tile can also belong to a hedge corner or a different object.
  if seed < 35 and matchesCrown(map, tx, ty, first, crown, 1) then
    return blossoms, 0, 0
  end
end

-- Two trees in the column beside the south gate carry their blossoms
-- on the left branch. Values are vertical offsets in native pixels.
local southGateLeftBranches = {[34] = 6, [36] = 3}

local function forestFlower(map, x, y, crown)
  -- A forest crown spans two cells. Pick one side per flowering tree.
  -- Match live leaf tiles so the rule also finds the half-block trees
  -- beside the paths. Stumps and signs use other tiles from this atlas.
  local side = x % 2
  local leftX = x - side
  local treeSeed = variation(leftX, y)
  if treeSeed >= 32 then return end
  local southOffset = leftX == 20 and southGateLeftBranches[y]
  local blossomSide = southOffset and 0 or treeSeed % 2
  if side ~= blossomSide then return end
  local tx, ty = x * 2, y * 2
  if matchesCrown(map, tx, ty, map:tileAt(tx, ty), crown, 1 + side * 2) then
    -- The opaque petals stay inside this 16px cell at either offset.
    return blossoms, side == 0 and 3 or -1, southOffset or 4
  end
end

local petalRadius = 44 -- native pixels from the player to a flowering branch
local lavenderRed, lavenderGreen = 0.78, 0.82
local pinkPetal = {body = {228/255, 132/255, 166/255}, tip = {1, 218/255, 225/255}}
local goldPetal = {body = {237/255, 171/255, 61/255}, tip = {1, 240/255, 165/255}}

local function petalAge(now, x, y, seed, planting)
  if planting == "downhill" then
    -- The breeze reaches each successive row later. Adjacent columns take turns.
    return (now - y * 0.4 - (x % 4) * 2.7) % 10.8
  end
  if planting == "terraces" then
    -- Rows 15, 11 and 7 lead north to the League. The right flower follows the left.
    local row = (15 - y) / 4
    return (now - row * 3.6 - (x == 7 and 0 or 0.7)) % 10.8
  end
  if planting then
    -- Stagger close-set crowns and garden flowers along the outdoor paths.
    return (now + ((x - y) % 4) * 2.7 + (seed % 7) * 0.04) % 10.8
  end
  return (now + seed * 0.37) % (4.2 + (seed % 5) * 0.25)
end

local function paintPetal(g, x, y, colors, alpha, sway, redTint, greenTint)
  local body, tip = colors.body, colors.tip
  g.setColor(body[1] * redTint, body[2] * greenTint, body[3], alpha)
  g.rectangle("fill", x, y, 2, 1)
  g.setColor(tip[1] * redTint, tip[2] * greenTint, tip[3], alpha)
  g.rectangle("fill", x + (sway < 0 and 1 or 0), y + 1, 1, 1)
end

local function drawPetal(g, map, camX, camY, x, y, seed, age, proximity, sprite, downhill)
  local duration = downhill and 1.8 or 2.4
  local redTint, greenTint = 1, 1
  if map.id == "LAVENDER_TOWN" then
    -- Give the town's primroses a gentler arc in the same shade as their petals.
    duration = 3
    redTint, greenTint = lavenderRed, lavenderGreen
  end
  if age >= duration then return end
  local alpha = math.min(1, age / 0.18, (duration - age) / 0.32, proximity)
  local progress = age / duration
  local sway = math.sin(progress * 2 * math.pi)
  local direction = math.floor(seed / 2) % 2 == 0 and 1 or -1
  local drift, drop = progress * 6 + sway * 2.5, progress * 24
  if sprite ~= blossoms then
    local reach, lift, settle = 11, 9, 3
    if downhill then
      reach, lift, settle = 6, 12, 18
    elseif map.id == "INDIGO_PLATEAU" then
      -- Drift inward while staying on the garden side of each statue.
      direction = x < map.widthCells * 8 and 1 or -1
      reach, lift, settle = 6, 12, 2
    end
    -- Keep the whole arc inside the map, including the tip below the petal.
    lift = math.min(lift, y)
    settle = math.min(settle, map.heightCells * 16 - y - 2)
    local endX = x + direction * reach
    if endX < 0 or endX + 1 >= map.widthCells * 16 then direction = -direction end
    drift = progress * reach + sway * 1.5
    drop = progress * settle - math.sin(progress * math.pi) * lift
  end
  x = math.floor(x + direction * drift + 0.5)
  y = math.floor(y + drop + 0.5)
  -- Keep each map's petals inside its terrain when the renderer draws a neighbor last.
  if x < 0 or y < 0 or x + 1 >= map.widthCells * 16 or y + 1 >= map.heightCells * 16 then return end
  local colors = sprite == gold and goldPetal or pinkPetal
  paintPetal(g, x - camX, y - camY, colors, alpha, sway, redTint, greenTint)
end

-- A surfable bank cell can contain both shore and open water. Aim for
-- the nearest fully wet 8px quarter so the ripple fits on the surface.
local function nearestWaterTile(map, cellX, cellY, flowerX, flowerY)
  local nearest, tileX, tileY = math.huge
  for ty = cellY * 2, cellY * 2 + 1 do
    for tx = cellX * 2, cellX * 2 + 1 do
      if map:tileAt(tx, ty) == 0x14 then
        local dx, dy = tx * 8 + 4 - flowerX, ty * 8 + 4 - flowerY
        local distance = dx * dx + dy * dy
        if distance < nearest then nearest, tileX, tileY = distance, tx, ty end
      end
    end
  end
  return tileX, tileY
end

local function drawPondPetal(g, camX, camY, x, y, age, proximity, tileX, tileY, sprite)
  local airTime, floatTime = 2.4, 1.8
  local duration = airTime + floatTime
  if age >= duration then return end
  local landingX, landingY = tileX * 8 + 4, tileY * 8 + 4
  local flight = math.min(age / airTime, 1)
  local onWater = math.max(age - airTime, 0)
  local drift = onWater / floatTime
  x = math.floor(x + (landingX - x) * flight - 3 * drift + 0.5) - camX
  y = math.floor(y + (landingY - y) * flight - 12 * math.sin(flight * math.pi) + 2 * drift + 0.5) - camY
  if age >= airTime and onWater < 0.55 then
    local ripple = onWater / 0.55
    local radius = 1 + math.floor(ripple * 3)
    g.setColor(0.72, 0.85, 0.87, 0.7 * math.min(proximity, 1) * (1 - ripple))
    g.rectangle("fill", landingX - camX - radius, landingY - camY + 1, 1, 1)
    g.rectangle("fill", landingX - camX + radius, landingY - camY + 1, 1, 1)
  end
  local alpha = math.min(1, age / 0.18, (duration - age) / 0.5, proximity)
  local sway = math.sin((flight + drift * 0.5) * 2 * math.pi)
  paintPetal(g, x, y, sprite == gold and goldPetal or pinkPetal, alpha, sway, 1, 1)
end

local function playerCenter(player, neighbor)
  local px = player.px or (player.cellX and player.cellX * 16)
  local py = player.py or (player.cellY and player.cellY * 16)
  if not px or not py then return end
  if neighbor then px, py = px - neighbor.ox, py - neighbor.oy end
  return px + 8, py + 8
end

local function petalProximity(dx, dy, radius, solidRadius)
  local distanceSquared = dx * dx + dy * dy
  if distanceSquared < radius * radius then
    return (radius * radius - distanceSquared) / (radius * radius - solidRadius * solidRadius)
  end
end

local function drawNearbyPetals(g, map, crown, flower, player, camX, camY, neighbor, planting)
  local px, py = playerCenter(player, neighbor)
  if not px then return end
  local terraces = planting == "terraces"
  local scanRadius = terraces and 56 or petalRadius
  local x0 = math.max(0, math.floor((px - scanRadius) / 16))
  local y0 = math.max(0, math.floor((py - scanRadius) / 16))
  local x1 = math.min(map.widthCells - 1, math.floor((px + scanRadius) / 16))
  local y1 = math.min(map.heightCells - 1, math.floor((py + scanRadius) / 16))
  if x0 > x1 or y0 > y1 then return end
  local downhill = planting == "downhill"
  local wildflowers = planting == "wildflowers" or downhill or terraces
  local primroses = wildflowers or planting == "primroses"
  local now = love.timer.getTime()
  for y = y0, y1 do
    for x = x0, x1 do
      local sprite, dx, dy, waterX, waterY = flower(map, x, y, crown, variation(x, y))
      local garden = (primroses and sprite == pink) or (wildflowers and sprite == gold)
      if sprite == blossoms or garden then
        local seed = variation(x + 7, y + 11)
        -- Both flower heads have a petal at (2,1). Crowns use a pixel on either branch.
        local petalX, petalY = 2, 1
        if not garden then
          local left = seed % 2 == 0
          petalX, petalY = left and 4 or 10, left and 5 or 7
        end
        local anchorX = x * 16 + dx + petalX
        local anchorY = y * 16 + dy + petalY
        local radius, solidRadius = petalRadius, 32
        if terraces then
          -- Both flowers in a pair are visible from either lane between the statues.
          radius, solidRadius = scanRadius, 48
        elseif wildflowers and garden then
          radius, solidRadius = 32, 24
        end
        local proximity = petalProximity(anchorX - px, anchorY - py, radius, solidRadius)
        if proximity then
          local age = petalAge(now, x, y, seed, planting)
          local tileX, tileY
          if waterX then
            tileX, tileY = nearestWaterTile(map, waterX, waterY, anchorX, anchorY)
          elseif map.id == "CELADON_CITY" and x == 27 and y == 20 and sprite == pink
              and map:tileAt(49, 40) == 0x14 then
            tileX, tileY = 49, 40 -- pond outside the Game Corner
          end
          if tileX then
            drawPondPetal(g, camX, camY, anchorX, anchorY, age, proximity, tileX, tileY, sprite)
          else
            drawPetal(g, map, camX, camY, anchorX, anchorY, seed, age, proximity, sprite, downhill and garden)
          end
        end
      end
    end
  end
end

-- Two low wooden boxes on the dry quay above the S.S. Anne departure area.
local dockPlanterColumns = {11, 16}
local dockSprigs = {{x = 1, y = 2}, {x = 8, y = 1}}

local function drawDockPlanter(g, px, py, sprig)
  g.setColor(0.28, 0.19, 0.15, 1)
  g.rectangle("fill", px + 1, py + 8, 14, 3)
  g.rectangle("fill", px + 2, py + 11, 12, 3)
  g.setColor(0.64, 0.40, 0.24, 1)
  g.rectangle("fill", px + 3, py + 11, 10, 2)
  g.setColor(0.84, 0.64, 0.41, 1)
  g.rectangle("fill", px + 2, py + 9, 12, 1)
  g.setColor(1, 1, 1, 1)
  for _, pos in ipairs(dockSprigs) do
    g.draw(image, sprig, px + pos.x, py + pos.y)
  end
end

local function drawDockPetal(g, map, camX, camY, x, row, sprig, phase, px, py)
  local index = math.floor(phase / 5.4) % #dockSprigs + 1
  local head = dockSprigs[index]
  local ax, ay = x * 16 + head.x + 2, row * 16 + head.y + 1
  -- The boarding path is several cells from the western planter.
  local proximity = petalProximity(ax - px, ay - py, 64, 52)
  if proximity then
    drawPetal(g, map, camX, camY, ax, ay, variation(x + index, row), phase % 5.4, proximity, sprig)
  end
end

local function drawDockPlanters(g, map, camX, camY, x0, y0, x1, y1, player)
  local row = 1
  local px, py, now
  if player and mod.options:get("petals") ~= false then
    px, py = playerCenter(player)
    if px then now = love.timer.getTime() end
  end
  local ty = row * 2
  for i, x in ipairs(dockPlanterColumns) do
    local visible = row >= y0 and row <= y1 and x >= x0 and x <= x1
    if visible or px then
      local tx = x * 2
      -- Four $0A quarters are permanent quay paving in SHIP_PORT.
      if map:tileAt(tx, ty) == 0x0a and map:tileAt(tx + 1, ty) == 0x0a
          and map:tileAt(tx, ty + 1) == 0x0a and map:tileAt(tx + 1, ty + 1) == 0x0a then
        local sprig = i == 1 and pink or gold
        if visible then drawDockPlanter(g, x * 16 - camX, row * 16 - camY, sprig) end
        if px then drawDockPetal(g, map, camX, camY, x, row, sprig, now + (i - 1) * 2.7, px, py) end
      end
    end
  end
end

local function drawVisible(g, map, camX, camY, x0, y0, x1, y1, player, neighbor)
  if not image then loadFlowers(g) end
  g.origin()
  g.setShader()
  g.setBlendMode("alpha")
  if map.id == "VERMILION_DOCK" then
    drawDockPlanters(g, map, camX, camY, x0, y0, x1, y1, player)
    return
  end
  if map.id == "LAVENDER_TOWN" then
    g.setColor(lavenderRed, lavenderGreen, 1, 1)
  else
    g.setColor(1, 1, 1, 1)
  end
  local blocks = map.tileset and map.tileset.blocks
  local forest = map.id == "VIRIDIAN_FOREST"
  local crown = blocks and blocks[(forest and 0x02 or 0x0f) + 1]
  local sceneryFlower = outdoorFlower
  local planting = Spring.connectedPetalMaps[map.id]
  local grassDensity = map.id == "ROUTE_18" and 32 or 45
  if forest then
    sceneryFlower, grassDensity = forestFlower, 32
  elseif safariBeds[map.id] then
    sceneryFlower, grassDensity, planting = safariFlower, 16, "wildflowers"
  elseif plateauVerges[map.id] then
    sceneryFlower = plateauFlower
  end
  for y = y0, y1 do
    for x = x0, x1 do
      local seed = variation(x, y)
      local sprite, dx, dy = sceneryFlower(map, x, y, crown, seed)
      -- The bottom-left quarter contains the live encounter-grass tile.
      -- Re-read it so flowers disappear when the player uses Cut.
      if not sprite and seed < grassDensity and map.isGrassCell
          and map:isGrassCell(x, y) and grassEdge(map, x, y) then
        sprite, dx, dy = seed % 4 == 0 and pink or gold, 0, 8
      end
      if sprite then
        g.draw(image, sprite, x * 16 + dx - camX, y * 16 + dy - camY)
      end
    end
  end
  if (forest or planting) and player and mod.options:get("petals") ~= false then
    drawNearbyPetals(g, map, crown, sceneryFlower, player, camX, camY, neighbor, planting)
  end
end

function Spring.draw(g, map, camX, camY, w, h, player, neighbor)
  if failed or not map.tileAt then return end
  -- TileRenderer rounds the camera down, including at negative offsets.
  camX, camY = math.floor(camX), math.floor(camY)
  local x0 = math.max(0, math.floor(camX / 16))
  local y0 = math.max(0, math.floor(camY / 16))
  local x1 = math.min(map.widthCells - 1, math.floor((camX + w - 1) / 16))
  local y1 = math.min(map.heightCells - 1, math.floor((camY + h - 1) / 16))
  if x0 > x1 or y0 > y1 then return end
  g.push("all")
  local ok, err = pcall(drawVisible, g, map, camX, camY, x0, y0, x1, y1, player, neighbor)
  g.pop()
  if not ok then
    failed = true
    mod.log:warn("Spring flowers could not be drawn: %s", tostring(err))
  end
end

return Spring
