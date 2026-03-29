$ErrorActionPreference = "SilentlyContinue"
$gamesDir = "d:\antigravity\games"
$prevGames = Get-Content "d:\antigravity\games-list.json" -Raw | ConvertFrom-Json
$games = [System.Collections.ArrayList]@()
foreach($g in $prevGames){$games.Add($g)|Out-Null}
$num = $games.Count + 5

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
function Save($id,$html,$title,$desc,$cat,$icon,$grad){
[System.IO.File]::WriteAllText("$gamesDir\game-$($id.ToString('000')).html",$html,[System.Text.Encoding]::UTF8)
$games.Add(@{id=$id.ToString('000');title=$title;desc=$desc;cat=$cat;icon=$icon;gradient=$grad})|Out-Null
}

# ===== FLAPPY BIRD =====
function MakeFlappy($id,$title,$desc,$gap,$pipeW,$gravity,$jumpF,$spd){
$html = (Head $title $desc "Arcade") + @"
<div class="game-container"><div class="game-score-bar"><div class="game-score-item"><span class="game-score-label">Score</span>
<span class="game-score-value" id="sc">0</span></div><div class="game-score-item"><span class="game-score-label">Best</span>
<span class="game-score-value" id="bs">0</span></div></div>
<div class="game-canvas-wrap"><canvas id="c" width="400" height="500"></canvas></div>
<div class="game-controls"><button class="game-btn game-btn-primary" id="sb" onclick="go()">▶ Start</button>
<button class="game-btn game-btn-secondary" onclick="rs()">↻ Restart</button></div></div>
<div class="game-instructions"><h3>📖 How to Play</h3><ul><li>Click, tap, or press Space to flap</li><li>Avoid the pipes</li><li>Each pipe passed = 1 point</li></ul></div>
<script>
const cv=document.getElementById('c'),cx=cv.getContext('2d'),W=cv.width,H=cv.height;
const GAP=$gap,PW=$pipeW,GR=$gravity,JF=$jumpF,SP=$spd;
let bird,pipes,sc,bs=+localStorage.getItem('flap_$id')||0,running=false,over=false,anim;
document.getElementById('bs').textContent=bs;
function init(){bird={x:80,y:H/2,vy:0,r:14};pipes=[];sc=0;over=false;running=false;
document.getElementById('sc').textContent=0;draw();}
function addPipe(){let gy=60+Math.random()*(H-GAP-120);pipes.push({x:W,gy:gy,scored:false});}
function draw(){cx.fillStyle='#0f0f1a';cx.fillRect(0,0,W,H);
pipes.forEach(p=>{cx.fillStyle='#10b981';cx.fillRect(p.x,0,PW,p.gy);cx.fillRect(p.x,p.gy+GAP,PW,H-p.gy-GAP);
cx.fillStyle='#059669';cx.fillRect(p.x-3,p.gy-16,PW+6,16);cx.fillRect(p.x-3,p.gy+GAP,PW+6,16);});
cx.shadowColor='#f59e0b';cx.shadowBlur=12;cx.fillStyle='#f59e0b';cx.beginPath();cx.arc(bird.x,bird.y,bird.r,0,Math.PI*2);cx.fill();cx.shadowBlur=0;
cx.fillStyle='#0f0f1a';cx.beginPath();cx.arc(bird.x+5,bird.y-3,3,0,Math.PI*2);cx.fill();
if(over){cx.fillStyle='rgba(0,0,0,.7)';cx.fillRect(0,0,W,H);cx.fillStyle='#f1f5f9';cx.font='bold 28px Outfit';cx.textAlign='center';
cx.fillText('Game Over!',W/2,H/2-15);cx.font='16px Inter';cx.fillStyle='#94a3b8';cx.fillText('Score: '+sc,W/2,H/2+20);}
if(!running&&!over){cx.fillStyle='rgba(0,0,0,.5)';cx.fillRect(0,0,W,H);cx.fillStyle='#f1f5f9';cx.font='bold 20px Outfit';cx.textAlign='center';cx.fillText('Press Start or Space',W/2,H/2);}}
function update(){bird.vy+=GR;bird.y+=bird.vy;if(bird.y<bird.r)bird.y=bird.r;
if(bird.y>H-bird.r){end();return;}
if(pipes.length===0||pipes[pipes.length-1].x<W-180)addPipe();
pipes.forEach(p=>{p.x-=SP;if(!p.scored&&p.x+PW<bird.x){p.scored=true;sc++;document.getElementById('sc').textContent=sc;}
if(bird.x+bird.r>p.x&&bird.x-bird.r<p.x+PW){if(bird.y-bird.r<p.gy||bird.y+bird.r>p.gy+GAP)end();}});
pipes=pipes.filter(p=>p.x>-PW);}
function end(){over=true;running=false;cancelAnimationFrame(anim);if(sc>bs){bs=sc;localStorage.setItem('flap_$id',bs);document.getElementById('bs').textContent=bs;}
document.getElementById('sb').textContent='▶ Start';draw();}
function flap(){if(!running){go();return;}bird.vy=JF;}
function loop(){if(!running)return;update();draw();anim=requestAnimationFrame(loop);}
function go(){if(running)return;if(over)init();running=true;document.getElementById('sb').textContent='Playing...';loop();}
function rs(){cancelAnimationFrame(anim);document.getElementById('sb').textContent='▶ Start';init();}
document.onkeydown=e=>{if(e.code==='Space'){e.preventDefault();flap();}};cv.onclick=flap;cv.ontouchstart=e=>{e.preventDefault();flap();};
init();
</script>
"@ + (Foot)
Save $id $html $title $desc 'arcade' '🐦' 'orange'
}

