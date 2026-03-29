const fs = require('fs');

const listPath = 'd:\\antigravity\\games-list.json';
const indexPath = 'd:\\antigravity\\index.html';

let rawData = fs.readFileSync(listPath, 'utf8');
if (rawData.charCodeAt(0) === 0xFEFF) rawData = rawData.slice(1);
let games = JSON.parse(rawData);

// Normalize cat to category and fix encoding issues (like snake icon)
games = games.map(g => {
  if (g.cat) {
    g.category = g.cat;
    delete g.cat;
  }
  if (g.icon === 'ðŸ  ') g.icon = '🐍';
  if (g.icon === 'ðŸ§±') g.icon = '🧱';
  if (g.icon === 'ðŸ “') g.icon = '🏓';
  return g;
});

// Add missing 001-005 if not present
const existingIds = games.map(g => g.id);
const missing = [];
if (!existingIds.includes('001')) missing.push({ id: '001', title: 'Snake Classic', desc: 'Guide the snake, eat food, grow longer. Don\'t hit the walls!', category: 'arcade', icon: '🐍', gradient: 'green' });
if (!existingIds.includes('002')) missing.push({ id: '002', title: 'Tic Tac Toe', desc: 'Classic X and O game. Play against a smart AI opponent.', category: 'strategy', icon: '❌', gradient: 'blue' });
if (!existingIds.includes('003')) missing.push({ id: '003', title: 'Click Speed Test', desc: 'How fast can you click? Test your clicking speed in 10 seconds.', category: 'reflex', icon: '🖱️', gradient: 'purple' });
if (!existingIds.includes('004')) missing.push({ id: '004', title: 'Memory Cards', desc: 'Flip cards and match pairs. Train your memory and beat the clock.', category: 'memory', icon: '🃏', gradient: 'pink' });
if (!existingIds.includes('005')) missing.push({ id: '005', title: 'Reaction Time', desc: 'Test your reflexes. Click as fast as you can when the screen turns green.', category: 'reflex', icon: '⚡', gradient: 'orange' });

games = missing.concat(games).sort((a,b) => parseInt(a.id) - parseInt(b.id));

fs.writeFileSync(listPath, JSON.stringify(games, null, 2));

// Update index.html again
let indexHtml = fs.readFileSync(indexPath, 'utf8');
indexHtml = indexHtml.replace(/const games = \[[\s\S]*?\];/, `const games = ${JSON.stringify(games, null, 2)};`);
indexHtml = indexHtml.replace(/<div class="hero-stat-number" id="gameCount">\d+<\/div>/, `<div class="hero-stat-number" id="gameCount">${games.length}</div>`);
fs.writeFileSync(indexPath, indexHtml);

console.log('Fixed games list, count:', games.length);
