pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
--menu
state=0
menu_items={"start","sound","quit"}
selected_item=1
sound_on=true
current_level=1
prev_mb=0
player_coins=0
levels={
 {s=0,e=200},
 {s=200,e=400},
 {s=400,e=600},
 {s=600,e=800},
 {s=800,e=1024}
}

function _init()
  poke(0x5f2d, 1) -- enable mouse
  music(0)
  game_init()
end

function _update()
  local mx=stat(32)
  local my=stat(33)
  local mb=stat(34)
  local mb_clicked = (mb%2)==1 and (prev_mb%2)==0

  if state==0 then

    
    if btnp(2) then selected_item-=1 if selected_item<1 then selected_item=#menu_items end end
    if btnp(3) then selected_item+=1 if selected_item>#menu_items then selected_item=1 end end
    
    if menu_items[selected_item]=="sound" then
       if btnp(0) or btnp(1) then
         sound_on = not sound_on
         if sound_on then music(0) else music(-1) end
       end
    end
    
    if mb_clicked then
      if my>=51 and my<=59 then
         selected_item=1
         if mx>=30 and mx<=90 then
           state=1
           current_level=1
           player_coins=0
           game_init()
         end
      elseif my>=61 and my<=69 then
         selected_item=2
         if mx>=30 and mx<=110 then
           sound_on = not sound_on
           if sound_on then music(0) else music(-1) end
         end
      elseif my>=71 and my<=79 then
         selected_item=3
         if mx>=30 and mx<=90 then
           stop()
         end
      end
    end
    
    if btnp(4) or btnp(5) then
      if menu_items[selected_item]=="start" then
        state=1
        current_level=1
        player_coins=0
        game_init()
      elseif menu_items[selected_item]=="sound" then
        sound_on = not sound_on
        if sound_on then music(0) else music(-1) end
      elseif menu_items[selected_item]=="quit" then
        stop()
      end
    end
  elseif state==1 then
    game_update()
  elseif state==2 then
    local btn_hover = mx>=24 and mx<=104 and my>=70 and my<=86
    if btnp(5) or (mb_clicked and btn_hover) then
       current_level+=1
       if current_level > #levels then
          current_level = 1
          state=0
       else
          game_init()
          state=1
       end
    end
  elseif state==3 then
    local btn_hover = mx>=34 and mx<=94 and my>=70 and my<=86
    if btnp(5) or (mb_clicked and btn_hover) then
       game_init()
       state=1
    end
  end

  prev_mb = mb
end

function _draw()
  if state==0 then
    camera()
    cls()
    print("the lost seals", 36, 20, 7)
    for i, item in ipairs(menu_items) do
      local y=45+i*10
      local c=6
      if i==selected_item then c=7 print(">",36,y,7) end
      
      if item=="sound" then
        local txt = "sound: on"
        if not sound_on then txt = "sound: off" end
        print(txt,44,y,c)
      else
        print(item,44,y,c)
      end
    end
    
    --draw mouse
    local mx=stat(32)
    local my=stat(33)
    line(mx,my,mx+2,my+2,7)
    line(mx,my,mx,my+3,7)
    
  elseif state==1 then
    game_draw()
  elseif state==2 then
    camera()
    cls()
    if current_level == #levels then
      print("finish game", 42, 30, 7)
    else
      print("level "..current_level.." completed", 30, 30, 7)
      print("seal collected!", 34, 45, 10)
      spr(12, 60, 54, 1, 1)
    end
    
    local mx=stat(32)
    local my=stat(33)
    local btn_hover = mx>=24 and mx<=104 and my>=70 and my<=86
    local c = btn_hover and 7 or 6
    rectfill(24,70,104,86,1)
    rect(24,70,104,86,c)
    local next_lvl = current_level + 1
    if next_lvl > #levels then
       print("go back to menu", 34, 76, c)
    else
       print("go to level "..next_lvl, 38, 76, c)
    end
    
    -- draw mouse cursor
    line(mx,my,mx+2,my+2,7)
    line(mx,my,mx,my+3,7)
  elseif state==3 then
    camera()
    cls()
    print("game over!", 44, 40, 8)
    
    local mx=stat(32)
    local my=stat(33)
    local btn_hover = mx>=34 and mx<=94 and my>=70 and my<=86
    local c = btn_hover and 7 or 6
    rectfill(34,70,94,86,1)
    rect(34,70,94,86,c)
    print("restart", 50, 76, c)
    
    -- draw mouse cursor
    line(mx,my,mx+2,my+2,7)
    line(mx,my,mx,my+3,7)
  end
