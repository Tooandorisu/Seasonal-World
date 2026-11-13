-- Original city exteriors only; Safari Zone interior/maps remain unchanged.
local City={lights={},details={},roofs={},protect={},fences={},tintTrim={}}
City.buildings={
  {256,0,96,64,30}, -- Safari Zone gate
  {64,160,64,64,30}, -- Mart
  {320,160,96,64,30}, -- meeting room
  {64,384,96,64,30}, -- Gym
  {160,416,64,32,14}, -- Bill's grandpa's house
  {224,416,64,32,14}, -- decorative house
  {288,384,64,64,30}, -- Pokemon Center
  {416,400,64,48,14}, -- Warden's house; upper 16px are backyard ground
  {480,400,64,48,14}, -- Good Rod house with a north-side entrance
}
for _,b in ipairs(City.buildings) do
  City.protect[#City.protect+1]={b[1],b[2],b[3],b[4]}
  City.details[#City.details+1]={b[1],b[2],b[3],b[5]}
  local y=b[2]+b[5]
  City.lights[#City.lights+1]={b[1],y,b[3]}
  City.details[#City.details+1]={b[1],y,b[3],4}
  City.details[#City.details+1]={b[1],y+4,14,6}
  City.details[#City.details+1]={b[1]+b[3]-14,y+4,14,6}
end
for _,r in ipairs(City.details) do City.roofs[#City.roofs+1]=r end
City.warmRoofs=true
City.finishRoofs=City.roofs
-- Flat north-side door approach, separate from the house roof/facade.
City.entranceSnow={{496,384,16,16}}
City.ledgeSnow={{64,496,96,8},{256,496,96,8}}
for _,p in ipairs({{15,23},{25,15},{17,5},{6,13},{20,27},{27,29},{21,15},
    {5,29},{33,7},{27,7},{13,7},{31,13},{13,15},{7,7}}) do
  City.tintTrim[#City.tintTrim+1]={p[1]*16,p[2]*16,16,16}
end
for _,r in ipairs(City.ledgeSnow) do City.tintTrim[#City.tintTrim+1]={r[1],r[2],r[3],16} end
return City
