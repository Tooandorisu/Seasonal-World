-- SHIP_PORT is not the city's OVERWORLD atlas. Select only its flat ground,
-- gangway and authored upper-ship surfaces; leave water and hull faces alone.
local Dock = {}
Dock.lights={{32,30,176},{256,30,160}}
local bands={{192,48,64,24},{176,64,16,8},{256,64,16,8}}
local cargoTops={{0,0,32,8},{0,16,32,8},{416,0,32,8},{416,16,32,8},{320,0,32,8}}
local function contains(rect,x,y)
  return x>=rect[1] and x<rect[1]+rect[3] and y>=rect[2] and y<rect[2]+rect[4]
end
function Dock.regions(map,camX,camY,w,h,animation)
  local ground,deck,ship={},{},{}
  local blocks=map.tileset and map.tileset.blocks
  if not blocks or type(map.tileAt)~="function" then return ground,deck,ship end
  local landIds,waterIds,gangwayIds={},{},{}
  for _,id in ipairs(blocks[0x0c+1] or {}) do landIds[id]=true end
  -- The first 16px of block $16 is the flat pier, not water below it.
  for i=1,8 do local id=(blocks[0x16+1] or {})[i]; if id then landIds[id]=true end end
  for _,id in ipairs(blocks[0x0d+1] or {}) do waterIds[id]=true end
  local gangway=blocks[0x15+1] or {}
  for i=1,2 do if gangway[i] then gangwayIds[gangway[i]]=true end end
  local function shipTop(x,y)
    for _,r in ipairs(bands) do if contains(r,x,y) then return true end end
    return false
  end
  local width,height=(map.widthCells or 0)*2,(map.heightCells or 0)*2
  for ty=math.max(0,math.floor(camY/8)),math.min(height-1,math.floor((camY+h-1)/8)) do
    for tx=math.max(0,math.floor(camX/8)),math.min(width-1,math.floor((camX+w-1)/8)) do
      local x,y=tx*8,ty*8
      local id=map:tileAt(tx,ty)
      if not waterIds[id] then
        if landIds[id] then ground[#ground+1]={x,y,8,8}
        elseif gangwayIds[id] and x>=224 and x<240 and y<48 then deck[#deck+1]={x,y,8,8}
        elseif not animation and shipTop(x,y) then ship[#ship+1]={x,y,8,8}
        else
          for _,r in ipairs(cargoTops) do
            if contains(r,x,y) then deck[#deck+1]={x,y,8,8};break end
          end
        end
      end
    end
  end
  -- The engine floods the original ship cells before drawing its snapshot.
  -- Follow the snapshot's actual offset; its top 16px stay at the gangway.
  if animation then
    for row,tiles in ipairs(animation.tiles or {}) do
      if row<=2 or not animation.gone then
        local slide=row>2 and (animation.off or 0) or 0
        for col,id in ipairs(tiles) do
          local x,y=animation.px+(col-1)*8,animation.py+(row-1)*8
          if not waterIds[id] then
            if row<=2 and gangwayIds[id] and x>=224 and x<240 then
              deck[#deck+1]={x,y,8,8}
            elseif row>2 and shipTop(x,y) then ship[#ship+1]={x-slide,y,8,8} end
          end
        end
      end
    end
  end
  return ground,deck,ship
end

Dock.effect=[[
extern float kind;
extern vec2 origin;
vec4 effect(vec4 color, Image image, vec2 uv, vec2 pixel) {
  vec4 c=Texel(image,uv);
  if (kind<1.5) {
    vec2 p=floor(pixel)+origin;
    float grain=step(17.0,mod(floor(p.x/2.0)*17.0+floor(p.y/2.0)*31.0,19.0));
    c.rgb=mix(vec3(0.91,0.96,0.99),vec3(0.99,1.0,1.0),grain);
  } else {
    float brightness=dot(c.rgb,vec3(0.299,0.587,0.114));
    float chroma=max(c.r,max(c.g,c.b))-min(c.r,min(c.g,c.b));
    bool warm=c.r>c.b*1.08 && c.g>c.b*1.03 && c.r>=c.g*0.85;
    if (brightness>0.28 && brightness<0.94 && (chroma<0.22 || warm)) {
      c.rgb=mix(vec3(0.82,0.90,0.96),vec3(0.98,0.99,1.0),smoothstep(0.28,0.90,brightness));
    }
  }
  return c*color;
}
]]
local canvas,shader,cw,ch,failed
function Dock.draw(g,map,camX,camY,w,h,warn,animation)
  if failed then return end
  local ground,deck,ship=Dock.regions(map,camX,camY,w,h,animation)
  if #ground==0 and #deck==0 and #ship==0 then return end
  local source=g.getCanvas()
  if not source then return end
  g.push("all")
  local ok,err=pcall(function()
    if not shader then shader=g.newShader(Dock.effect) end
    if not canvas or cw~=w or ch~=h then
      if canvas and canvas.release then canvas:release() end
      canvas=nil
      canvas=g.newCanvas(w,h);canvas:setFilter("nearest","nearest");cw,ch=w,h
    end
    g.origin();g.setColor(1,1,1,1);g.setBlendMode("alpha","premultiplied")
    shader:send("origin",{camX,camY})
    for kind,regions in ipairs({ground,deck,ship}) do
      if #regions>0 then
        g.setScissor();g.setCanvas(canvas);g.clear(0,0,0,0)
        shader:send("kind",kind);g.setShader(shader);g.draw(source,0,0)
        g.setCanvas(source);g.setShader()
        for _,r in ipairs(regions) do
          local x0,y0=math.max(0,r[1]-camX),math.max(0,r[2]-camY)
          local x1,y1=math.min(w,r[1]+r[3]-camX),math.min(h,r[2]+r[4]-camY)
          if x1>x0 and y1>y0 then g.setScissor(x0,y0,x1-x0,y1-y0);g.draw(canvas,0,0) end
        end
      end
    end
  end)
  g.setCanvas(source);g.pop()
  if not ok then
    failed=true
    if canvas and canvas.release then canvas:release() end
    if shader and shader.release then shader:release() end
    canvas,shader=nil,nil
    warn("Dock snow could not be drawn: %s",tostring(err))
  end
end
return Dock