end
-->8
--variables

function game_init()
  -- set flags for our test tiles (10=solid, 11=spike, 12=seal)
  fset(10, 0, true) -- set flag 0 for tile 10
  fset(34, 0, true) -- solid platform
  fset(70, 0, false) -- not solid from top
  fset(70, 1, true) -- solid horizontally
  
  -- collect coin, heart, key, and spring map coordinates
  coins = {}
  hearts = {}
  keys = {}
  springs = {}
  for x=0,127 do
    for y=0,31 do
      local t = mget(x,y)
      if t >= 17 and t <= 20 then
        add(coins, {mx=x, my=y})
      elseif t == 40 or t == 41 then
        add(hearts, {mx=x, my=y})
      elseif t == 84 or t == 85 then
        add(keys, {mx=x, my=y})
      elseif t == 97 then
        add(springs, {mx=x, my=y, timer=0})
      end
    end
  end
  -- vertical walls (cannot stand on them, blocks horizontally)
  for i in all({64,65,66,67,80,81,91}) do
    fset(i, 0, false)
    fset(i, 1, true)
  end
  
  fset(99, 0, true) -- solid floor
  fset(99, 1, true) -- solid wall
  for i in all({68,69,82,83}) do
    fset(i, 0, true)
    fset(i, 1, true)
  end
  fset(11, 2, true) -- set flag 2 for tile 11
  fset(12, 3, true) -- set flag 3 for tile 12 (seal)
  fset(13, 3, true) -- set flag 3 for tile 13 (seal with background)
  
  --castle background has no colliders
  for i=72,79 do fset(i, 0) end

  player={
    sp=1,
    x=59,
    y=59,
    w=8,
    h=8,
    flp=false,
    dx=0,
    dy=0,
    max_dx=2,
    max_dy=3,
    acc=0.5,
    boost=3.1,
    anim=0,
    running=false,
    jumping=false,
    falling=false,
    sliding=false,
    landed=false,
    hp=3,
    keys=0,
    key_inv={},
    invuln_timer=0
  }
  
  ui_message = ""
  ui_message_timer = 0
  
  gravity=0.3
  friction=0.85
  
  --camera
  cam_x=0
  
  --map limits
  map_start=levels[current_level].s
  map_end=levels[current_level].e
  
  if current_level == 2 then
    player.x = 26 * 8
    player.y = 4 * 8
  elseif current_level == 3 then
    player.x = 52 * 8
    player.y = 14 * 8
  elseif current_level == 4 then
    player.x = 77 * 8
    player.y = 5 * 8
  elseif current_level == 5 then
    player.x = 100 * 8
    player.y = 14 * 8
  else
    player.x = map_start + 24
    player.y = 112
  end
end

-->8
--update and draw

function game_update()
  if ui_message_timer > 0 then
    ui_message_timer -= 1
  end
  player_update()
  player_animate()
  
  -- animate springs
  for s in all(springs) do
    if s.timer > 0 then
      s.timer -= 1
      if s.timer == 0 then
        mset(s.mx, s.my, 97)
      end
    end
  end
  
  -- animate coins on the map
  local coin_frame = 17 + flr(time()*8) % 4
  for c in all(coins) do
    mset(c.mx, c.my, coin_frame)
  end
  
  -- animate keys on the map
  local key_frame = 84 + (flr(time()*4) % 2)
  for k in all(keys) do
    mset(k.mx, k.my, key_frame)
  end
  
  -- animate hearts on the map
  local heart_frame = 40 + (flr(time()*4) % 2)
  for h in all(hearts) do
    mset(h.mx, h.my, heart_frame)
  end
  
  --simple camera
  cam_x=player.x-64+(player.w/2)
  if cam_x<map_start then
    cam_x=map_start
  end
  if cam_x>map_end-128 then
    cam_x=map_end-128
  end
  camera(cam_x,0)
