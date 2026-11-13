-- Authored scenery bounds for the original Cerulean City layout.
-- Shared live-map snow preserves water, warps, signs and character layers.
local City = {}
City.lights = {
  {128,174,96}, -- badge house
  {224,174,96}, -- north decorative house
  {416,174,96}, -- trashed house; keep back-door event clear
  {544,174,96}, -- northeast decorative house
  {192,238,96}, -- trade house
  {288,254,64}, -- Pokemon Center
  {384,286,128}, -- Gym
  {192,382,64}, -- Bike Shop
  {384,382,64}, -- Mart
  {288,398,96}, -- south decorative house
  {448,398,96}, -- southeast decorative house
}
City.details = {
  {128,160,96,14},{224,160,96,14},{416,160,96,14},{544,160,96,14},
  {192,224,96,14},{288,224,64,30},{384,256,128,30},
  {192,352,64,30},{384,352,64,30},{288,384,96,14},{448,384,96,14},
}
for _,r in ipairs(City.lights) do
  City.details[#City.details+1]={r[1],r[2],r[3],4}
  City.details[#City.details+1]={r[1],r[2]+4,14,6}
  City.details[#City.details+1]={r[1]+r[3]-14,r[2]+4,14,6}
end
City.roofs = {}
for _,r in ipairs(City.details) do City.roofs[#City.roofs+1]=r end
-- Green between the paved backyard stones also accumulates snow.
City.details[#City.details+1]={128,128,160,32}
City.details[#City.details+1]={416,128,128,32}
City.fences = {}
-- Dry grassy cliff lips, separated around the stairs east of the Gym.
City.ledgeSnow = {{352,272,32,8},{128,240,64,8},{512,304,48,8},{576,304,32,8},
  {256,528,128,8},{384,48,32,8}}
-- Pale-green seams and embedded signs; preserve dark lettering/stone and
-- warm cliff faces through the shared bright-ground-only colour filter.
City.tintTrim = {{160,384,32,32},{256,448,32,32},
  {368,304,16,16},{320,272,16,16},{416,400,16,16},{432,336,16,16}}
for _,r in ipairs(City.ledgeSnow) do
  City.tintTrim[#City.tintTrim+1]={r[1],r[2],r[3],16}
end
return City
