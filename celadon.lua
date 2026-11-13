-- Native building footprints, roof height and light positions. Keep large
-- facades and both Department Store/Mansion entrances outside ground snow.
local City={lights={},details={},roofs={},protect={},fences={},tintTrim={}}
City.buildings={
  {32,64,64,96,30},{96,96,128,128,30},{224,64,96,96,30},{352,64,96,96,30},
  {448,96,64,64,30},{512,96,64,64,30},{576,96,64,64,30},{640,96,64,64,30},
  {320,224,96,32,14},
  {416,256,96,64,30},{512,256,64,64,30},{608,256,64,64,30},{672,256,64,64,30},
  {32,384,64,64,30},{96,384,128,64,30},{224,384,64,64,30},{288,384,64,64,30},
  {416,384,64,64,30},{480,384,64,64,30},{544,384,64,64,30},{608,384,64,64,30},{672,384,64,64,30},
  {288,448,64,64,30},
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
-- A hue-only final pass survives late roof/continuation redraws while
-- leaving neutral facade pixels unchanged. These bounds never include doors.
City.finishRoofs=City.roofs
-- Reviewed flat back-door approach, kept separate from the roof/facade.
City.entranceSnow={{384,48,32,16}}
City.ledgeSnow={{32,496,48,8},{96,496,192,8}}
for _,p in ipairs({{27,15},{19,15},{42,9},{13,29},{21,9},{12,13},{39,21},{33,21},{27,21}}) do
  City.tintTrim[#City.tintTrim+1]={p[1]*16,p[2]*16,16,16}
end
for _,r in ipairs(City.ledgeSnow) do City.tintTrim[#City.tintTrim+1]={r[1],r[2],r[3],16} end
return City
