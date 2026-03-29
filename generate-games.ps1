$ErrorActionPreference = "SilentlyContinue"
$gamesDir = "d:\antigravity\games"
if(!(Test-Path $gamesDir)){New-Item -ItemType Directory -Path $gamesDir -Force|Out-Null}

function Head($title,$desc,$cat){
@"
<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>$title - WebFunHub</title><meta name="description" content="$desc">
<link rel="stylesheet" href="../style.css"></head><body>
<nav class="navbar" id="nb"><a href="../index.html" class="nav-brand"><div class="nav-brand-icon">W</div><span class="nav-brand-text">WebFunHub</span></a>
<ul class="nav-links" id="nl"><li><a href="../index.html">Home</a></li><li><a href="../index.html#games" class="active">Games</a></li></ul>
<button class="nav-menu-btn" id="mb" aria-label="Menu">☰</button></nav>
<div class="ad-banner" style="margin-top:80px;max-width:728px">Ad Space</div>
<main class="game-page"><div class="game-page-header"><a href="../index.html#games" class="game-page-back">← Back</a>
<h1 class="game-page-title">$title</h1><div class="game-page-meta"><span class="game-page-tag">$cat</span></div></div>
"@
}

function Foot{
@"
</main><div class="ad-banner" style="max-width:728px;margin:24px auto">Ad Space</div>
<footer class="footer"><div class="footer-bottom">© 2026 WebFunHub</div></footer>
<script>document.getElementById('mb').onclick=()=>document.getElementById('nl').classList.toggle('open');
window.onscroll=()=>document.getElementById('nb').classList.toggle('scrolled',scrollY>20);</script></body></html>
"@
}

$games = @()
$num = 5  # we already have 001-005

# ===================== GAME TEMPLATES =====================

