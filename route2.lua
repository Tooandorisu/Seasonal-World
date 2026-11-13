local roofs={
  {176,104,96,40},  -- Diglett's Cave, flat top above the entrance
  {32,192,64,30},   -- Viridian Forest north gate
  {224,288,64,14},  -- trade house
  {224,576,96,30},  -- Route 2 Gate
  {32,640,64,30},   -- Viridian Forest south gate
}

local details={}
for _,roof in ipairs(roofs) do details[#details+1]=roof end
for i=2,#roofs do
  local roof=roofs[i]
  local x,y,w,h=roof[1],roof[2],roof[3],roof[4]
  details[#details+1]={x,y+h,w,4}
  details[#details+1]={x,y+h+4,14,6}
  details[#details+1]={x+w-14,y+h+4,14,6}
end

return {
  roofs=roofs, details=details, warmRoofs=true,
  protect={{160,96,128,64},{32,192,64,64},{224,288,64,32},
    {224,576,96,64},{32,640,64,64}},
  tintTrim={{176,176,16,16},{80,1040,16,16}},
  -- Walkable back approaches share cells with the gate warps.
  entranceSnow={{48,176,16,16},{256,560,16,16}},
  lights={}, fences={},
  -- Grass lips on the upper side of the ledges, including stair blocks.
  ledgeSnow={{0,304,128,8},{224,432,96,8},{224,496,96,8},
    {224,688,96,8},{0,752,128,8},{192,784,128,8},{32,976,160,8},{224,976,96,8}},
}
