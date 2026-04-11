pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
--variables

function _init()
  player={
    sp=1,
    x=59,
    y=59,
    w=8,
    h=8,
    flp=false
    dx=0,
    dy=0,
    max_dx=2,
    max_dy+3,
    acc=0.5,
    boost=4,
    anim=0,
    running=false,
    jumping=false,
    falling=false,
    sliding=false,
    landed=false
  }
  
  gravity=0.3,
  friction=0.85
  
  --simple camera
  cam_x=0
  
  --map limits
  map_start=0
  map_end=1024
  
  ---------test----------
  x1r=0 y1r=0 x2r=0 y2r=0
  collide_l="no"
  collide_r="no"
  collide_u="no"
  collide_d="no"
  -----------------------
end


-->8
--update and draw

function _update()
  player_update()
  player_animate()
  
  --simple camera
  cam_x=player.x-64+player.w/2)
  if cam_xmap_start then
    cam_x=map_start
  end
  if cam_x>map_end-128 then
    cam_x=map_end-128
  end
  camera(cam_x,0)
end

function _draw()
  cls()
  map(0,0)
  spr(player.sp,player.x,player.y,1,1,player.flp)
  
  -------test-------
  rect(x1r,y1r,x2r,y2r,7)
  print("⬅️= "..collide_l,player.x,player.y-10)
  print("➡️= "..collide_r,player.x,player.y-16)
  print("⬆️= "..collide_u,player.x,player.y-22)
  print("⬇️= "..collide_d,player.x,player.y-28)
  ------------------
end
-->8
--collisions

function collide_map(obj,aim,flag)
 --obj = table needs x,y,w,h
 --aim = left,right,up,down
 
 local x=obj.x  local y=obj.y
 local w=obj.w  local h=obj.h
 
 local x1=0  local y1=0
 local w1=0  local h1=0
 
 if aim=="left" then
   x1=x-1  y1=y
   x2=x    y2=y+h-1
 
 elseif aim=="right" then
   x1=x+w-1   y1=y
   x2=x+w     y2=y+h-1
 
 elseif aim=="up" then
   x1=x+2    y1=y-1
   x2+x+w-3  y2=y
 
 elseif aim=="down" then
   x1=x+2    y1=y+h
   x2=x+w-3  y2=y+h
 end
 
 -------test-------
 x1r=x1 y1r=y1
 x2r=x2 y2r=y2
 ------------------
 
 --pixels to tiles
 x1/=8   y1/=8
 x2/=8   y2/=8
 
 if fget(mget(x1,y1), flag)
 or fget(mget(x1,y2), flag)
 or fget(mget(x2,y1), flag)
 or fget(mget(x2,y2), flag) then
   return true
 else
   return false
end
-->8
--player

function player_update()
 --physics
 player.dy+=gravity
 player.dx*=friction
 
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
 
 --slide
 if player.running
 and not btn(⬅️)
 and not btn(➡️)
 and not player.falling
 and not player.jumping then
   player.running=false
   player.sliding=true
 end
 
 --jump
 if btnp(❎)
 and player.landed then
   player.dy-=player boost
   player.landed=false
 end
 
 --check collision up and down
 if player.dy>0 then
   player.falling=true
   player.landed=false
   player.jumping=false
   
   player.dy=limit_speed(player.dy,player.max_dy)
   
   if collide_map(player,"down",0) then
     player,landed=true
     player.falling=false
     player.dy=0
     player.y-=((player.y+player.h+1)%8)-1
   
     -----test----
     collide_d="yes"
   else 
     collide_d="no"
     -------------
   end
  elseif player.dy<o then
    player.jumping=true
    if collide_map(player,"up",1)
      player.dy=0
    end
    -----test----
     collide_u="yes"
   else 
     collide_u="no"
     -------------
  end    
  --check collision left and right
  if player.dx<0 then
  
    player.dx=limit_speed(player.dx,player.max_dx)
    if collide_map(player,"left",1)     
      player.dx=0
     end
     
     -----test----
     collide_l="yes"
   else 
     collide_l="no"
     -------------
     
   elseif player.dx>0 then
   
     player.dx=limit_speed(player.dx,player.max_dx)
     
     if collide_map(player,"right",1)
       player.dx=0
       
       -----test----
     collide_r="yes"
   else 
     collide_r="no"
     -------------
     end
   end
   
   --stop sliding
   if player.sliding then
     if abs(player,dx)<.2
     or player.running then
       player.dx=0
       player.sliding=false
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
00000000004444400044444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000002475f5002475f5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700404ffff0404ffef000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000006d0000066d60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000006d1d000f0d10f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000f0110f00001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000120000001200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000001002000010020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
