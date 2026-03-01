const express = require('express');
const fs = require('fs');
const path = require('path');
const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json({ limit: '5mb' }));
app.use('/public', express.static('public'));

// --- Bot Flow Storage (JSON files, same format as Chatwoot addon) ---
const BOTS_DIR = path.join(__dirname, 'data', 'bots');
if (!fs.existsSync(BOTS_DIR)) fs.mkdirSync(BOTS_DIR, { recursive: true });

function allBots() {
  try {
    return fs.readdirSync(BOTS_DIR)
      .filter(f => f.endsWith('.json'))
      .map(f => JSON.parse(fs.readFileSync(path.join(BOTS_DIR, f), 'utf8')))
      .sort((a, b) => (b.updated_at || '').localeCompare(a.updated_at || ''));
  } catch { return []; }
}

function findBot(id) {
  try {
    const p = path.join(BOTS_DIR, `${id}.json`);
    return fs.existsSync(p) ? JSON.parse(fs.readFileSync(p, 'utf8')) : null;
  } catch { return null; }
}

function saveBot(data) {
  data.id = data.id || `${Date.now()}${String(Math.floor(Math.random() * 1000)).padStart(3, '0')}`;
  data.updated_at = new Date().toISOString();
  data.created_at = data.created_at || new Date().toISOString();
  data.account_id = data.account_id || 1;
  fs.writeFileSync(path.join(BOTS_DIR, `${data.id}.json`), JSON.stringify(data, null, 2));
  return data;
}

function deleteBot(id) {
  const p = path.join(BOTS_DIR, `${id}.json`);
  if (fs.existsSync(p)) fs.unlinkSync(p);
}

// --- Mock metadata ---
const meta = JSON.parse(fs.readFileSync(path.join(__dirname, 'data', 'mock-meta.json'), 'utf8'));
const campaigns = JSON.parse(fs.readFileSync(path.join(__dirname, 'data', 'mock-campaigns.json'), 'utf8'));

// --- Locale detection ---
function detectLocale(req) {
  if (req.query.lang) return req.query.lang;
  const accept = req.headers['accept-language'] || '';
  if (accept.startsWith('he')) return 'he';
  return 'en';
}

// --- HTML pages ---
function sendPage(res, file, replacements = {}) {
  let html = fs.readFileSync(path.join(__dirname, 'views', file), 'utf8');
  for (const [key, val] of Object.entries(replacements)) {
    html = html.split(key).join(val);
  }
  res.type('html').send(html);
}

// --- Routes: Landing ---
app.get('/', (req, res) => sendPage(res, 'index.html'));

// --- Routes: Bot Builder Pages ---
app.get('/bot-builder', (req, res) => sendPage(res, 'bot-list.html', {
  '__LOCALE__': JSON.stringify(detectLocale(req))
}));
app.get('/bot-builder/new', (req, res) => sendPage(res, 'bot-editor.html', {
  '__BOT_ID__': 'null',
  '__LOCALE__': JSON.stringify(detectLocale(req))
}));
app.get('/bot-builder/:id/edit', (req, res) => sendPage(res, 'bot-editor.html', {
  '__BOT_ID__': JSON.stringify(req.params.id),
  '__LOCALE__': JSON.stringify(detectLocale(req))
}));

// --- Routes: Bot Builder API ---
app.get('/bot-builder/api/bots', (req, res) => res.json(allBots()));
app.post('/bot-builder/api/bots', (req, res) => res.json(saveBot(req.body)));
app.get('/bot-builder/api/bots/:id', (req, res) => {
  const bot = findBot(req.params.id);
  res.json(bot || { error: 1 });
});
app.delete('/bot-builder/api/bots/:id', (req, res) => {
  deleteBot(req.params.id);
  res.json({ ok: 1 });
});
app.post('/bot-builder/api/bots/:id/toggle', (req, res) => {
  const bot = findBot(req.params.id);
  if (!bot) return res.json({ error: 1 });
  bot.active = !bot.active;
  res.json(saveBot(bot));
});

// --- Routes: Metadata API (mock) ---
app.get('/bot-builder/api/inboxes', (req, res) => res.json(meta.inboxes));
app.get('/bot-builder/api/agents', (req, res) => res.json(meta.agents));
app.get('/bot-builder/api/labels', (req, res) => res.json(meta.labels));
app.get('/bot-builder/api/teams', (req, res) => res.json(meta.teams));
app.get('/bot-builder/api/custom_attributes', (req, res) => res.json(meta.custom_attributes || []));
app.get('/bot-builder/api/contact_fields', (req, res) => res.json([
  { key: 'name', label: 'Name' },
  { key: 'email', label: 'Email' },
  { key: 'phone_number', label: 'Phone' },
  { key: 'city', label: 'City' },
  { key: 'country', label: 'Country' }
]));

// --- Routes: Campaign Report ---
app.get('/campaign-report', (req, res) => sendPage(res, 'campaign-list.html', {
  '__LOCALE__': JSON.stringify(detectLocale(req)),
  '__CAMPAIGNS__': JSON.stringify(campaigns)
}));
app.get('/campaign-report/:id', (req, res) => {
  const c = campaigns.find(c => String(c.id) === req.params.id);
  if (!c) return res.status(404).type('html').send('<h1>Campaign not found</h1>');
  sendPage(res, 'campaign-detail.html', {
    '__LOCALE__': JSON.stringify(detectLocale(req)),
    '__CAMPAIGN__': JSON.stringify(c)
  });
});

app.listen(PORT, () => console.log(`Chatwoot Addons running on http://localhost:${PORT}`));