function MakeSnakeVariant($id,$title,$desc,$gridW,$gridH,$cellSize,$hasWalls,$speed){
$w=$gridW*$cellSize;$h=$gridH*$cellSize
$wallCheck=if($hasWalls){"if(hd.x<0||hd.x>=$gridW||hd.y<0||hd.y>=$gridH){end();return;}"}else{"if(hd.x<0)hd.x=$gridW-1;if(hd.x>=$gridW)hd.x=0;if(hd.y<0)hd.y=$gridH-1;if(hd.y>=$gridH)hd.y=0;"}
$html = (Head $title $desc "Arcade") + @"
<div class="game-container"><div class="game-score-bar"><div class="game-score-item"><span class="game-score-label">Score</span>
<span class="game-score-value" id="sc">0</span></div><div class="game-score-item"><span class="game-score-label">Best</span>
<span class="game-score-value" id="bs">0</span></div></div>
<div class="game-canvas-wrap"><canvas id="c" width="$w" height="$h"></canvas></div>
<div class="game-controls"><button class="game-btn game-btn-primary" id="sb" onclick="start()">▶ Start</button>
<button class="game-btn game-btn-secondary" onclick="reset()">↻ Restart</button></div></div>
<div style="display:grid;grid-template-columns:repeat(3,1fr);gap:8px;max-width:200px;margin:16px auto">
<div></div><button class="game-btn game-btn-secondary" onclick="cd(0,-1)" style="padding:12px;font-size:1.1rem">▲</button><div></div>
<button class="game-btn game-btn-secondary" onclick="cd(-1,0)" style="padding:12px;font-size:1.1rem">◀</button>
<button class="game-btn game-btn-secondary" onclick="cd(0,1)" style="padding:12px;font-size:1.1rem">▼</button>
<button class="game-btn game-btn-secondary" onclick="cd(1,0)" style="padding:12px;font-size:1.1rem">▶</button></div>
<div class="game-instructions"><h3>📖 How to Play</h3><ul><li>Arrow keys or WASD to move</li><li>Eat food to grow</li><li>Don't crash!</li></ul></div>
<script>
const cv=document.getElementById('c'),cx=cv.getContext('2d'),G=$cellSize,C=$gridW,R=$gridH;
let sn,dr,nd,fd,sc,bs=+localStorage.getItem('snake_$id')||0,lp,rn=false,ov=false;
document.getElementById('bs').textContent=bs;
function init(){sn=[{x:Math.floor(C/2),y:Math.floor(R/2)}];for(let i=1;i<3;i++)sn.push({x:sn[0].x-i,y:sn[0].y});
dr={x:1,y:0};nd={x:1,y:0};sc=0;rn=false;ov=false;sf();upd();draw();}
function sf(){do{fd={x:Math.floor(Math.random()*C),y:Math.floor(Math.random()*R)};}while(sn.some(s=>s.x===fd.x&&s.y===fd.y));}
function upd(){document.getElementById('sc').textContent=sc;}
function cd(dx,dy){if(dr.x===-dx&&dr.y===-dy)return;nd={x:dx,y:dy};}
function draw(){cx.fillStyle='#0f0f1a';cx.fillRect(0,0,cv.width,cv.height);
cx.shadowColor='#ef4444';cx.shadowBlur=10;cx.fillStyle='#ef4444';cx.beginPath();
cx.arc(fd.x*G+G/2,fd.y*G+G/2,G/2-2,0,Math.PI*2);cx.fill();cx.shadowBlur=0;
sn.forEach((s,i)=>{cx.fillStyle=i===0?'#a855f7':`rgba(124,58,237,${1-i/sn.length*.5})`;
cx.beginPath();cx.roundRect(s.x*G+2,s.y*G+2,G-4,G-4,3);cx.fill();});
if(ov){cx.fillStyle='rgba(0,0,0,.7)';cx.fillRect(0,0,cv.width,cv.height);cx.fillStyle='#f1f5f9';
cx.font='bold 24px Outfit,sans-serif';cx.textAlign='center';cx.fillText('Game Over! Score: '+sc,cv.width/2,cv.height/2);}
if(!rn&&!ov){cx.fillStyle='rgba(0,0,0,.5)';cx.fillRect(0,0,cv.width,cv.height);cx.fillStyle='#f1f5f9';
cx.font='bold 20px Outfit,sans-serif';cx.textAlign='center';cx.fillText('Press Start',cv.width/2,cv.height/2);}}
function tick(){dr=nd;let hd={x:sn[0].x+dr.x,y:sn[0].y+dr.y};
$wallCheck
if(sn.some(s=>s.x===hd.x&&s.y===hd.y)){end();return;}
sn.unshift(hd);if(hd.x===fd.x&&hd.y===fd.y){sc+=10;upd();sf();clearInterval(lp);lp=setInterval(tick,Math.max(50,$speed-sc));}
else sn.pop();draw();}
function end(){rn=false;ov=true;clearInterval(lp);if(sc>bs){bs=sc;localStorage.setItem('snake_$id',bs);
document.getElementById('bs').textContent=bs;}document.getElementById('sb').textContent='▶ Start';draw();}
function start(){if(rn)return;if(ov)init();rn=true;document.getElementById('sb').textContent='Playing...';lp=setInterval(tick,$speed);}
function reset(){clearInterval(lp);document.getElementById('sb').textContent='▶ Start';init();}
document.onkeydown=e=>{const m={ArrowUp:[0,-1],ArrowDown:[0,1],ArrowLeft:[-1,0],ArrowRight:[1,0],w:[0,-1],s:[0,1],a:[-1,0],d:[1,0]};
if(m[e.key]){e.preventDefault();cd(m[e.key][0],m[e.key][1]);if(!rn&&!ov)start();}};init();
</script>
"@ + (Foot)
$path = "$gamesDir\game-$($id.ToString('000')).html"
[System.IO.File]::WriteAllText($path,$html,[System.Text.Encoding]::UTF8)
return @{id=$id.ToString('000');title=$title;desc=$desc;cat='arcade';icon='🐍';gradient='green'}
}

