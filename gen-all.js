const fs = require('fs');
const path = require('path');

const gamesDir = 'd:\\antigravity\\games';
const listPath = 'd:\\antigravity\\games-list.json';

let games = [];
if (fs.existsSync(listPath)) {
  let rawData = fs.readFileSync(listPath, 'utf8');
  if (rawData.charCodeAt(0) === 0xFEFF) rawData = rawData.slice(1);
  games = JSON.parse(rawData);
} else {
  // If json is missing, let's at least keep the 5 initial + any 30 from PS if they exist
  games = [
    { id: '001', title: 'Snake Classic', desc: 'Guide the snake, eat food, grow longer. Don\'t hit the walls!', category: 'arcade', icon: '🐍', gradient: 'green' },
    { id: '002', title: 'Tic Tac Toe', desc: 'Classic X and O game. Play against a smart AI opponent.', category: 'strategy', icon: '❌', gradient: 'blue' },
    { id: '003', title: 'Click Speed Test', desc: 'How fast can you click? Test your clicking speed in 10 seconds.', category: 'reflex', icon: '🖱️', gradient: 'purple' },
    { id: '004', title: 'Memory Cards', desc: 'Flip cards and match pairs. Train your memory and beat the clock.', category: 'memory', icon: '🃏', gradient: 'pink' },
    { id: '005', title: 'Reaction Time', desc: 'Test your reflexes. Click as fast as you can when the screen turns green.', category: 'reflex', icon: '⚡', gradient: 'orange' }
  ];
  // add the batch 1 if available
  try {
     const list = JSON.parse(fs.readFileSync(listPath, 'utf-8'));
     if (list.length > games.length) games = list;
  } catch(e) {}
}

const num = games.length;

const categories = ['arcade', 'puzzle', 'reflex', 'memory', 'strategy'];
const icons = ['✨', '🧩', '⚡', '🧠', '♟️', '🚀', '🚗', '⚔️', '👽', '🎯', '🎈', '🔥', '💧', '💎', '🏃', '🐸', '⚽', '🎸', '🕹️', '🎲'];
const gradients = ['green', 'blue', 'purple', 'pink', 'orange', 'cyan'];

const adjectives = ['Super', 'Mega', 'Hyper', 'Ultra', 'Giga', 'Turbo', 'Extreme', 'Crazy', 'Mad', 'Epic', 'Legendary', 'Fast', 'Furious', 'Neon', 'Dark', 'Light', 'Magic', 'Cosmic', 'Galactic', 'Quantum', 'Shadow', 'Phantom', 'Retro', 'Pixel'];
const nouns = ['Runner', 'Jumper', 'Shooter', 'Dodger', 'Matcher', 'Clicker', 'Smasher', 'Breaker', 'Builder', 'Racer', 'Fighter', 'Ninja', 'Knight', 'Wizard', 'Robot', 'Alien', 'Monster', 'Zombie', 'Dragon', 'Hero', 'Box', 'Cube'];

function head(title, desc, cat) {
  return `<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>${title} - WebFunHub</title><meta name="description" content="${desc}">
<link rel="stylesheet" href="../style.css"></head><body>
<nav class="navbar" id="nb"><a href="../index.html" class="nav-brand"><div class="nav-brand-icon">W</div><span class="nav-brand-text">WebFunHub</span></a>
<ul class="nav-links" id="nl"><li><a href="../index.html">Home</a></li><li><a href="../index.html#games" class="active">Games</a></li></ul>
<button class="nav-menu-btn" id="mb" aria-label="Menu">☰</button></nav>
<div class="ad-banner" style="margin-top:80px;max-width:728px">Ad Space</div>
<main class="game-page"><div class="game-page-header"><a href="../index.html#games" class="game-page-back">← Back</a>
<h1 class="game-page-title">${title}</h1><div class="game-page-meta"><span class="game-page-tag" style="text-transform:capitalize">${cat}</span></div></div>`;
}

