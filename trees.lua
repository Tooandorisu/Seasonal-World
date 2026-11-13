-- One occupied 16x16 base cell per tree. Foliage may overhang cells above,
-- like the engine's normal tall scenery; packages remain decorative.
local Trees = {
  { x = 9, y = 6, message = "Warm lights shine\nthrough the snow.\nMay your journey\nbe full of joy!\nMerry Christmas!" },
  { x = 3, y = 11, message = "Gifts for friends\nand POKEMON!\nThe best gift is\nbeing together." },
}
local viridian = {
  { x = 18, y = 20, message = "A little warmth\non a snowy day.\nMerry Christmas,\nVIRIDIAN CITY!" },
}
local pewter = {
  { x = 18, y = 26, message = "Snow on the roofs,\nwarmth in our hearts.\nMerry Christmas,\nPEWTER CITY!" },
}
local cerulean = {
  { x = 20, y = 22, message = "Warm wishes beside\nthe winter waters.\nMerry Christmas,\nCERULEAN CITY!" },
}
local vermilion = {
  { x = 19, y = 11, message = "Warm lights by\nthe winter harbour.\nMerry Christmas,\nVERMILION CITY!" },
}
local lavender = {
  { x = 12, y = 14, message = "A quiet light\nfor every friend.\nMerry Christmas,\nLAVENDER TOWN!" },
}
local celadon = {
  { x = 18, y = 20, message = "City lights glow\nthrough the snow.\nMerry Christmas,\nCELADON CITY!" },
}
local fuchsia = {
  { x = 20, y = 20, message = "Warm wishes to\nfriends big and small.\nMerry Christmas,\nFUCHSIA CITY!" },
}
local saffron = {
  { x = 26, y = 14, message = "Bright lights for\na peaceful city.\nMerry Christmas,\nSAFFRON CITY!" },
}
local cinnabar = {
  { x = 11, y = 6, message = "Warm island lights\non a winter night.\nMerry Christmas,\nCINNABAR ISLAND!" },
}
local indigo = {
  { x = 9, y = 11, message = "A light for every\ntrainer who made it.\nMerry Christmas,\nINDIGO PLATEAU!" },
}
local safari = {
  { x = 16, y = 22, message = "Warm wishes for\nyour safari.\nMerry Christmas!" },
}
local empty = {}

function Trees.forMap(map)
  if not map or map.id == "PALLET_TOWN" then return Trees end
  local locations=map.id=="VIRIDIAN_CITY" and viridian or map.id=="PEWTER_CITY" and pewter or map.id=="CERULEAN_CITY" and cerulean or map.id=="VERMILION_CITY" and vermilion or map.id=="LAVENDER_TOWN" and lavender or map.id=="CELADON_CITY" and celadon or map.id=="FUCHSIA_CITY" and fuchsia or map.id=="SAFFRON_CITY" and saffron or map.id=="CINNABAR_ISLAND" and cinnabar or map.id=="INDIGO_PLATEAU" and indigo
  if map.id=="SAFARI_ZONE_CENTER" then locations=safari end
  if not locations then return empty end
  -- Fail closed on modified maps. Check the trunk and its bypass cells.
  if type(map.isWalkableCell) ~= "function" then return empty end
  local tree=locations[1]
  local x,y=tree.x,tree.y
  local clearance={{x,y},{x-1,y},{x+1,y},{x,y-1},{x,y+1}}
  if locations==indigo then
    -- The west edge is already bounded by statues. Keep the entire
    -- parallel lane open so both doors remain reachable from Route 23.
    clearance={{x,y},{x,y-1},{x,y+1},{x+1,y-1},{x+1,y},{x+1,y+1}}
  end
  for _, p in ipairs(clearance) do
    if not map:isWalkableCell(p[1],p[2])
        or (map.isWaterCell and map:isWaterCell(p[1],p[2]))
        or (map.warpAtCell and map:warpAtCell(p[1],p[2]))
        or (map.signAtCell and map:signAtCell(p[1],p[2])) then return empty end
  end
  return locations
end

function Trees.at(x, y, map)
  for _, tree in ipairs(Trees.forMap(map)) do
    if tree.x == x and tree.y == y then return tree end
  end
end

return Trees