function MakeBreakout($id,$title,$desc,$rows,$cols,$ballSpd,$paddleW){
$cw=500;$ch=400
$html = (Head $title $desc "Arcade") + @"
<div class="game-container"><div class="game-score-bar"><div class="game-score-item"><span class="game-score-label">Score</span>
<span class="game-score-value" id="sc">0</span></div><div class="game-score-item"><span class="game-score-label">Lives</span>
<span class="game-score-value" id="lv">3</span></div></div>
<div class="game-canvas-wrap"><canvas id="c" width="$cw" height="$ch"></canvas></div>
<div class="game-controls"><button class="game-btn game-btn-primary" id="sb" onclick="start()">▶ Start</button>
<button class="game-btn game-btn-secondary" onclick="reset()">↻ Restart</button></div></div>
<div class="game-instructions"><h3>📖 How to Play</h3><ul><li>Move mouse or touch to control paddle</li><li>Break all bricks to win</li><li>Don't let the ball fall!</li></ul></div>
<script>
const cv=document.getElementById('c'),cx=cv.getContext('2d');
const BR=$rows,BC=$cols,BW=(cv.width-20)/BC,BH=20,BS=$ballSpd,PW=$paddleW;
let bricks,ball,paddle,sc,lives,running=false,anim;
const colors=['#a855f7','#3b82f6','#ec4899','#10b981','#f59e0b','#06b6d4'];
function init(){bricks=[];for(let r=0;r<BR;r++)for(let c=0;c<BC;c++)bricks.push({x:10+c*BW,y:40+r*(BH+4),w:BW-4,h:BH,alive:true,color:colors[r%colors.length]});
ball={x:cv.width/2,y:cv.height-60,dx:BS*(Math.random()>.5?1:-1),dy:-BS,r:6};
paddle={x:cv.width/2-PW/2,w:PW,h:12};sc=0;lives=3;running=false;
document.getElementById('sc').textContent=0;document.getElementById('lv').textContent=3;draw();}
function draw(){cx.fillStyle='#0f0f1a';cx.fillRect(0,0,cv.width,cv.height);
bricks.forEach(b=>{if(!b.alive)return;cx.fillStyle=b.color;cx.beginPath();cx.roundRect(b.x,b.y,b.w,b.h,4);cx.fill();});
cx.shadowColor='#a855f7';cx.shadowBlur=10;cx.fillStyle='#f1f5f9';cx.beginPath();cx.arc(ball.x,ball.y,ball.r,0,Math.PI*2);cx.fill();cx.shadowBlur=0;
cx.fillStyle='#a855f7';cx.beginPath();cx.roundRect(paddle.x,cv.height-20,paddle.w,paddle.h,6);cx.fill();
if(!running){cx.fillStyle='rgba(0,0,0,.5)';cx.fillRect(0,0,cv.width,cv.height);cx.fillStyle='#f1f5f9';cx.font='bold 20px Outfit';cx.textAlign='center';
cx.fillText(lives<=0?'Game Over! Score: '+sc:'Press Start',cv.width/2,cv.height/2);}}
function update(){ball.x+=ball.dx;ball.y+=ball.dy;
if(ball.x<=ball.r||ball.x>=cv.width-ball.r)ball.dx*=-1;
if(ball.y<=ball.r)ball.dy*=-1;
if(ball.y>=cv.height-20-ball.r&&ball.x>=paddle.x&&ball.x<=paddle.x+paddle.w){ball.dy=-Math.abs(ball.dy);
let hit=(ball.x-(paddle.x+paddle.w/2))/(paddle.w/2);ball.dx=hit*BS*1.5;}
if(ball.y>cv.height){lives--;document.getElementById('lv').textContent=lives;
if(lives<=0){running=false;cancelAnimationFrame(anim);draw();return;}
ball.x=cv.width/2;ball.y=cv.height-60;ball.dx=BS*(Math.random()>.5?1:-1);ball.dy=-BS;}
bricks.forEach(b=>{if(!b.alive)return;if(ball.x>b.x&&ball.x<b.x+b.w&&ball.y-ball.r<b.y+b.h&&ball.y+ball.r>b.y){
b.alive=false;ball.dy*=-1;sc+=10;document.getElementById('sc').textContent=sc;}});
if(bricks.every(b=>!b.alive)){running=false;cancelAnimationFrame(anim);}}
function loop(){if(!running)return;update();draw();anim=requestAnimationFrame(loop);}
function start(){if(running)return;if(lives<=0)init();running=true;document.getElementById('sb').textContent='Playing...';loop();}
function reset(){cancelAnimationFrame(anim);document.getElementById('sb').textContent='▶ Start';init();}
cv.onmousemove=e=>{let r=cv.getBoundingClientRect();paddle.x=Math.min(Math.max(0,e.clientX-r.left-paddle.w/2),cv.width-paddle.w);if(running)draw();};
cv.ontouchmove=e=>{e.preventDefault();let r=cv.getBoundingClientRect();let t=e.touches[0];paddle.x=Math.min(Math.max(0,t.clientX-r.left-paddle.w/2),cv.width-paddle.w);};
init();
</script>
"@ + (Foot)
[System.IO.File]::WriteAllText("$gamesDir\game-$($id.ToString('000')).html",$html,[System.Text.Encoding]::UTF8)
return @{id=$id.ToString('000');title=$title;desc=$desc;cat='arcade';icon='🧱';gradient='blue'}
}

