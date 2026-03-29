const fs = require('fs');
const path = require('path');

const listPath = 'd:\\antigravity\\games-list.json';
const gamesDir = 'd:\\antigravity\\games';
const indexPath = 'd:\\antigravity\\index.html';

// 1. Read existing games
let games = JSON.parse(fs.readFileSync(listPath, 'utf8'));
let nextId = Math.max(...games.map(g => parseInt(g.id))) + 1;

function head(title, desc, cat) {
  return `<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>${title} - WebFunHub</title><meta name="description" content="${desc}">
<link rel="stylesheet" href="../style.css"></head><body>
<nav class="navbar" id="nb"><a href="../index.html" class="nav-brand"><div class="nav-brand-icon">W</div><span class="nav-brand-text">WebFunHub</span></a>
<ul class="nav-links" id="nl"><li><a href="../index.html">Home</a></li><li><a href="../index.html#games" class="active">Games</a></li></ul>
<button class="nav-menu-btn" id="mb" aria-label="Menu">☰</button></nav>
<div class="ad-banner" style="margin-top:80px;max-width:728px">Ad Space</div>
<main class="game-page"><div class="game-page-header"><a href="../index.html#games" class="game-page-back">← Back</a>
<h1 class="game-page-title">${title}</h1><div class="game-page-meta"><span class="game-page-tag" style="text-transform:capitalize">${cat}</span></div></div>
<div class="game-container">
<div class="game-score-bar">
<div class="game-score-item"><span class="game-score-label">Score</span><span class="game-score-value" id="sc">0</span></div>
<div class="game-score-item"><span class="game-score-label">High Score</span><span class="game-score-value" id="hi">0</span></div>
</div>
<div class="game-canvas-wrap" style="padding:0;overflow:hidden;background:#111;position:relative;display:flex;justify-content:center;">
<canvas id="c" width="400" height="600" style="max-width:100%;background:#222;box-shadow:0 0 20px rgba(0,0,0,0.5);"></canvas>
<div id="over" style="display:none;position:absolute;inset:0;background:rgba(0,0,0,0.8);backdrop-filter:blur(4px);flex-direction:column;align-items:center;justify-content:center;color:#fff;">
<h2 style="font-size:3rem;margin-bottom:10px;font-family:Outfit;color:var(--accent-secondary)">GAME OVER</h2>
<p style="font-size:1.2rem;margin-bottom:20px">Score: <span id="fsc">0</span></p>
<button class="game-btn game-btn-primary" onclick="init()">Play Again</button>
</div>
</div>
<div class="game-controls"><button class="game-btn game-btn-primary" onclick="init()">↻ Restart</button></div>
`;
}

function foot() {
  return `</div></main>
<div class="ad-banner" style="max-width:728px;margin:24px auto">Ad Space</div>
<footer class="footer"><div class="footer-bottom">© 2026 WebFunHub</div></footer>
<script>document.getElementById('mb').onclick=()=>document.getElementById('nl').classList.toggle('open');
window.onscroll=()=>document.getElementById('nb').classList.toggle('scrolled',scrollY>20);</script></body></html>`;
}