# ===== DODGE GAME =====
function MakeDodge($id,$title,$desc,$pSpd,$obstSpd,$obstRate,$theme){
$html = (Head $title $desc "Arcade") + @"
<div class="game-container"><div class="game-score-bar"><div class="game-score-item"><span class="game-score-label">Score</span>
<span class="game-score-value" id="sc">0</span></div><div class="game-score-item"><span class="game-score-label">Best</span>
<span class="game-score-value" id="bs">0</span></div></div>
<div class="game-canvas-wrap"><canvas id="c" width="400" height="500"></canvas></div>
<div class="game-controls"><button class="game-btn game-btn-primary" id="sb" onclick="go()">▶ Start</button>
<button class="game-btn game-btn-secondary" onclick="rs()">↻ Restart</button></div></div>
<div class="game-instructions"><h3>📖 How to Play</h3><ul><li>Move mouse/touch or use Arrow keys</li><li>Dodge falling obstacles</li><li>Survive as long as you can!</li></ul></div>
<script>
const cv=document.getElementById('c'),cx=cv.getContext('2d'),W=cv.width,H=cv.height;
let player={x:W/2,y:H-40,w:30,h:30},obs=[],sc=0,bs=+localStorage.getItem('dodge_$id')||0,running=false,over=false,anim,fr=0;
document.getElementById('bs').textContent=bs;const keys={};
function draw(){cx.fillStyle='#0f0f1a';cx.fillRect(0,0,W,H);
cx.fillStyle='$theme';cx.shadowColor='$theme';cx.shadowBlur=10;cx.beginPath();cx.roundRect(player.x-player.w/2,player.y-player.h/2,player.w,player.h,6);cx.fill();cx.shadowBlur=0;
obs.forEach(o=>{cx.fillStyle='#ef4444';cx.beginPath();cx.roundRect(o.x,o.y,o.w,o.h,4);cx.fill();});
if(over){cx.fillStyle='rgba(0,0,0,.7)';cx.fillRect(0,0,W,H);cx.fillStyle='#f1f5f9';cx.font='bold 24px Outfit';cx.textAlign='center';cx.fillText('Game Over! Score: '+sc,W/2,H/2);}
if(!running&&!over){cx.fillStyle='rgba(0,0,0,.5)';cx.fillRect(0,0,W,H);cx.fillStyle='#f1f5f9';cx.font='bold 20px Outfit';cx.textAlign='center';cx.fillText('Press Start',W/2,H/2);}}
function update(){fr++;if(keys.ArrowLeft||keys.a)player.x-=$pSpd;if(keys.ArrowRight||keys.d)player.x+=$pSpd;
player.x=Math.max(player.w/2,Math.min(W-player.w/2,player.x));
if(fr%$obstRate===0){let w=15+Math.random()*30;obs.push({x:Math.random()*(W-w),y:-20,w:w,h:15+Math.random()*15,spd:$obstSpd+Math.random()*2});}
obs.forEach(o=>{o.y+=o.spd;});obs=obs.filter(o=>o.y<H+20);
obs.forEach(o=>{if(player.x+player.w/2>o.x&&player.x-player.w/2<o.x+o.w&&player.y+player.h/2>o.y&&player.y-player.h/2<o.y+o.h)end();});
sc++;document.getElementById('sc').textContent=Math.floor(sc/10);}
function end(){over=true;running=false;cancelAnimationFrame(anim);let s=Math.floor(sc/10);if(s>bs){bs=s;localStorage.setItem('dodge_$id',bs);document.getElementById('bs').textContent=bs;}
document.getElementById('sb').textContent='▶ Start';draw();}
function loop(){if(!running)return;update();draw();anim=requestAnimationFrame(loop);}
function go(){if(running)return;if(over){player={x:W/2,y:H-40,w:30,h:30};obs=[];sc=0;over=false;document.getElementById('sc').textContent=0;}
running=true;document.getElementById('sb').textContent='Playing...';loop();}
function rs(){cancelAnimationFrame(anim);player={x:W/2,y:H-40,w:30,h:30};obs=[];sc=0;over=false;running=false;
document.getElementById('sc').textContent=0;document.getElementById('sb').textContent='▶ Start';draw();}
document.onkeydown=e=>{keys[e.key]=true;};document.onkeyup=e=>{keys[e.key]=false;};
cv.onmousemove=e=>{let r=cv.getBoundingClientRect();player.x=e.clientX-r.left;};
cv.ontouchmove=e=>{e.preventDefault();let r=cv.getBoundingClientRect();player.x=e.touches[0].clientX-r.left;};
draw();
</script>
"@ + (Foot)
Save $id $html $title $desc 'arcade' '💨' 'pink'
}

