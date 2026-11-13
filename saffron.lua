-- Source building footprints, including the decorative outer city blocks.
local City={buildings={},lights={},details={},roofs={},protect={},fences={},ledgeSnow={},tintTrim={}}
local function add(x,y,w,h,roof)
  City.buildings[#City.buildings+1]={x,y,w,h,roof}
end
add(352,0,96,64,30) -- Fighting Dojo
add(448,0,128,64,30) -- Gym
add(576,16,64,48,14)
for _,x in ipairs({32,96,160}) do add(x,48,64,48,14) end -- includes Copycat
for _,x in ipairs({64,128,192,448,512}) do add(x,144,64,48,14) end
add(384,128,64,64,30) -- Mart
add(256,160,128,192,30) -- Silph Co.; preserve every windowed floor
for _,x in ipairs({96,160,384,448,512}) do add(x,256,64,96,30) end
for _,x in ipairs({64,192,256,320,512}) do add(x,432,64,48,14) end
add(128,416,64,64,30) -- Pokemon Center
add(448,416,64,64,30) -- Mr Psychic
add(0,512,64,64,30)
for _,x in ipairs({64,128,192,256,384,448,512}) do add(x,528,64,48,14) end
add(576,512,64,64,30)
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
for _,p in ipairs({{17,5},{27,5},{35,5},{26,11},{39,19},{5,21},{15,21},{10,29},{27,29},{1,19}}) do
  City.tintTrim[#City.tintTrim+1]={p[1]*16,p[2]*16,16,16}
end
return City
