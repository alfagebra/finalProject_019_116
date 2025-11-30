const express = require('express');
const cors = require('cors');
const fs = require('fs');
const path = require('path');

const app = express();
app.use(cors());
app.use(express.json());

const DATA_PATH = path.join(__dirname, '..', 'assets', 'data', 'pbm_materi.json');
let db = null;

function loadData() {
  try {
    const raw = fs.readFileSync(DATA_PATH, 'utf8');
    db = JSON.parse(raw);
    console.log('Loaded JSON:', DATA_PATH);
  } catch (err) {
    console.error('Failed to load JSON:', err);
    db = { judul_materi: 'empty', rangkuman_topik: [] };
  }
}

loadData();

// GET /materi - return full JSON
app.get('/materi', (req, res) => {
  return res.json(db);
});

// GET /topics - return an array of { topik_id, judul_topik }
app.get('/topics', (req, res) => {
  const list = (db.rangkuman_topik || []).map(t => ({ topik_id: t.topik_id, judul_topik: t.judul_topik }));
  return res.json(list);
});

// GET /topic/:id - return the full topic object by topik_id
app.get('/topic/:id', (req, res) => {
  const id = req.params.id;
  const topic = (db.rangkuman_topik || []).find(t => t.topik_id === id || t.topik_id === (id.toUpperCase()));
  if (!topic) return res.status(404).json({ error: 'Topic not found' });
  return res.json(topic);
});

// GET /search?q=... - search across judul_topik, sub_judul, pertanyaan, and pilihan
app.get('/search', (req, res) => {
  const q = (req.query.q || '').trim().toLowerCase();
  if (!q) return res.json({ query: q, results: [] });

  const results = [];
  (db.rangkuman_topik || []).forEach(topic => {
    const tMatch = (topic.judul_topik || '').toLowerCase().includes(q);
    if (tMatch) {
      results.push({
        topik_id: topic.topik_id,
        judul_topik: topic.judul_topik,
        match_in: 'judul_topik'
      });
      return; // if title matches, good enough
    }

    // search konten -> sub_judul and nested text
    let foundInKonten = false;
    if (Array.isArray(topic.konten)) {
      for (const k of topic.konten) {
        // sub_judul field
        if (k.sub_judul && String(k.sub_judul).toLowerCase().includes(q)) {
          results.push({ topik_id: topic.topik_id, judul_topik: topic.judul_topik, match_in: 'sub_judul', sub_judul: k.sub_judul });
          foundInKonten = true;
          break;
        }
        // stringify konten block and search
        const block = JSON.stringify(k).toLowerCase();
        if (block.includes(q)) {
          results.push({ topik_id: topic.topik_id, judul_topik: topic.judul_topik, match_in: 'konten' });
          foundInKonten = true;
          break;
        }
      }
    }
    if (foundInKonten) return;

    // search kuis questions
    if (Array.isArray(topic.kuis)) {
      for (const qq of topic.kuis) {
        if (qq.pertanyaan && qq.pertanyaan.toLowerCase().includes(q)) {
          results.push({ topik_id: topic.topik_id, judul_topik: topic.judul_topik, match_in: 'kuis', pertanyaan: qq.pertanyaan });
          break;
        }
        if (Array.isArray(qq.pilihan)) {
          for (const p of qq.pilihan) {
            if (p && String(p).toLowerCase().includes(q)) {
              results.push({ topik_id: topic.topik_id, judul_topik: topic.judul_topik, match_in: 'kuis_pilihan', pilihan: p });
              break;
            }
          }
        }
      }
    }
  });

  return res.json({ query: q, results });
});

// GET /reload - re-read JSON from disk (dev only)
app.get('/reload', (req, res) => {
  loadData();
  return res.json({ ok: true, message: 'reloaded', topics: (db.rangkuman_topik || []).length });
});

const PORT = process.env.PORT || 3333;
app.listen(PORT, () => {
  console.log(`pbm-materi-api listening on http://localhost:${PORT}`);
});