# ===== WHACK A MOLE =====
function MakeWhack($id,$title,$desc,$gridS,$showTime,$dur){
$cells=$gridS*$gridS
$html = (Head $title $desc "Reflex") + @"
<div class="game-container"><div class="game-score-bar"><div class="game-score-item"><span class="game-score-label">Score</span>
<span class="game-score-value" id="sc">0</span></div><div class="game-score-item"><span class="game-score-label">Time</span>
<span class="game-score-value" id="tm">$dur</span></div></div>
<div style="display:grid;grid-template-columns:repeat($gridS,1fr);gap:8px;max-width:${gridS}00px;margin:0 auto;padding:24px" id="grid"></div>
<div class="game-controls"><button class="game-btn game-btn-primary" id="sb" onclick="go()">▶ Start</button></div></div>
<div class="game-instructions"><h3>📖 How to Play</h3><ul><li>Click/tap the moles when they appear!</li><li>Score as many as you can in $dur seconds</li></ul></div>
<style>.mole-cell{aspect-ratio:1;background:var(--bg-secondary);border:2px solid var(--border-color);border-radius:var(--radius-md);display:flex;align-items:center;justify-content:center;font-size:2rem;cursor:pointer;transition:all .15s;user-select:none}.mole-cell:hover{border-color:var(--border-hover)}.mole-cell.active{background:rgba(124,58,237,.2);border-color:var(--accent-primary);transform:scale(1.05)}.mole-cell.hit{background:rgba(16,185,129,.2);border-color:var(--accent-green)}</style>
<script>
const GS=$gridS,DUR=$dur,ST=$showTime;
let sc=0,tm=DUR,running=false,moleIdx=-1,ti,mi;
const grid=document.getElementById('grid');
for(let i=0;i<GS*GS;i++){const d=document.createElement('div');d.className='mole-cell';d.id='m'+i;d.textContent='🕳️';
d.onclick=()=>{if(!running||i!==moleIdx)return;sc++;document.getElementById('sc').textContent=sc;d.classList.remove('active');d.classList.add('hit');d.textContent='💥';
setTimeout(()=>{d.classList.remove('hit');d.textContent='🕳️';},200);showMole();};grid.appendChild(d);}
function showMole(){if(!running)return;if(moleIdx>=0){document.getElementById('m'+moleIdx).classList.remove('active');document.getElementById('m'+moleIdx).textContent='🕳️';}
moleIdx=Math.floor(Math.random()*GS*GS);document.getElementById('m'+moleIdx).classList.add('active');document.getElementById('m'+moleIdx).textContent='🐹';
clearTimeout(mi);mi=setTimeout(()=>{if(running){document.getElementById('m'+moleIdx).classList.remove('active');document.getElementById('m'+moleIdx).textContent='🕳️';showMole();}},ST);}
function go(){if(running)return;sc=0;tm=DUR;running=true;document.getElementById('sc').textContent=0;document.getElementById('tm').textContent=DUR;
document.getElementById('sb').textContent='Playing...';showMole();
ti=setInterval(()=>{tm--;document.getElementById('tm').textContent=tm;if(tm<=0){running=false;clearInterval(ti);clearTimeout(mi);
if(moleIdx>=0){document.getElementById('m'+moleIdx).classList.remove('active');document.getElementById('m'+moleIdx).textContent='🕳️';}
document.getElementById('sb').textContent='▶ Play Again';}},1000);}
</script>
"@ + (Foot)
Save $id $html $title $desc 'reflex' '🐹' 'orange'
}

