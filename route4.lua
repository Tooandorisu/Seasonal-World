local function layout(x,y,w,roofHeight,expanded)
  local eave=y+roofHeight
  local roof={x,y,w,roofHeight}
  local details={roof}
  if not expanded then
    details[#details+1]={x,eave,w,4}
    details[#details+1]={x,eave+4,14,6}
    details[#details+1]={x+w-14,eave+4,14,6}
  end
  return {
    roofs=details, details=details, warmRoofs=true, finishRoofs=details,
    lights={{x,eave,w}}, fences={},
    protect={{x,y,w,96-y}},
    tintTrim={{192,80,16,16},{272,112,16,16},{432,112,16,16}},
    ledgeSnow={{640,80,32,8},{992,80,288,8},{64,112,64,8},{896,112,384,8},
      {224,144,96,8},{384,144,320,8},{832,144,160,8},{1024,144,160,8},
      {1216,144,64,8},{64,176,128,8},{224,208,96,8},{672,208,320,8},
      {1216,208,64,8},{96,240,64,8},{192,272,32,8}},
  }
end

local compact=layout(160,32,64,30,false)
local expanded=layout(144,16,80,44,true)
expanded.tintTrim[#expanded.tintTrim+1]={144,16,80,16}

function compact.forMap(map,provider,game)
  local roofs=provider and provider.roofs
  if roofs and type(roofs.cells)=="function" and map.def then
    local ok,cells=pcall(roofs.cells,roofs,game,map.def)
    if ok and cells and cells.rows then
      for _,entry in ipairs(cells.rows[1] or {}) do
        if entry.role=="larger_center" and entry.x==11 then return expanded end
      end
    end
  end
  return compact
end

return compact