end

function game_draw()
  cls(12)
  map(0,0)
  
  -- draw player (blinking if invincible)
  if player.invuln_timer == 0 or (player.invuln_timer % 8) < 4 then
    pal(12, 0) -- change player's light blue color to black
    spr(player.sp,player.x,player.y,1,1,player.flp)
    pal() -- reset palette
  end
  
  -- draw health UI
  camera()
  local anim_offset = (flr(time()*4) % 2) * 16
  for i=1,3 do
    local sp_id = 39 -- broken heart
    if i <= player.hp then sp_id = 38 end -- full heart
    spr(sp_id + anim_offset, 2 + (i-1)*10, 2)
  end
  
  -- draw coin UI
  local coin_frame = 49 + flr(time()*8) % 4
  local txt = "x"..player_coins
  local txt_w = #txt * 4
  local tx = 126 - txt_w
  spr(coin_frame, tx - 10, 2)
  print(txt, tx, 4, 7)
  
  -- draw key UI
  local total_keys = player.keys + #player.key_inv
  if total_keys > 0 then
    local txt2 = "x"..total_keys
    local tx2 = tx - 30
    spr(86 + (flr(time()*4) % 2), tx2 - 10, 2)
    print(txt2, tx2, 4, 7)
  end
  
  if ui_message_timer > 0 then
    local txt_w = #ui_message * 4
    local cx = cam_x + 64 - (txt_w/2)
    rectfill(cx - 2, 60, cx + txt_w + 1, 68, 0)
    print(ui_message, cx, 62, 7)
  end
end
-->8
--collisions

function is_solid(px, py, flag)
 local tile_x = flr(px/8)
 local tile_y = flr(py/8)
 local t = mget(tile_x, tile_y)
 
 if t == 112 or t == 119 then
   if flag == 1 then return false end -- don't block horizontally
   return (py % 8) >= 7 - (px % 8) -- bottom right diagonal slope (/)
 end
 
 if t == 114 then
   if flag == 1 then return false end -- don't block horizontally
   return (py % 8) >= (px % 8)  -- bottom left diagonal slope (\)
 end
 
 if t == 116 then
   if flag == 1 then return false end -- don't block horizontally
   return (py % 8) <= 7 - (px % 8) -- top left diagonal slope (/)
 end
 
 return fget(t, flag)
end

function collide_map(obj,aim,flag)
 --obj = table needs x,y,w,h
 --aim = left,right,up,down
 
 local x=obj.x  local y=obj.y
 local w=obj.w  local h=obj.h
 
 local x1=0  local y1=0
 local x2=0  local y2=0
 
 if aim=="left" then
   x1=x-1  y1=y
   x2=x    y2=y+h-1
 
 elseif aim=="right" then
   x1=x+w-1   y1=y
   x2=x+w     y2=y+h-1
 
 elseif aim=="up" then
   x1=x+2    y1=y-1
   x2=x+w-3  y2=y
 
 elseif aim=="down" then
   x1=x+2    y1=y+h
   x2=x+w-3  y2=y+h
 end
 
 if is_solid(x1,y1,flag)
 or is_solid(x1,y2,flag)
 or is_solid(x2,y1,flag)
 or is_solid(x2,y2,flag) then
   return true
 else
   return false
 end
end

function check_hazard(obj)
 local x1=(obj.x+2)/8
 local y1=(obj.y+2)/8
 local x2=(obj.x+obj.w-3)/8
 local y2=(obj.y+obj.h-1)/8
 
 if fget(mget(x1,y1), 2)
 or fget(mget(x1,y2), 2)
 or fget(mget(x2,y1), 2)
 or fget(mget(x2,y2), 2) then
   return true
 end
 return false
end

function check_seal(obj)
 local x1=(obj.x+2)/8
 local y1=(obj.y+2)/8
 local x2=(obj.x+obj.w-3)/8
 local y2=(obj.y+obj.h-1)/8
 
 if fget(mget(x1,y1), 3)
 or fget(mget(x1,y2), 3)
 or fget(mget(x2,y1), 3)
 or fget(mget(x2,y2), 3) then
   return true
 end
 return false