# ===== AIM TRAINER =====
function MakeAim($id,$title,$desc,$targetMin,$targetMax,$dur){
$html = (Head $title $desc "Reflex") + @"
<div class="game-container"><div class="game-score-bar"><div class="game-score-item"><span class="game-score-label">Hits</span>
<span class="game-score-value" id="sc">0</span></div><div class="game-score-item"><span class="game-score-label">Misses</span>
<span class="game-score-value" id="ms">0</span></div><div class="game-score-item"><span class="game-score-label">Time</span>
<span class="game-score-value" id="tm">$dur</span></div></div>
<div class="game-canvas-wrap"><canvas id="c" width="500" height="400" style="cursor:crosshair"></canvas></div>
<div class="game-controls"><button class="game-btn game-btn-primary" id="sb" onclick="go()">▶ Start</button></div></div>
<div class="game-instructions"><h3>📖 How to Play</h3><ul><li>Click the targets as fast as you can</li><li>Don't miss or you lose accuracy</li></ul></div>
<script>
const cv=document.getElementById('c'),cx=cv.getContext('2d'),W=cv.width,H=cv.height;
let t={x:0,y:0,r:0},hits=0,misses=0,tm=$dur,running=false,ti;
function newTarget(){t.r=$targetMin+Math.random()*($targetMax-$targetMin);t.x=t.r+Math.random()*(W-2*t.r);t.y=t.r+Math.random()*(H-2*t.r);draw();}
function draw(){cx.fillStyle='#0f0f1a';cx.fillRect(0,0,W,H);if(!running){cx.fillStyle='#f1f5f9';cx.font='bold 20px Outfit';cx.textAlign='center';
cx.fillText(tm<=0?'Done! Hits: '+hits+' Accuracy: '+(hits+misses>0?Math.round(hits/(hits+misses)*100):0)+'%':'Press Start',W/2,H/2);return;}
cx.beginPath();cx.arc(t.x,t.y,t.r,0,Math.PI*2);cx.fillStyle='rgba(239,68,68,.2)';cx.fill();
cx.beginPath();cx.arc(t.x,t.y,t.r*.7,0,Math.PI*2);cx.fillStyle='rgba(239,68,68,.4)';cx.fill();
cx.beginPath();cx.arc(t.x,t.y,t.r*.4,0,Math.PI*2);cx.fillStyle='#ef4444';cx.fill();
cx.beginPath();cx.arc(t.x,t.y,t.r*.15,0,Math.PI*2);cx.fillStyle='#f1f5f9';cx.fill();}
cv.onclick=e=>{if(!running)return;let r=cv.getBoundingClientRect();let mx=e.clientX-r.left,my=e.clientY-r.top;
let d=Math.hypot(mx-t.x,my-t.y);if(d<=t.r){hits++;document.getElementById('sc').textContent=hits;newTarget();}
else{misses++;document.getElementById('ms').textContent=misses;}};
function go(){if(running)return;hits=0;misses=0;tm=$dur;running=true;
document.getElementById('sc').textContent=0;document.getElementById('ms').textContent=0;document.getElementById('tm').textContent=tm;
document.getElementById('sb').textContent='Playing...';newTarget();
ti=setInterval(()=>{tm--;document.getElementById('tm').textContent=tm;if(tm<=0){running=false;clearInterval(ti);document.getElementById('sb').textContent='▶ Again';draw();}},1000);}
draw();
</script>
"@ + (Foot)
Save $id $html $title $desc 'reflex' '🎯' 'pink'
}