// CAR Racing Template
function makeCarRace(speedMulti, enemyFreq, bgCol) {
  return `</div>
<div class="game-instructions" style="margin:0 24px 24px"><h3>📖 How to Play</h3><ul><li>Use <b>Left/Right Arrows</b> or <b>Tap sides</b> to steer your car.</li><li>Dodge traffic and survive as long as possible!</li></ul></div>
<script>
const cvs = document.getElementById('c'), ctx = cvs.getContext('2d');
let sc=0, hi=localStorage.getItem('carhi')||0, state=0; // 0=menu, 1=play, 2=over
let player, enemies, frame, speed=${speedMulti};
document.getElementById('hi').textContent = hi;

function init() {
  player = {x: 175, y: 500, w: 50, h: 80, c: '#3b82f6'};
  enemies = [];
  sc = 0; frame = 0; state = 1;
  document.getElementById('over').style.display='none';
  document.getElementById('sc').textContent=sc;
  loop();
}

function drawCar(x,y,w,h,c) {
  ctx.fillStyle=c; ctx.fillRect(x,y,w,h);
  ctx.fillStyle='#111'; ctx.fillRect(x-5,y+10,10,20); ctx.fillRect(x+w-5,y+10,10,20);
  ctx.fillRect(x-5,y+50,10,20); ctx.fillRect(x+w-5,y+50,10,20);
  ctx.fillStyle='#888'; ctx.fillRect(x+10,y+15,w-20,15); ctx.fillRect(x+10,y+50,w-20,10);
}

function loop() {
  if(state!==1) return;
  requestAnimationFrame(loop);
  ctx.fillStyle='${bgCol}'; ctx.fillRect(0,0,400,600);
  
  // Roads
  ctx.fillStyle='#444'; ctx.fillRect(50,0,300,600);
  ctx.fillStyle='#fff';
  for(let i=0; i<600; i+=60) {
    if((i+frame*speed)%60 < 30) {
      ctx.fillRect(145, i, 10, 30);
      ctx.fillRect(245, i, 10, 30);
    }
  }

  // Player
  drawCar(player.x, player.y, player.w, player.h, player.c);

  // Enemies
  if(frame % ${Math.floor(60/enemyFreq)} === 0) {
    let lanes = [65, 165, 265];
    enemies.push({x: lanes[Math.floor(Math.random()*3)], y: -100, w: 50, h: 80, c: ['#ef4444','#f59e0b','#ec4899','#10b981'][Math.floor(Math.random()*4)]});
  }

  for(let i=enemies.length-1; i>=0; i--) {
    let e = enemies[i];
    e.y += speed * 0.8 + Math.random()*2; // slight diff speeds
    drawCar(e.x, e.y, e.w, e.h, e.c);
    
    // Collision
    if(player.x < e.x+e.w && player.x+player.w > e.x && player.y < e.y+e.h && player.h+player.y > e.y) {
      state = 2; // crash
      document.getElementById('fsc').textContent = Math.floor(sc);
      if(Math.floor(sc)>hi) { hi = Math.floor(sc); localStorage.setItem('carhi', hi); document.getElementById('hi').textContent=hi; }
      document.getElementById('over').style.display='flex';
      return;
    }
    
    if(e.y > 600) { enemies.splice(i, 1); }
  }

  sc += 0.05 * speed;
  document.getElementById('sc').textContent = Math.floor(sc);
  if(frame%300===0) speed+=0.2; // Increase speed over time
  frame++;
}

window.addEventListener('keydown', e => {
  if(state!==1) return;
  if(e.key==='ArrowLeft' && player.x > 55) player.x -= 100;
  if(e.key==='ArrowRight' && player.x < 250) player.x += 100;
});
cvs.addEventListener('mousedown', e => {
  if(state!==1) return;
  const rect = cvs.getBoundingClientRect();
  const x = e.clientX - rect.left;
  if(x < rect.width/2 && player.x > 55) player.x -= 100;
  else if(x >= rect.width/2 && player.x < 250) player.x += 100;
});
cvs.addEventListener('touchstart', e => {
  e.preventDefault();
  if(state!==1) return;
  const rect = cvs.getBoundingClientRect();
  const touch = e.touches[0];
  const x = touch.clientX - rect.left;
  if(x < rect.width/2 && player.x > 55) player.x -= 100;
  else if(x >= rect.width/2 && player.x < 250) player.x += 100;
}, {passive:false});

init();
</script>
`;
}

// BATTLE Shooter Template
function makeBattle(fireRate, enemySpeed, bgCol) {
  return `</div>
<div class="game-instructions" style="margin:0 24px 24px"><h3>📖 How to Play</h3><ul><li>Use <b>Mouse/Touch</b> to slide your ship.</li><li>Shoot falling enemies automatically. Don't let them hit you or the bottom!</li></ul></div>
<script>
const cvs = document.getElementById('c'), ctx = cvs.getContext('2d');
let sc=0, hi=localStorage.getItem('bathhi')||0, state=0; 
let player, bullets, enemies, frame;
document.getElementById('hi').textContent = hi;

function init() {
  player = {x: 180, y: 520, w: 40, h: 40, c: '#06b6d4'};
  bullets = []; enemies = [];
  sc = 0; frame = 0; state = 1;
  document.getElementById('over').style.display='none';
  document.getElementById('sc').textContent=sc;
  loop();
}

function loop() {
  if(state!==1) return;
  requestAnimationFrame(loop);
  ctx.fillStyle='${bgCol}'; ctx.fillRect(0,0,400,600);
  
  // Stars
  ctx.fillStyle='#fff';
  for(let i=0;i<20;i++) {
    let sy = (Array(20).fill(0).map((_,i)=>(i*30 + frame)%600))[i];
    ctx.globalAlpha = Math.random();
    ctx.fillRect(Math.abs(Math.sin(i*23)*400), sy, 2, 2);
  }
  ctx.globalAlpha = 1;

  // Player
  ctx.fillStyle=player.c;
  ctx.beginPath();
  ctx.moveTo(player.x+20, player.y);
  ctx.lineTo(player.x+40, player.y+40);
  ctx.lineTo(player.x, player.y+40);
  ctx.fill();

  // Shoot
  if(frame % ${fireRate} === 0) {
    bullets.push({x: player.x+18, y: player.y, w: 4, h: 10});
  }

  // Bullets
  ctx.fillStyle='#f59e0b';
  for(let i=bullets.length-1; i>=0; i--) {
    let b = bullets[i];
    b.y -= 10;
    ctx.fillRect(b.x, b.y, b.w, b.h);
    if(b.y < -10) bullets.splice(i,1);
  }

  // Enemies
  if(frame % ${Math.floor(120/enemySpeed)} === 0) {
    enemies.push({x: Math.random()*360, y: -40, w: 30, h: 30, hp: 1});
  }

  ctx.fillStyle='#ef4444';
  for(let i=enemies.length-1; i>=0; i--) {
    let e = enemies[i];
    e.y += ${enemySpeed} + (sc/50);
    ctx.fillRect(e.x, e.y, e.w, e.h);
    
    // Hit by bullet
    for(let j=bullets.length-1; j>=0; j--) {
      let b = bullets[j];
      if(b.x < e.x+e.w && b.x+b.w > e.x && b.y < e.y+e.h && b.h+b.y > e.y) {
        enemies.splice(i,1);
        bullets.splice(j,1);
        sc+=10; document.getElementById('sc').textContent=sc;
        break;
      }
    }
    
    // Hit player or bottom
    if(e && ((player.x < e.x+e.w && player.x+player.w > e.x && player.y < e.y+e.h && player.h+player.y > e.y) || e.y > 600)) {
      state = 2; // game over
      document.getElementById('fsc').textContent = sc;
      if(sc>hi) { hi = sc; localStorage.setItem('bathhi', hi); document.getElementById('hi').textContent=hi; }
      document.getElementById('over').style.display='flex';
      return;
    }
  }

  frame++;
}

function move(cx) {
  if(state!==1) return;
  const rect = cvs.getBoundingClientRect();
  const scaleX = cvs.width / rect.width;
  let x = (cx - rect.left) * scaleX - player.w/2;
  player.x = Math.max(0, Math.min(360, x));
}

cvs.addEventListener('mousemove', e => move(e.clientX));
cvs.addEventListener('touchmove', e => {
  e.preventDefault();
  move(e.touches[0].clientX);
}, {passive:false});

init();
</script>
`;
}

