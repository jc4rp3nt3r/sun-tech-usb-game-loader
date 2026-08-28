/* Grid Runner — light cycles on a neon grid.
   A worked example for SUN Tech Unlimited: fixed-timestep loop, grid
   collision, and a deliberately simple opponent AI you can improve. */
(() => {
'use strict';
const c = document.getElementById('c'), ctx = c.getContext('2d');
const msg = document.getElementById('msg');
const scoreEl = document.getElementById('score'), roundEl = document.getElementById('round');

const COLS = 96, ROWS = 60;
let CELL = 10, offX = 0, offY = 0;

function fit() {
  const w = c.clientWidth, h = c.clientHeight, dpr = Math.min(devicePixelRatio || 1, 2);
  c.width = Math.round(w * dpr); c.height = Math.round(h * dpr);
  ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
  CELL = Math.floor(Math.min(w / COLS, h / ROWS));
  offX = Math.floor((w - CELL * COLS) / 2);
  offY = Math.floor((h - CELL * ROWS) / 2);
}
addEventListener('resize', fit);

const DIRS = { up:[0,-1], down:[0,1], left:[-1,0], right:[1,0] };
const OPP  = { up:'down', down:'up', left:'right', right:'left' };

let grid, riders, running = false, over = false, tick = 0, speed = 6, round = 1, score = 0;

function makeRider(x, y, dir, color, human) {
  return { x, y, dir, next: dir, color, human, alive: true, trail: [[x, y]] };
}

function reset(newRound) {
  grid = new Uint8Array(COLS * ROWS);
  riders = [
    makeRider(8, ROWS >> 1, 'right', '#22E8FF', true),
    makeRider(COLS - 9, (ROWS >> 1) - 8, 'left', '#FF6A00', false),
    makeRider(COLS - 9, (ROWS >> 1) + 8, 'left', '#FF1E6F', false)
  ];
  riders.forEach((r, i) => { grid[r.y * COLS + r.x] = i + 1; });
  tick = 0;
  speed = 6 + Math.min(round - 1, 6);
  over = false;
  if (newRound) roundEl.textContent = round;
}

const free = (x, y) => x >= 0 && y >= 0 && x < COLS && y < ROWS && !grid[y * COLS + x];

/* Opponent: prefer to keep going, turn only when the way ahead closes.
   Looks a few cells ahead so it doesn't corner itself immediately. */
function think(r) {
  const room = d => {
    const [dx, dy] = DIRS[d];
    let n = 0, x = r.x, y = r.y;
    while (n < 12 && free(x + dx, y + dy)) { x += dx; y += dy; n++; }
    return n;
  };
  const options = Object.keys(DIRS).filter(d => d !== OPP[r.dir]);
  const ahead = room(r.dir);
  if (ahead > 3 && Math.random() > 0.06) return r.dir;
  let best = r.dir, bestRoom = -1;
  for (const d of options) {
    const s = room(d) + Math.random() * 2;
    if (s > bestRoom) { bestRoom = s; best = d; }
  }
  return best;
}

function step() {
  for (const r of riders) {
    if (!r.alive) continue;
    if (!r.human) r.next = think(r);
    if (r.next !== OPP[r.dir]) r.dir = r.next;
    const [dx, dy] = DIRS[r.dir];
    const nx = r.x + dx, ny = r.y + dy;
    if (!free(nx, ny)) { r.alive = false; continue; }
    r.x = nx; r.y = ny;
    grid[ny * COLS + nx] = 1;
    r.trail.push([nx, ny]);
  }

  const you = riders[0];
  const bots = riders.slice(1).filter(r => r.alive).length;

  if (you.alive) { score += 1; scoreEl.textContent = score; }

  if (!you.alive) return end('DERESOLVED', 'The grid keeps your trail. Space to try again.');
  if (bots === 0)  return end('ROUND CLEAR', 'Both programs are down. Space for a faster round.', true);
}

function end(title, sub, won) {
  over = true; running = false;
  msg.innerHTML = `<h1>${title}</h1><p>${sub}</p>
    <p class="keys">Score ${score} · Round ${round} · Space to continue · Esc for the grid</p>`;
  msg.classList.remove('hide');
  if (won) round++; else { round = 1; score = 0; }
}

function draw() {
  const w = c.clientWidth, h = c.clientHeight;
  ctx.fillStyle = '#04060D';
  ctx.fillRect(0, 0, w, h);

  // arena grid
  ctx.strokeStyle = 'rgba(34,232,255,.07)';
  ctx.lineWidth = 1;
  ctx.beginPath();
  for (let x = 0; x <= COLS; x += 4) { ctx.moveTo(offX + x * CELL, offY); ctx.lineTo(offX + x * CELL, offY + ROWS * CELL); }
  for (let y = 0; y <= ROWS; y += 4) { ctx.moveTo(offX, offY + y * CELL); ctx.lineTo(offX + COLS * CELL, offY + y * CELL); }
  ctx.stroke();

  ctx.strokeStyle = 'rgba(255,106,0,.35)';
  ctx.strokeRect(offX + .5, offY + .5, COLS * CELL - 1, ROWS * CELL - 1);

  for (const r of riders) {
    ctx.fillStyle = r.color;
    ctx.shadowColor = r.color;
    ctx.shadowBlur = r.alive ? 9 : 0;
    ctx.globalAlpha = r.alive ? 1 : .3;
    for (const [x, y] of r.trail) ctx.fillRect(offX + x * CELL, offY + y * CELL, CELL, CELL);
    if (r.alive) {
      ctx.shadowBlur = 22; ctx.fillStyle = '#fff';
      ctx.fillRect(offX + r.x * CELL, offY + r.y * CELL, CELL, CELL);
    }
  }
  ctx.globalAlpha = 1; ctx.shadowBlur = 0;
}

let acc = 0, last = 0;
function loop(t) {
  requestAnimationFrame(loop);
  if (!last) last = t;
  const dt = Math.min(t - last, 100); last = t;
  if (running) {
    acc += dt;
    const interval = 1000 / speed;
    while (acc >= interval) { acc -= interval; if (running) step(); }
  }
  draw();
}
requestAnimationFrame(loop);

const KEYMAP = {
  ArrowUp:'up', ArrowDown:'down', ArrowLeft:'left', ArrowRight:'right',
  w:'up', s:'down', a:'left', d:'right', W:'up', S:'down', A:'left', D:'right'
};

addEventListener('keydown', e => {
  if (e.key === ' ') {
    e.preventDefault();
    if (!running) { reset(over); msg.classList.add('hide'); running = true; }
    return;
  }
  const d = KEYMAP[e.key];
  if (d) { e.preventDefault(); if (running) riders[0].next = d; }
});

fit(); reset(true); draw();
})();