# ===== MATH QUIZ =====
function MakeMath($id,$title,$desc,$op,$maxN,$timePerQ){
$html = (Head $title $desc "Puzzle") + @"
<div class="game-container" style="padding:24px">
<div class="game-score-bar" style="border:none;padding:0 0 16px"><div class="game-score-item"><span class="game-score-label">Score</span>
<span class="game-score-value" id="sc">0</span></div><div class="game-score-item"><span class="game-score-label">Streak</span>
<span class="game-score-value" id="st">0</span></div><div class="game-score-item"><span class="game-score-label">Time</span>
<span class="game-score-value" id="tm">$timePerQ</span></div></div>
<div style="text-align:center;padding:24px 0"><div style="font-family:Outfit;font-size:3rem;font-weight:800;color:var(--accent-secondary)" id="q">Press Start</div>
<input type="number" class="tool-input" id="ans" placeholder="Your answer..." style="max-width:200px;margin:16px auto;text-align:center;font-size:1.3rem" onkeydown="if(event.key==='Enter')check()">
<div style="margin-top:8px"><button class="game-btn game-btn-primary" onclick="check()">Submit</button></div>
<div id="fb" style="margin-top:12px;font-size:1.1rem;min-height:30px"></div></div>
<div class="game-controls" style="border:none"><button class="game-btn game-btn-primary" id="sb" onclick="go()">▶ Start</button></div></div>
<div class="game-instructions"><h3>📖 How to Play</h3><ul><li>Solve the math problem before time runs out</li><li>Type your answer and press Enter or Submit</li><li>Build streaks for bonus points!</li></ul></div>
<script>
const OP='$op',MX=$maxN,TPQ=$timePerQ;
let a,b,answer,sc=0,streak=0,tm=TPQ,running=false,ti;
function newQ(){let ops=OP.split('');let op=ops[Math.floor(Math.random()*ops.length)];
a=Math.floor(Math.random()*MX)+1;b=Math.floor(Math.random()*MX)+1;
if(op==='-'&&a<b){let t=a;a=b;b=t;}if(op==='÷'){a=b*(Math.floor(Math.random()*10)+1);}
if(op==='+')answer=a+b;else if(op==='-')answer=a-b;else if(op==='×')answer=a*b;else answer=a/b;
document.getElementById('q').textContent=a+' '+op+' '+b+' = ?';document.getElementById('ans').value='';document.getElementById('ans').focus();
tm=TPQ;document.getElementById('tm').textContent=tm;clearInterval(ti);
ti=setInterval(()=>{tm--;document.getElementById('tm').textContent=tm;if(tm<=0){streak=0;document.getElementById('st').textContent=0;
document.getElementById('fb').innerHTML='<span style="color:#ef4444">⏰ Time up! Answer: '+answer+'</span>';setTimeout(newQ,1500);}},1000);}
function check(){if(!running)return;let v=parseFloat(document.getElementById('ans').value);
if(v===answer){sc+=10+streak*2;streak++;document.getElementById('sc').textContent=sc;document.getElementById('st').textContent=streak;
document.getElementById('fb').innerHTML='<span style="color:#10b981">✓ Correct!</span>';setTimeout(newQ,800);}
else{streak=0;document.getElementById('st').textContent=0;
document.getElementById('fb').innerHTML='<span style="color:#ef4444">✗ Wrong! Answer: '+answer+'</span>';setTimeout(newQ,1500);}}
function go(){running=true;sc=0;streak=0;document.getElementById('sc').textContent=0;document.getElementById('st').textContent=0;
document.getElementById('sb').style.display='none';newQ();}
</script>
"@ + (Foot)
Save $id $html $title $desc 'puzzle' '🔢' 'blue'
}