// Generate 15 Car Games
const carAdjs = ['Neon', 'Midnight', 'Turbo', 'Drift', 'Highway', 'Street', 'Nitro', 'Cyber', 'Urban', 'Desert', 'City', 'Speed', 'Formula', 'Rally', 'Furious'];
for(let i=0; i<15; i++) {
  let id = (nextId++).toString().padStart(3, '0');
  let speedMulti = 5 + (i * 0.5);
  let enemyFreq = 1 + (i * 0.1);
  let title = `${carAdjs[i]} Racer`;
  let cat = 'racing';
  let html = head(title, `High speed ${title} car racing game. Dodge traffic and survive!`, cat) + makeCarRace(speedMulti, enemyFreq, '#15803d');
  
  fs.writeFileSync(path.join(gamesDir, `game-${id}.html`), html);
  games.push({ id, title, desc: `Thrilling car racing action in ${title}. Beat your high score!`, category: cat, icon: '🏎️', gradient: 'orange' });
}

// Generate 15 Battle Games
const batAdjs = ['Galactic', 'Space', 'Alien', 'Star', 'Neon', 'Cosmic', 'Void', 'Orbit', 'Galaxy', 'Pixel', 'Astro', 'Quantum', 'Plasma', 'Nova', 'Titan'];
for(let i=0; i<15; i++) {
  let id = (nextId++).toString().padStart(3, '0');
  let fireRate = Math.max(4, 15 - Math.floor(i/2));
  let enemySpeed = 1.5 + (i * 0.2);
  let title = `${batAdjs[i]} Invaders`;
  let cat = 'battle';
  let html = head(title, `Intense ${title} space battle game. Defend your ship!`, cat) + makeBattle(fireRate, enemySpeed, '#0f172a');
  
  fs.writeFileSync(path.join(gamesDir, `game-${id}.html`), html);
  games.push({ id, title, desc: `Epic space battles await in ${title}. Destroy the enemies!`, category: cat, icon: '🚀', gradient: 'blue' });
}

fs.writeFileSync(listPath, JSON.stringify(games, null, 2));

// Update index.html
let indexHtml = fs.readFileSync(indexPath, 'utf8');
indexHtml = indexHtml.replace(/const games = \[[\s\S]*?\];/, `const games = ${JSON.stringify(games, null, 2)};`);
indexHtml = indexHtml.replace(/<div class="hero-stat-number" id="gameCount">\d+<\/div>/, `<div class="hero-stat-number" id="gameCount">${games.length}</div>`);

// Add tags for racing and battle to filter UI if not exist
if(!indexHtml.includes('data-filter="racing"')) {
  indexHtml = indexHtml.replace('</div', '  <span class="filter-tag" data-filter="racing">Racing</span>\n      <span class="filter-tag" data-filter="battle">Battle</span>\n    </div');
}

fs.writeFileSync(indexPath, indexHtml);
console.log(`Generated 30 new games! Total now: ${games.length}`);
