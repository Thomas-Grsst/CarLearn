// Usage : node fusion.js  -> génère index.html à partir de modele.html et de tous les sujets/*.json (thèmes alternés)
const fs = require('fs'), path = require('path');
const dir = path.join(__dirname, 'sujets');
const lots = fs.readdirSync(dir).filter(f => /^lot\d+\.json$/.test(f))
  .sort((a, b) => parseInt(a.slice(3)) - parseInt(b.slice(3)))
  .map(f => JSON.parse(fs.readFileSync(path.join(dir, f), 'utf8')));
const tous = [], vus = new Set();
for (let i = 0; lots.some(l => i < l.length); i++)
  for (const l of lots) if (l[i] && !vus.has(l[i].id)) { vus.add(l[i].id); tous.push(l[i]); }
for (const s of tous) if (!s.id || !s.titre || s.sections.length < 3 || s.quiz.length < 3) throw new Error('Sujet invalide : ' + s.id);
const html = fs.readFileSync(path.join(__dirname, 'modele.html'), 'utf8');
const out = html.replace(/const SUJETS = \[[\s\S]*?\n\];/, () => 'const SUJETS = [\n' + tous.map(t => JSON.stringify(t)).join(',\n') + '\n];');
fs.writeFileSync(path.join(__dirname, 'index.html'), out);
console.log(tous.length + ' sujets intégrés');