# ===== COLOR MATCH =====
function MakeColorMatch($id,$title,$desc,$numColors,$timeLimit){
$html = (Head $title $desc "Reflex") + @"
<div class="game-container" style="padding:24px">
<div class="game-score-bar" style="border:none;padding:0 0 16px"><div class="game-score-item"><span class="game-score-label">Score</span>
<span class="game-score-value" id="sc">0</span></div><div class="game-score-item"><span class="game-score-label">Time</span>
<span class="game-score-value" id="tm">$timeLimit</span></div></div>
<div style="text-align:center;padding:20px 0"><div style="font-size:1rem;color:var(--text-muted);margin-bottom:8px">Does the TEXT COLOR match the WORD?</div>
<div style="font-family:Outfit;font-size:3.5rem;font-weight:800;padding:32px;background:var(--bg-secondary);border-radius:var(--radius-lg);margin-bottom:24px" id="word">Ready?</div>
<div style="display:flex;gap:12px;justify-content:center"><button class="game-btn game-btn-primary" onclick="pick(true)" style="min-width:120px">✓ Match</button>
<button class="game-btn game-btn-secondary" onclick="pick(false)" style="min-width:120px;border-color:#ef4444;color:#ef4444">✗ No Match</button></div>
<div id="fb" style="margin-top:12px;min-height:24px"></div></div>
<div class="game-controls" style="border:none"><button class="game-btn game-btn-primary" id="sb" onclick="go()">▶ Start</button></div></div>
<div class="game-instructions"><h3>📖 How to Play</h3><ul><li>A color word is shown in a colored font</li><li>Decide if the text COLOR matches the WORD shown</li><li>Click Match or No Match as fast as you can!</li></ul></div>
<script>
const COLORS=[{n:'Red',h:'#ef4444'},{n:'Blue',h:'#3b82f6'},{n:'Green',h:'#10b981'},{n:'Yellow',h:'#f59e0b'},{n:'Purple',h:'#a855f7'},{n:'Pink',h:'#ec4899'},{n:'Cyan',h:'#06b6d4'},{n:'Orange',h:'#f97316'}].slice(0,$numColors);
let isMatch,sc=0,tm=$timeLimit,running=false,ti;
function newRound(){let wi=Math.floor(Math.random()*COLORS.length);let ci;
if(Math.random()>.5){ci=wi;isMatch=true;}else{do{ci=Math.floor(Math.random()*COLORS.length);}while(ci===wi);isMatch=false;}
const w=document.getElementById('word');w.textContent=COLORS[wi].n;w.style.color=COLORS[ci].h;}
function pick(v){if(!running)return;if(v===isMatch){sc++;document.getElementById('sc').textContent=sc;
document.getElementById('fb').innerHTML='<span style="color:#10b981">✓</span>';}
else{document.getElementById('fb').innerHTML='<span style="color:#ef4444">✗</span>';}
setTimeout(()=>{document.getElementById('fb').innerHTML='';newRound();},300);}
function go(){sc=0;tm=$timeLimit;running=true;document.getElementById('sc').textContent=0;document.getElementById('tm').textContent=tm;
document.getElementById('sb').style.display='none';newRound();
ti=setInterval(()=>{tm--;document.getElementById('tm').textContent=tm;if(tm<=0){running=false;clearInterval(ti);
document.getElementById('word').textContent='Done! Score: '+sc;document.getElementById('word').style.color='#f1f5f9';
document.getElementById('sb').style.display='';document.getElementById('sb').textContent='▶ Again';}},1000);}
document.onkeydown=e=>{if(e.key==='ArrowLeft')pick(true);if(e.key==='ArrowRight')pick(false);};
</script>
"@ + (Foot)
Save $id $html $title $desc 'reflex' '🎨' 'pink'
}

Write-Host "Generating Batch 2..." -ForegroundColor Cyan

# FLAPPY VARIANTS (10)
for($i=0;$i -lt 10;$i++){
$gaps=@(130,120,140,110,150,100,135,125,115,105)
$spds=@(3,4,3,5,2,6,3,4,5,4)
$titles=@("Flappy Bird","Flappy Hard","Flappy Easy","Flappy Extreme","Flappy Chill","Flappy Insane","Flappy Classic","Flappy Pro","Flappy Speed","Flappy Tiny")
$descs=@("Classic flappy game","Hard mode flappy","Easy flappy fun","Extreme difficulty","Relaxed flappy","Insanely hard","Original style","Pro challenge","Fast pipes","Tiny gaps")
$num++;MakeFlappy $num $titles[$i] $descs[$i] $gaps[$i] 50 0.4 -7 $spds[$i]
}
Write-Host "  Flappy variants: 10" -ForegroundColor Yellow

