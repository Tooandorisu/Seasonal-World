-- Authored scenery bounds checked against Pewter's original map layout.
-- The shared live-map renderer supplies terrain, trees, fences and stones.
local City = {}
City.lights = {
  {160,94,128}, -- museum main hall: two-storey roof
  {288,62,96},  -- museum east wing
  {448,206,64}, -- Nidoran house
  {192,254,96}, -- Gym
  {352,254,64}, -- Mart
  {192,382,64}, -- Pokemon Center
  {96,462,64},  -- speech house
}
City.details = {
  {160,32,128,62}, {288,32,96,30},
  {448,192,64,14}, {192,224,96,30}, {352,224,64,30},
  {192,352,64,30}, {96,448,64,14},
}
for _,r in ipairs(City.lights) do
  City.details[#City.details+1]={r[1],r[2],r[3],4}
  City.details[#City.details+1]={r[1],r[2]+4,14,6}
  City.details[#City.details+1]={r[1]+r[3]-14,r[2]+4,14,6}
end
-- Include the neutral/lilac fascia and corner awnings in roof snow too.
City.roofs = {}
for _,r in ipairs(City.details) do City.roofs[#City.roofs+1]=r end
-- Native fence caps use live atlas tiles in surfaces.lua. Avoid guessed
-- full-width strips across the sign embedded in the garden fence.
City.fences = {}
-- Only the grassy 8px lip above the brown cliff. Split around the
-- stairs and boundary bushes; neither should receive opaque ground snow.
City.ledgeSnow = {
  {64,112,48,8}, {128,112,32,8},
  {288,112,144,8}, {448,112,48,8}, {512,112,48,8},
  {352,464,48,8}, {416,464,64,8},
}
-- Pale-green residue across the full garden fence row and lower ledge seams.
-- Unlike opaque ground snow, this pass preserves dark sign text/outlines,
-- brown cliff faces and the stairs excluded from ledgeSnow.
City.tintTrim = {{320,352,192,32}}
for _,r in ipairs(City.ledgeSnow) do
  City.tintTrim[#City.tintTrim+1]={r[1],r[2],r[3],16}
end
return City
