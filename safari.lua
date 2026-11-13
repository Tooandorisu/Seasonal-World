local function layout(houses, signs)
  local roofs, lights, protect, trim = {}, {}, {}, {}
  for _, house in ipairs(houses) do
    local x,y=house[1],house[2]
    roofs[#roofs+1]={x,y,64,16}
    lights[#lights+1]={x+3,y+15,58}
    protect[#protect+1]={x,y,64,32}
  end
  for _, sign in ipairs(signs) do
    trim[#trim+1]={sign[1]*16,sign[2]*16,16,16}
  end
  return {
    roofs=roofs, details=roofs, finishRoofs=roofs, warmRoofs=true,
    protect=protect, lights=lights, tintTrim=trim, fences={}, ledgeSnow={},
  }
end

return {
  SAFARI_ZONE_CENTER=layout({{256,288}},{{18,20},{14,22}}),
  SAFARI_ZONE_EAST=layout({{384,128}},{{26,10},{6,4},{5,23}}),
  SAFARI_ZONE_NORTH=layout({{544,32}},{{36,4},{4,25},{13,31},{19,33},{26,28}}),
  SAFARI_ZONE_WEST=layout({{32,32},{160,160}},{{12,12},{17,3},{26,4},{24,22}}),
}
