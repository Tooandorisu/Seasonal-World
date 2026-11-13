-- Lavender's tower has windowed masonry at the northern map edge, rather
-- than a house roof. Keep that facade out of the roof recolour rectangles.
local City = {}
City.lights = {
  {32,62,64},   -- Pokemon Center
  {96,142,64},  -- Mr Fuji's house
  {224,190,64}, -- Mart
  {32,206,64},  -- Cubone house
  {96,206,64},  -- Name Rater's house
}
City.details = {
  {32,32,64,30},{96,128,64,14},{224,160,64,30},
  {32,192,64,14},{96,192,64,14},
}
for _,r in ipairs(City.lights) do
  City.details[#City.details+1]={r[1],r[2],r[3],4}
  City.details[#City.details+1]={r[1],r[2]+4,14,6}
  City.details[#City.details+1]={r[1]+r[3]-14,r[2]+4,14,6}
end
City.roofs = {}
for _,r in ipairs(City.details) do City.roofs[#City.roofs+1]=r end
-- The tower string stays in the masonry band between its window rows.
City.lights[#City.lights+1]={192,12,96}
-- Do not draw an assumed roof edge across the windowed original facade.
City.protect={{192,0,96,64},{224,80,16,16}}
City.fences = {}
City.ledgeSnow = {}
City.tintTrim={
  {176,144,16,16},{144,48,16,16},{256,208,16,16},
  {64,80,16,16},{80,144,16,16},{272,112,16,16},
}
return City