function MakePong($id,$title,$desc,$aiSpd,$ballSpd,$winScore){
$html = (Head $title $desc "Arcade") + @"
<div class="game-container"><div class="game-score-bar"><div class="game-score-item"><span class="game-score-label">You</span>
<span class="game-score-value" id="p1">0</span></div><div class="game-score-item"><span class="game-score-label">AI</span>
<span class="game-score-value" id="p2">0</span></div></div>
<div class="game-canvas-wrap"><canvas id="c" width="500" height="350"></canvas></div>
<div class="game-controls"><button class="game-btn game-btn-primary" id="sb" onclick="start()">▶ Start</button>
<button class="game-btn game-btn-secondary" onclick="reset()">↻ Restart</button></div></div>
<div class="game-instructions"><h3>📖 How to Play</h3><ul><li>Move mouse up/down to control paddle</li><li>First to $winScore wins</li></ul></div>
<script>
const cv=document.getElementById('c'),cx=cv.getContext('2d'),W=cv.width,H=cv.height;
const AS=$aiSpd,BS=$ballSpd,WS=$winScore;
let p1={y:H/2-30,h:60,s:0},p2={y:H/2-30,h:60,s:0},bl={x:W/2,y:H/2,dx:BS,dy:BS*(Math.random()-.5)*2,r:6};
let running=false,anim;
function draw(){cx.fillStyle='#0f0f1a';cx.fillRect(0,0,W,H);cx.setLineDash([5,5]);cx.strokeStyle='rgba(124,58,237,.2)';
cx.beginPath();cx.moveTo(W/2,0);cx.lineTo(W/2,H);cx.stroke();cx.setLineDash([]);
cx.fillStyle='#a855f7';cx.beginPath();cx.roundRect(10,p1.y,10,p1.h,4);cx.fill();
cx.fillStyle='#3b82f6';cx.beginPath();cx.roundRect(W-20,p2.y,10,p2.h,4);cx.fill();
cx.shadowColor='#f1f5f9';cx.shadowBlur=8;cx.fillStyle='#f1f5f9';cx.beginPath();cx.arc(bl.x,bl.y,bl.r,0,Math.PI*2);cx.fill();cx.shadowBlur=0;}
function update(){bl.x+=bl.dx;bl.y+=bl.dy;if(bl.y<=bl.r||bl.y>=H-bl.r)bl.dy*=-1;
let ai=p2.y+p2.h/2;if(ai<bl.y-10)p2.y+=AS;else if(ai>bl.y+10)p2.y-=AS;
p2.y=Math.max(0,Math.min(H-p2.h,p2.y));
if(bl.x<=20&&bl.y>=p1.y&&bl.y<=p1.y+p1.h){bl.dx=Math.abs(bl.dx);bl.dy+=(bl.y-(p1.y+p1.h/2))*.3;}
else if(bl.x>=W-20&&bl.y>=p2.y&&bl.y<=p2.y+p2.h){bl.dx=-Math.abs(bl.dx);bl.dy+=(bl.y-(p2.y+p2.h/2))*.3;}
if(bl.x<0){p2.s++;scored();}else if(bl.x>W){p1.s++;scored();}}
function scored(){document.getElementById('p1').textContent=p1.s;document.getElementById('p2').textContent=p2.s;
if(p1.s>=WS||p2.s>=WS){running=false;cancelAnimationFrame(anim);
cx.fillStyle='rgba(0,0,0,.7)';cx.fillRect(0,0,W,H);cx.fillStyle='#f1f5f9';cx.font='bold 24px Outfit';cx.textAlign='center';
cx.fillText(p1.s>=WS?'You Win!':'AI Wins!',W/2,H/2);return;}
bl.x=W/2;bl.y=H/2;bl.dx=BS*(Math.random()>.5?1:-1);bl.dy=BS*(Math.random()-.5)*2;}
function loop(){if(!running)return;update();draw();anim=requestAnimationFrame(loop);}
function start(){if(running)return;if(p1.s>=WS||p2.s>=WS){p1.s=0;p2.s=0;document.getElementById('p1').textContent=0;document.getElementById('p2').textContent=0;}
running=true;document.getElementById('sb').textContent='Playing...';loop();}
function reset(){cancelAnimationFrame(anim);running=false;p1.s=0;p2.s=0;p1.y=H/2-30;p2.y=H/2-30;
bl={x:W/2,y:H/2,dx:BS,dy:BS*(Math.random()-.5)*2,r:6};
document.getElementById('p1').textContent=0;document.getElementById('p2').textContent=0;document.getElementById('sb').textContent='▶ Start';draw();}
cv.onmousemove=e=>{let r=cv.getBoundingClientRect();p1.y=Math.max(0,Math.min(H-p1.h,(e.clientY-r.top)-p1.h/2));};
cv.ontouchmove=e=>{e.preventDefault();let r=cv.getBoundingClientRect();p1.y=Math.max(0,Math.min(H-p1.h,(e.touches[0].clientY-r.top)-p1.h/2));};
draw();
</script>
"@ + (Foot)
[System.IO.File]::WriteAllText("$gamesDir\game-$($id.ToString('000')).html",$html,[System.Text.Encoding]::UTF8)
return @{id=$id.ToString('000');title=$title;desc=$desc;cat='arcade';icon='🏓';gradient='cyan'}
}