end

function check_coin(obj)
  local picked_up = 0
  for c in all(coins) do
    local cx = c.mx * 8
    local cy = c.my * 8
    if obj.x < cx + 8 and obj.x + obj.w > cx and obj.y < cy + 8 and obj.y + obj.h > cy then
      mset(c.mx, c.my, 73)
      del(coins, c)
      picked_up += 1
    end
  end
  return picked_up
end

function check_heart(obj)
  local picked_up = 0
  for h in all(hearts) do
    local cx = h.mx * 8
    local cy = h.my * 8
    if obj.x < cx + 8 and obj.x + obj.w > cx and obj.y < cy + 8 and obj.y + obj.h > cy then
      mset(h.mx, h.my, 73)
      del(hearts, h)
      picked_up += 1
    end
  end
  return picked_up
end

function check_key(obj)
  local picked_up = false
  for k in all(keys) do
    local cx = k.mx * 8
    local cy = k.my * 8
    if obj.x < cx + 8 and obj.x + obj.w > cx and obj.y < cy + 8 and obj.y + obj.h > cy then
      mset(k.mx, k.my, 73)
      
      if k.mx == 102 and k.my == 9 then
        add(player.key_inv, 1)
      elseif k.mx == 125 and k.my == 5 then
        add(player.key_inv, 2)
      else
        player.keys += 1
      end
      
      del(keys, k)
      picked_up = true
    end
  end
  return picked_up
end

