local mod = ...
local NewYear = {}
local previewStart
local colors = {{1,.76,.28}, {.98,.39,.50}, {.34,.87,.97}}
-- Centres are in world pixels above the water north of the city pier.
local displays = {{281,390,405}, {308,387,402}, {339,391,406}}
local paper = {{1,3,1},{3,10,2},{7,5,3},{9,12,1},{13,8,2},{12,2,3},{5,14,3}}

function NewYear.resetPreview()
  previewStart=nil
end

function NewYear.confetti(mode,date)
  return mode=="new_year" or ((mode==nil or mode=="auto") and date and date.month==1 and date.day==1)
end

function NewYear.hasPaper(map,x,y)
  return map.id=="VERMILION_CITY" and x==20 and y==26 and map.tileAt
    and map:tileAt(40,52)==0x3c and map:tileAt(41,52)==0x3c
    and map:tileAt(40,53)==0x3c and map:tileAt(41,53)==0x3c
end

-- Time relative to midnight. Outside the one-hour show only the paper remains.
function NewYear.showTime(mode,date,fraction,now)
  if mode=="new_year" then
    if not previewStart or now<previewStart then previewStart=now end
    return (now-previewStart)%18
  end
  if (mode and mode~="auto") or not date or not date.hour or not date.min then return end
  local second=date.hour*3600+date.min*60+(date.sec or 0)
  if date.month==12 and date.day==31 and second>=84600 then return second-86400+fraction end
  if date.month==1 and date.day==1 and second<1800 then return second+fraction end
end

local function light(g,color,alpha)
  g.setColor(color[1],color[2],color[3],alpha)
end
local function pixel(g,x,y,w,h)
  g.rectangle("fill",math.floor(x),math.floor(y),w,h)
end

local function firework(g,map,cx,cy,index,age)
  if age<0 or age>=2.25 then return end
  local pos,color=displays[index],colors[index]
  local x,y,waterY=pos[1],pos[2],pos[3]
  if age<.55 then
    local rise=age/.55
    local tip=y+(waterY-y)*(1-rise)^2
    light(g,color,1)
    pixel(g,x-cx,tip-cy,2,2)
    light(g,color,.65)
    pixel(g,x-cx,tip+3-cy,1,3)
    return
  end
  local t=(age-.55)/1.7
  local radius=2+17*(1-(1-t)^2)
  light(g,color,1-t*.85)
  for ray=0,11 do
    local angle=ray*math.pi/6+index*.17
    local dx,dy=math.cos(angle)*radius,math.sin(angle)*radius
    pixel(g,x+dx-cx,y+dy+t*t*8-cy,2,2)
    pixel(g,x+dx*.8-cx,y+dy*.8+t*t*8-cy,1,1)
  end
  if t<.22 then
    g.setColor(1,.96,.83,1-t*3)
    pixel(g,x-1-cx,y-1-cy,3,3)
  end
  -- Short shimmering dashes on live open water only.
  light(g,color,.64*(1-t))
  for j=0,4 do
    local wx=x+math.floor(math.sin(j*2+t*9)*5)
    local wy=waterY+j*2
    if map:tileAt(math.floor(wx/8),math.floor(wy/8))==0x14
        and map:tileAt(math.floor((wx+4)/8),math.floor(wy/8))==0x14 then
      pixel(g,wx-cx,wy-cy,5-j,1)
    end
  end
end

local function paint(g,map,cx,cy,show,hasPaper)
  g.origin();g.setShader();g.setBlendMode("alpha")
  if hasPaper and NewYear.hasPaper(map,20,26) then
    for _,p in ipairs(paper) do
      light(g,colors[p[3]],1)
      pixel(g,320+p[1]-cx,416+p[2]-cy,2,1)
    end
  end
  if not show then return end
  if show>=0 and show<5 then
    for i=1,3 do firework(g,map,cx,cy,i,show+.55-(i-1)*1.25) end
  else
    local beat=show%15
    firework(g,map,cx,cy,1+math.floor(show/15)%3,beat)
  end
end

local failed=false
function NewYear.draw(g,map,camX,camY,w,h,mode,date,checkedAt)
  if failed or not map.tileAt then return end
  if camX+w<=258 or camX>=362 or camY+h<=336 or camY>=432 then
    previewStart=nil
    return
  end
  local now=love.timer.getTime()
  local show
  local ready=camX<=263 and camX+w>=357 and camY<=369 and camY+h>=413
  if mode~="new_year" or previewStart or ready then
    show=NewYear.showTime(mode,date,math.max(0,math.min(.999,now-checkedAt)),now)
  end
  local hasPaper=NewYear.confetti(mode,date)
  if not show and not hasPaper then return end
  g.push("all")
  local ok,err=pcall(paint,g,map,math.floor(camX),math.floor(camY),show,hasPaper)
  g.pop()
  if not ok then failed=true;mod.log:warn("New Year harbour drawing failed: %s",tostring(err)) end
end
return NewYear
