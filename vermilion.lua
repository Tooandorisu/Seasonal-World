-- Authored roof/sign bounds for the original Vermilion City layout.
-- Terrain, foliage, scenery and dry deck snow follow the live map.
local City = {}
City.lights = {
  {96,30,64},   -- Old Rod house
  {160,30,64},  -- Pokemon Center
  {224,30,64},  -- northern decorative house
  {320,30,64},  -- northeast decorative house
  {128,190,64}, -- Pokemon Fan Club
  {224,190,64}, -- trade house
  {352,190,64}, -- Mart
  {128,286,96}, -- Gym
  {352,286,64}, -- Pidgey house
}
City.details = {
  {96,0,64,30},{160,0,64,30},{224,0,64,30},{320,0,64,30},
  {128,160,64,30},{224,160,64,30},{352,160,64,30},
  {128,256,96,30},{352,256,64,30},
}
for _,r in ipairs(City.lights) do
  City.details[#City.details+1]={r[1],r[2],r[3],4}
  City.details[#City.details+1]={r[1],r[2]+4,14,6}
  City.details[#City.details+1]={r[1]+r[3]-14,r[2]+4,14,6}
end
City.roofs = {}
for _,r in ipairs(City.details) do City.roofs[#City.roofs+1]=r end
-- Warm roof palettes need the same snow treatment as blue/neutral ones.
-- This flag applies only within the roof rectangles above.
City.warmRoofs = true
City.fences = {}
City.ledgeSnow = {}
City.tintTrim = {
  {432,48,16,16},{592,208,16,16},{384,208,16,16},{192,48,16,16},
  {112,208,16,16},{112,304,16,16},{464,240,16,16},
}
return City