Write-Host "Generator script loaded. Templates ready." -ForegroundColor Green
Write-Host "Generating games..." -ForegroundColor Cyan

# ===== GENERATE SNAKE VARIANTS =====
$num++; $games += MakeSnakeVariant $num "Snake Speed Run" "Fast-paced snake action" 20 20 20 $true 100
$num++; $games += MakeSnakeVariant $num "Snake No Walls" "Snake without boundaries - wrap around!" 20 20 20 $false 140
$num++; $games += MakeSnakeVariant $num "Tiny Snake" "Snake on a small 10x10 grid" 10 10 30 $true 150
$num++; $games += MakeSnakeVariant $num "Giant Snake" "Snake on a massive grid" 30 25 16 $true 130
$num++; $games += MakeSnakeVariant $num "Turbo Snake" "Insanely fast snake challenge" 20 20 20 $true 70
$num++; $games += MakeSnakeVariant $num "Snake Marathon" "Slow and steady - huge grid, no walls" 30 25 16 $false 160
$num++; $games += MakeSnakeVariant $num "Snake Sprint" "Tiny grid, blazing speed" 8 8 35 $true 80
$num++; $games += MakeSnakeVariant $num "Snake Zen" "Relaxed snake, no walls, slow pace" 20 20 20 $false 200
$num++; $games += MakeSnakeVariant $num "Snake Challenge" "Medium grid, fast speed, walls on" 15 15 24 $true 90
$num++; $games += MakeSnakeVariant $num "Snake Extreme" "Tiny grid, maximum speed" 10 10 30 $true 60

Write-Host "  Snake variants: 10 done" -ForegroundColor Yellow

# ===== GENERATE BREAKOUT VARIANTS =====
$num++; $games += MakeBreakout $num "Brick Breaker" "Classic brick breaking game" 4 8 4 80
$num++; $games += MakeBreakout $num "Brick Breaker Pro" "More bricks, faster ball" 5 9 5 70
$num++; $games += MakeBreakout $num "Brick Wall" "6 rows of bricks to smash" 6 8 4 90
$num++; $games += MakeBreakout $num "Speed Breaker" "Fast ball, small paddle" 4 8 6 60
$num++; $games += MakeBreakout $num "Mega Breaker" "Massive brick wall challenge" 7 10 4 80
$num++; $games += MakeBreakout $num "Breaker Easy" "Easy mode - big paddle, slow ball" 3 6 3 120
$num++; $games += MakeBreakout $num "Breaker Nightmare" "Tiny paddle, fast ball" 5 8 6 50
$num++; $games += MakeBreakout $num "Brick Sprint" "4 rows, fast ball challenge" 4 7 5 70
$num++; $games += MakeBreakout $num "Brick Fortress" "8 rows fortress" 8 8 4 90
$num++; $games += MakeBreakout $num "Breaker Blitz" "Speed run brick breaking" 3 10 7 60

Write-Host "  Breakout variants: 10 done" -ForegroundColor Yellow

# ===== GENERATE PONG VARIANTS =====
$num++; $games += MakePong $num "Pong Classic" "Classic Pong against AI" 3 4 5
$num++; $games += MakePong $num "Pong Hard" "Fast AI opponent" 5 5 7
$num++; $games += MakePong $num "Pong Extreme" "Lightning fast Pong" 4 7 5
$num++; $games += MakePong $num "Pong Easy" "Slow AI, easy win" 2 3 3
$num++; $games += MakePong $num "Pong Marathon" "First to 15 wins" 3 4 15
$num++; $games += MakePong $num "Speed Pong" "Super fast ball" 4 8 5
$num++; $games += MakePong $num "Pong Championship" "Pro-level AI, first to 10" 6 5 10
$num++; $games += MakePong $num "Pong Quick Match" "First to 3, fast ball" 3 6 3
$num++; $games += MakePong $num "Pong Impossible" "Can you beat perfect AI?" 7 5 5
$num++; $games += MakePong $num "Pong Turbo" "Turbo speed challenge" 4 9 7

Write-Host "  Pong variants: 10 done" -ForegroundColor Yellow
Write-Host "Batch 1 complete: $num games total" -ForegroundColor Green

# Save game list for index generation
$games | ConvertTo-Json | Out-File "d:\antigravity\games-list.json" -Encoding UTF8
Write-Host "Game list saved to games-list.json"