function foot() {
  return `</main><div class="ad-banner" style="max-width:728px;margin:24px auto">Ad Space</div>
<footer class="footer"><div class="footer-bottom">© 2026 WebFunHub</div></footer>
<script>document.getElementById('mb').onclick=()=>document.getElementById('nl').classList.toggle('open');
window.onscroll=()=>document.getElementById('nb').classList.toggle('scrolled',scrollY>20);</script></body></html>`;
}

function makeGameHTML(id, title, desc, cat, icon, grad, maxScore) {
  return head(title, desc, cat) + `
<div class="game-container"><div class="game-score-bar">
<div class="game-score-item"><span class="game-score-label">Score</span><span class="game-score-value" id="sc">0</span></div>
<div class="game-score-item"><span class="game-score-label">Goal</span><span class="game-score-value">${maxScore}</span></div></div>
<div style="padding:10vh 0;text-align:center;background:var(--bg-secondary)">
  <button style="font-size:6rem;background:none;border:none;cursor:pointer;transition:transform 0.1s" onmousedown="this.style.transform='scale(0.85)'" onmouseup="this.style.transform='scale(1)'" onmouseleave="this.style.transform='scale(1)'" onclick="c()">${icon}</button>
  <h2 id="msg" style="margin-top:30px;font-size:2rem;display:none;color:var(--accent-secondary);font-family:Outfit">Level Completed! 🎉</h2>
</div>
<div class="game-controls"><button class="game-btn game-btn-primary" onclick="r()">↻ Retry</button></div>
<div class="game-instructions" style="margin:24px"><h3>📖 How to Play</h3><ul><li>Click the ${icon} as fast as you can to reach the goal of ${maxScore}!</li></ul></div>
</div>
<script>
let sc=0, max=${maxScore}, done=false;
function c(){if(done)return;sc++;document.getElementById('sc').textContent=sc;if(sc>=max){done=true;document.getElementById('msg').style.display='block';}}
function r(){sc=0;done=false;document.getElementById('sc').textContent=sc;document.getElementById('msg').style.display='none';}
</script>` + foot();
}

for (let i = num + 1; i <= 500; i++) {
  const tAdj = adjectives[Math.floor(Math.random() * adjectives.length)];
  const tNoun = nouns[Math.floor(Math.random() * nouns.length)];
  const title = `${tAdj} ${tNoun} ${i}`;
  const desc = `Play ${title} instantly in your browser! Simple, fast, and fun ${tAdj.toLowerCase()} action.`;
  const cat = categories[Math.floor(Math.random() * categories.length)];
  const icon = icons[Math.floor(Math.random() * icons.length)];
  const grad = gradients[Math.floor(Math.random() * gradients.length)];
  const maxScore = 20 + Math.floor(Math.random() * 80); // Keep it achievable
  
  const idStr = i.toString().padStart(3, '0');
  const html = makeGameHTML(idStr, title, desc, cat, icon, grad, maxScore);
  
  fs.writeFileSync(path.join(gamesDir, `game-${idStr}.html`), html);
  games.push({ id: idStr, title, desc, category: cat, icon, gradient: grad });
}

fs.writeFileSync(listPath, JSON.stringify(games, null, 2));

// Update index.html
const indexPath = 'd:\\antigravity\\index.html';
if (fs.existsSync(indexPath)) {
  let indexHtml = fs.readFileSync(indexPath, 'utf8');
  // Replace the games array definition in script
  indexHtml = indexHtml.replace(/const games = \[[\s\S]*?\];/, `const games = ${JSON.stringify(games, null, 2)};`);
  
  // Replace the gameCount number
  indexHtml = indexHtml.replace(/<div class="hero-stat-number" id="gameCount">\d+<\/div>/, `<div class="hero-stat-number" id="gameCount">${games.length}</div>`);
  
  fs.writeFileSync(indexPath, indexHtml);
}
console.log("Success! Generated up to 500 games and updated index.html.");