# DODGE VARIANTS (10)
for($i=0;$i -lt 10;$i++){
$titles=@("Dodge Ball","Dodge Rain","Dodge Storm","Dodge Sprint","Dodge Easy","Dodge Chaos","Sky Dodge","Neon Dodge","Speed Dodge","Mega Dodge")
$spds=@(5,4,6,7,3,8,5,6,7,5)
$obstSpds=@(3,2,4,5,2,6,3,4,5,4)
$rates=@(20,25,15,12,30,10,18,14,11,16)
$colors=@('#a855f7','#3b82f6','#ef4444','#f59e0b','#10b981','#ec4899','#06b6d4','#a855f7','#f59e0b','#3b82f6')
$num++;MakeDodge $num $titles[$i] "Dodge falling objects - $($titles[$i])!" $spds[$i] $obstSpds[$i] $rates[$i] $colors[$i]
}
Write-Host "  Dodge variants: 10" -ForegroundColor Yellow

# WHACK A MOLE (10)
for($i=0;$i -lt 10;$i++){
$titles=@("Whack-a-Mole","Mole Frenzy","Quick Moles","Mole Sprint","Mole Easy","Mole Mania","Mole Hunter","Mole Blitz","Mole Master","Mega Moles")
$grids=@(3,3,4,3,3,4,3,4,4,4)
$times=@(1000,700,800,600,1500,500,900,650,750,550)
$durs=@(30,20,30,15,45,20,25,15,30,20)
$num++;MakeWhack $num $titles[$i] "$($titles[$i]) - whack em all!" $grids[$i] $times[$i] $durs[$i]
}
Write-Host "  Whack-a-Mole variants: 10" -ForegroundColor Yellow

# AIM TRAINER (10)
for($i=0;$i -lt 10;$i++){
$titles=@("Aim Trainer","Aim Pro","Aim Speed","Aim Sniper","Aim Easy","Aim Extreme","Aim Challenge","Precision Aim","Quick Shot","Target Master")
$mins=@(20,15,25,10,30,8,18,12,22,15)
$maxs=@(40,30,45,25,50,20,35,28,40,30)
$durs=@(30,20,30,20,45,15,30,25,20,30)
$num++;MakeAim $num $titles[$i] "$($titles[$i]) - test your aim!" $mins[$i] $maxs[$i] $durs[$i]
}
Write-Host "  Aim Trainer variants: 10" -ForegroundColor Yellow

# MATH QUIZ (10)
for($i=0;$i -lt 10;$i++){
$titles=@("Math Add","Math Subtract","Math Multiply","Math Divide","Math Mix","Quick Math","Math Hard","Math Easy","Math Blitz","Math Master")
$ops=@('+','-','×','÷','+,-','×,÷','+,-,×','÷','+,-,×,÷','+,-,×,÷')
$maxNs=@(50,30,12,10,50,12,20,20,30,50)
$tpqs=@(15,15,20,20,12,15,10,30,8,10)
$num++;MakeMath $num $titles[$i] "$($titles[$i]) - solve fast!" $ops[$i] $maxNs[$i] $tpqs[$i]
}
Write-Host "  Math Quiz variants: 10" -ForegroundColor Yellow

# COLOR MATCH (10)
for($i=0;$i -lt 10;$i++){
$titles=@("Color Match","Color Rush","Color Pro","Stroop Test","Color Easy","Color Extreme","Color Sprint","Color Focus","Color Zen","Color Chaos")
$nums=@(4,5,6,7,3,8,5,4,3,8)
$durs=@(30,20,30,25,45,15,20,30,60,15)
$num++;MakeColorMatch $num $titles[$i] "$($titles[$i]) - Stroop effect challenge!" $nums[$i] $durs[$i]
}
Write-Host "  Color Match variants: 10" -ForegroundColor Yellow

Write-Host "Batch 2 complete: $num games total" -ForegroundColor Green
$games | ConvertTo-Json | Out-File "d:\antigravity\games-list.json" -Encoding UTF8