function check_door(obj)
  local tx1 = flr((obj.x-1)/8)
  local tx2 = flr((obj.x+obj.w)/8)
  local ty1 = flr((obj.y-1)/8)
  local ty2 = flr((obj.y+obj.h)/8)
  
  local tiles = {
    {x=tx1, y=flr((obj.y+obj.h/2)/8)},
    {x=tx2, y=flr((obj.y+obj.h/2)/8)},
    {x=flr((obj.x+obj.w/2)/8), y=ty1},
    {x=flr((obj.x+obj.w/2)/8), y=ty2}
  }
  
  for p in all(tiles) do
    if mget(p.x, p.y) == 70 then
      local door_id = 0
      if p.x == 120 and (p.y == 8 or p.y == 9) then door_id = 1 end
      if p.x == 123 and (p.y == 14 or p.y == 15) then door_id = 2 end
      
      local can_open = false
      local specific_key_idx = 0
      
      if door_id == 1 then
        for i=1,#player.key_inv do
          if player.key_inv[i] == 1 then can_open = true specific_key_idx = i end
        end
      elseif door_id == 2 then
        for i=1,#player.key_inv do
          if player.key_inv[i] == 2 then can_open = true specific_key_idx = i end
        end
      else
        if player.keys > 0 then can_open = true end
      end
      
      if can_open then
        mset(p.x, p.y, 71)
        if mget(p.x, p.y-1) == 70 then mset(p.x, p.y-1, 71) end
        if mget(p.x, p.y+1) == 70 then mset(p.x, p.y+1, 71) end
        
        if door_id > 0 then
          deli(player.key_inv, specific_key_idx)
        else
          player.keys -= 1
        end
        
        if sound_on then sfx(2, 3) end
      else
        -- tried to open door but didn't have correct key, show ui if they have any key
        if (door_id > 0 and (#player.key_inv > 0 or player.keys > 0)) then
          ui_message = "incorrect key!"
          ui_message_timer = 90
        end
      end
    end
  end
end

function check_spring(obj)
  local hit = false
  for s in all(springs) do
    local cx = s.mx * 8
    local cy = s.my * 8
    if obj.dy >= 0 and obj.x < cx + 8 and obj.x + obj.w > cx and obj.y + obj.h >= cy and obj.y + obj.h <= cy + 6 then
       obj.dy = -4.5
       obj.landed = false
       s.timer = 15
       mset(s.mx, s.my, 98)
       hit = true
    end
  end
  if hit and sound_on then sfx(2, 3) end
end
-->8
--player

function player_update()
 --physics
 player.dy+=gravity
 player.dx*=friction
 
 if player.invuln_timer > 0 then
   player.invuln_timer -= 1
 end
 
 --controls
 if btn(⬅️) then
   player.dx-=player.acc
   player.running=true
   player.flp=true
 end
 if btn(➡️) then
   player.dx+=player.acc
   player.running=true
   player.flp=false
 end
 
  --stop instantly on ground
  if not btn(⬅️) and not btn(➡️) then
    player.running=false
    if player.landed then
      player.dx=0
      player.sliding=false
    end
  end
 
 --jump
 if btnp(⬆️)
 and player.landed then
   player.dy-=player.boost
   player.landed=false
 end
 
 --check collision up and down
 if player.dy>0 then
   player.falling=true
   player.landed=false
   player.jumping=false
   
   player.dy=limit_speed(player.dy,player.max_dy)
   
   if collide_map(player,"down",0) then
     player.landed=true
     player.falling=false
     player.dy=0
     while collide_map(player,"down",0) do
       player.y -= 1
     end
     player.y += 1
   end
 elseif player.dy<0 then
   player.jumping=true
   if collide_map(player,"up",1) then
     player.dy=0
   end
 end    
  
 --check collision left and right
 if player.dx<0 then
 
   player.dx=limit_speed(player.dx,player.max_dx)
   if collide_map(player,"left",1) then
     player.dx=0
   end
    
 elseif player.dx>0 then
  
    player.dx=limit_speed(player.dx,player.max_dx)
    
    if collide_map(player,"right",1) then
      player.dx=0
    end
 end
   
 player.x+=player.dx
 player.y+=player.dy
 
 --limit player to map
 if player.x<map_start then
   player.x=map_start
 end
 if player.x>map_end-player.w then
   player.x=map_end-player.w
 end
 
 if check_seal(player) then
   if sound_on then sfx(2, 3) end
   state=2
 elseif check_hazard(player) then
   if player.invuln_timer == 0 then
     player.hp -= 1
     if sound_on then sfx(1, 2) end -- play hurt sound
     if player.hp <= 0 then
       state=3
     else
       player.dy = -2 -- bounce up
       player.invuln_timer = 60 -- 2 seconds of invincibility
     end
   end
 end
 
 local collected = check_coin(player)
 if collected > 0 then
   player_coins += collected
   if sound_on then sfx(2, 3) end -- play a short SFX instead of the music track
 end
 
 local collected_hearts = check_heart(player)
 if collected_hearts > 0 then
   player.hp += collected_hearts
   if player.hp > 3 then player.hp = 3 end
   if sound_on then sfx(2, 3) end
 end
 
 if check_key(player) then
   if sound_on then sfx(2, 3) end
 end
 
 check_door(player)
 check_spring(player)
end
  
function player_animate()
 if player.jumping then
   player.sp=7
 elseif player.falling then
   player.sp=8
 elseif player.sliding then
   player.sp=9
 elseif player.running then
   if time()-player.anim>.1 then
     player.anim=time()
     player.sp+=1
     if player.sp>6 then
       player.sp=3
     end
   end
 else --player idle
   if time()-player.anim>.3 then
     player.anim=time()
     player.sp+=1
     if player.sp>2 then
       player.sp=1
     end
   end
 end    
end

function limit_speed(num,maximum)
 return mid(-maximum,num,maximum)
end
__gfx__
000000000044444000444440400444440404444400044444400444440004444440044444000000003333333355d5555500000000555555550000000057555755
0000000002475f5002475f500424f75f4024f75f0424f75f0424f75f0424f75f0424f75f400000003333333355555d5d0088880055888855000000005f5d5755
00000000404ffff0404ffef00004fffe0004fffe4004fffe0004fffe4004fffe0004fffe24444440333333335555555508888880588888850000000057555f5d
000000000006d0000066d6000066d0000066d0000066d0000066d0000006d00000001d6004f75f5033333333d5555555088aa880588aa8850000000057555755
00000000006d1d000f0d10f00f0d10000f0d10000f0d10000f0d1000006d100000001d0f04fffff0333333335558f555088aa880588aa885000000005f555755
000000000f0110f000011000000110000001100000011000000110000f011000000011000011d6003333333355888f5d00888800558888550000000057555f55
0000000000012000000120000110200000112000022210000021100000210000000001200f0112f0333333335888f8f500a00a0055a55a55000000005755d555
000000000010020000100200000020000012000000001000002100000211000000000012000011223333333388888f8f0a0000a05a5555a5000000005f555555
00000000d555555d55555555555555555555555d555555555555555500422211000425550004255500000000000000005999aa7500000000000000005f575575
0000000055aa77555d5a75d5555775d55557a555155551555555555500442411000425550004455500000000000000005599975d0000000000000000575f5575
000000005aa99aa555a79a55555995555579aad511551d555555515500044155000445550004255500000000000000005559a5550000000000000000555f55f5
000000005a9aa97555a9aa55555aa5555daa9a551d111d51555555110004255500042555000425550000000000000000d559a5d5000000000000000055575575
00000000579a79a555a9a7555d5995d5557a9a5511d1111d55111111000445550004255500042555000e0e000000000055597555000000000000000055575575
000000005aa99aa5d5aa9a5d5557755555a9aa5551111111511dd11500042555000425550004415500ef0f000000000055d9a5550000000000000000555f55f5
00000000557aa7d5555a7555d55aa555d557a5551111d11511111d5500042555000425550042221100ef0f0000000000555975550000000000000000555555f5
00000000d5555555555555555555555d5555555d55555555d111515500042555000425550044221100eeeee0000000005559a55d000000000000000055555555
0000000000000000000000000000000666666666600000000880088008800880588d5885555d555500444440000000005559a555000000000000000000000000
00000000000000000000000000000066666666666600000088888ee888882ee888888ee85885588502475f50000000005559a55d000000000000000000000000
000000000000000000000000000000666666666666600000888888ee888288ee888888ee58888ee5404ffff00000000055597555000000000000000000000000
0000000000000000000000000006666666666666666000008888888e8888288e8888888e588888e50006d000000000005d59a555000000000000000000000000
000000000000000000000000066666666666666666666000888888e8888288e8888888e858888885006d1d000000000055597555000000000000000000000000
00000000000000000000000006666666666666666666660008888e8008882e8058888e8555888e550f0110f00000000055597555000000000000000000000000
00000000000000000000000006666666666666666666666600888800008288005588885d5558855d00012000000000005559a555000000000000000000000000
0000000000000000000000000666666666666666666666660008800000082000d55885d5d55555d5001002000000000055d9a55d000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000005955555d5d5555a5000000005955555dd559a5555d5555a5070557000f075070
0000000000aa7700000a7000000770000007a0000000000008800880088008809505d055550d5057000000009555d5555599aa55555d55570f0d5700070f5070
000000000aa99aa000a79a00000990000079aa000000000008888ee008828ee0900550055005500700000000955555555a5555a55555555707055f00000f50f0
000000000a9aa97000a9aa00000aa00000aa9a0000000000088888e0088828e009055009900550700000000059555559a5955a5a955555755755575555575575
00000000079a79a000a9a70000099000007a9a00000000000888888008828880079550900a0559f000000000579555955559a5555a5559f55f55575555575575
000000000aa99aa000aa9a000007700000a9aa000000000000888e0000882e000f09aa000fa970f0000000005f59aa555559a5555fa975fd07055f00000f50f0
00000000007aa700000a7000000aa0000007a0000000000000088000000280000f055700070f507000000000df5557555d59a5d5575f55750705d000000550f0
000000000000000000000000000000000000000000000000000000000000000007055f00070750f00000000057555fd55559a55557d755f50f05500000055000
00000011122112211100000000000000bbbbbbbbbbbbbbbb55333355555333330000005d5555555555000000550055000055005500055000d555555d000d5000
000000111111111111000000000000003b3bb3b33bbbb333d553355dd5533333000000555555555dd5000000550055000055005d000550005505505500055000
00001122211221122211000000000000333b33343b333434555335555553333300005555d5d55555555500005555555555555555000550005005500500055000
0000111111111111111100000000000043333444b3b3344455a33a55555333a300005555555555555d5500005555555555555d55555555d50005500000055000
0011221112211221112211000000000044333444333444f45553355555533333005555d555d5555555555500555555555d555555d55555550005500000055000
001111111111111111111100000000002344454434344444555335d55553333300555d555555555d555555005555555555d55555000550000005d0000005d000
1122112221122112221122112112211244445442442454455d5335555d533333555555d5555555555d5d555555555555555555d50005d0000005500000055000
111111111111111111111111111111114e54244524f44ef4553333555553333355d555555555dd555555555d555555555555555500055000000550005d555555
1200120000210021bbb33b31bbb3b3bb55555d5555555d5500000000000000005552424400000000000000001221122156556565556565560000000000000000
1100110000110011b3b33312333333bb5d5555555d55555500000000000000005554335200000000000000001111111155655656665d65650000000000000000
2112211221122112b33414114444333b5555555555555555000000000000000055d4335400000000000000002112211255566565555565650000000000000000
1111111111111111b14f111145f44333555d5555aaad5a5a00000000aaa00a0a5552133400000000000000005111111555555565655656650000000000000000
12211221122112213421122144244443aaa55a5aa5aaaaaaaaa00a0aa0aaaaaa5d541dd40000000000000000522112255d5d5565566665650000000000000000
11111111111111114e4111114e444444a5aaaaaaaaa55555a0aaaaaaaaa00000555435d400000000000000005111111d555555655656d5650000000000000000
211221122112211241111111454424f4aaa5555555555555aaa00000000000005554111200000000000000005112211555d55555d656555d0000000000000000
11111111111111112112211224444e455555555d5555555d00000000000000005d5244440000000000000000d51111555555d55d565555d50000000000000000
4444444455555d5555555d55122112210000000024244442444242244442255dd555555d5555955d55555555d5d5555dd55555d55d242425542224d500000000
4444444455d5555555d555551111111100000000211188e44aa9f98452554d5555555555d555a555555555d5555000055000055dd521554d5259545d00000000
444444445555555d5555555d2112211200000000211818e249af8e82521d2555555555555555ad55555555555500000550000055552d1325d299925500000000
444444445d5555555d55555511111111000000004188888429ffffe442524555555d555d5555a5d555555555d0006605500600055543354554a9945500000000
44444444555cc65555555555122112210000000048188114488ff9a2422245d555555555555d65d55d5555d55000600550600605d5455325d2aaa25500000000
4444444451ccc6655555555c1111111100000000418e81842efef98442112555d5555d555555dd555555555550066605560600055525d52d54aaa45d00000000
444444441111ccc61cc555662112211200000000288888e24f9fffe2451d455d5d555555d555d5555555555550600005500000055541152554fa525500000000
444444441111c1cc111cc1c6111111110000000044444444442222444242455555554444fffdd6ff4444455d5d55555dd555555d5d4d114554ff925d00000000
d55d5511d55d551111d55d550000000012211221555555d115555555122112215d5544555fffffff55544555d5555555555555555525354554ff545500000000
5555551155555511115555550000000011111115555d5511115d55d5511111115555445555fffff5d55445555060000d500000055d4d3145d2eff4d500000000
5d5511225d551122221155d5000000002112215d5d555112211555555512211255554455555fff555554455556000005506000055541114552fee25d00000000
5555111155551111111155550000000011111555555511111111555d55511111555544555d55f555555445d55060006550060605d54dd54554eff45500000000
55112211551122111122115500000000122155555551122112211555d55512215d5544555555555555544555d0066605500060055525534d548ee45500000000
5511111155111111111111550000000011155d555d1111111111115555555111d555445d55555555d55445555506000d500600555543d12552ee825500000000
112211221122112222112211000000002155555d5112211221122115d55d5512555544555555d55d555445555550000550600555d5253325d488e25d00000000
11111111111111111111111100000000155d555511111111111111115555555155554555d55555555555455dd5d5555555555555d524442d5424245500000000
__map__
0000000000000000000000000000000000000000000023242500000000000000000000000000000000000000000023242500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000023250000000000000000000000000000000000000000000000232500000000000000
0000000000000000000000000023242500505050505050505050505050505050505050505050420000232425000000004050506342000000002324242425000000000023242540515151515151515151515151000023242425000000000000505050505050515151515151515151510000000000000000000000405151515151
0000000000002324250000000000000000415d494949495c7763745c5d49491c49494949494977505050505050505051745c5d6363505050505050504200000000000000000063745d495c776374491c4977630000000000000000000000006374497763745d491c49494949495c63002324250000000000000063745c5d7763
232425000000000000004050505050506374494949494949495b49494949492c49494949494949494949494949494949494949635d1c49494949495c630000000040505050506349494e494963493b3c3d497763515151510000000000002363494e49634949492c494949494949630000000000000000000000636d6b6c6e63
00000000000000000040744949494949494949494e49490d4946494949493b3c3d49494e494949494949494949494949494949633b3c3d49494954496300002324631149495c5b49674d58495b490f491f494949494977635151515151515163494d496349493b3c3d4949494e49630000000000002324242500637d7b7c7e63
00000023242500004074494949494949494949494d4970636363636372490f491f49494d49494949494949491149494e494949630f491f4949706363630000000063637249494649494f0d49464949494949494e494e49494949494949494949494f116349490f491f4949494d49630000000000000000000040744949544963
00000000000000407449494966494949494949494f7074495c635d49777249494949494f49494949494970636349494d49494963494e49497074494977505050507449494970636363636363636363637249494d494d496649494949494911494970636349494949494949114f49635151515151515151515174494970636363
00000000000040634949494949494949494949706374494949634949497763724949706372494949497074494949494f49494963494d497074494949494949494949494970745d1c49495c77635c4e5d77720b4f494f494949494965497063724949496349496e49494970636363635d494949494949495c5b49497074495c63
0000000000000063494e494e4172494949706374494e494e4963494e494e49494949494949494949284949494949706363724963114f4949494949494949494949490b707449492c4949495d63494d49497763636363636363724949494949494949496349677e584970745c5d5d5b4949494949494949494628707449494963
2324250000000063494d494d5c77637249494949494d494d4963494d494d706372494949494970636372494949494949494949636363636363724965494949706363637449493b3c3d49494963544f49494949494949495c5d776363637249494949496349495449494949494949494965494949494949706363744958496763
0000000000000063114f0b4f4949494949494949494f114f4963114f494f49490b0b0b49497074494949494949494949490b0b635d49494949494949494949494949494949490f491f49494963636363724949654949494949494949494949494949496363636363637249490b49494949494949494970741c49494949114963
0000002325004063636363636363636372494970636363636363636363636363636363636374494949494949497063636363636349494949494970637249706372494949494e494e494e4949635d494977724949496d6b6c6e4949494949494949280b6349494949494949706363636363724949706374492c49497063636363
00000000000017494949494949494949494970745d4949495c635d494949494949494949494949494949494970745d4949497763494949494970745d4949494977637249494d494d494d49496349114949776363727d7b7c7e706363637249497063636349494958494970745d49494949777249494949383c3949635d495c63
000000000000184965496649654949494970744968696a49496368696a654966494949494949494949494971744949494949495b496549497074494949494968696a7772494f494f494f49496349637249494949777249494968696a494949495b49495b4949494949707449496768696a4977724949673e493f585b49494963
000000000000194949494949494949497174494978797a11496378797a4911494949494949490b490b49717449494949490d494649490b70744949490b0b0b78797a49494949284949114949634949490b494949494949494978797a4949494946490d46490b0b4970744949114978797a494949490b494f494f6146490d4963
4553455345526363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363636363
__sfx__
00100000182501f250242501f250182501f250242501f250182501f250242501f250182501f250242501f250182501f250242501f250182501f250242501f250182501f250242501f250182501f250242501f250
00100000241600000027160000002b16000000301602b160271600000024160000001f1600000024160000002216000000241600000027160000002b160000002e1600000030160000002b160000002716000000
0002000030050370503c0500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
03 00014040

