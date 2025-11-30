pbm-materi-api
===============

Small development API that serves the `pbm_materi.json` used by the Flutter app.

Quick start
-----------
Requires Node.js (14+ recommended).

1. open a terminal in the `api/` folder
2. install dependencies:

```powershell
npm install
```

3. start the server:

```powershell
npm run dev   # requires nodemon
# or
npm start
```

Endpoints
---------
- GET /materi — returns the full JSON
- GET /topics — returns a short list of topics: `{ topik_id, judul_topik }`
- GET /topic/:id — returns a single topic object matching `topik_id`
- GET /search?q=term — searches across titles, sub_judul, konten, and kuis
- GET /reload — forces the server to re-read `assets/data/pbm_materi.json` (dev only)

Notes
-----
The server reads the JSON from `../assets/data/pbm_materi.json` relative to the `api/` folder. If you want a copy inside `api/data/` instead, copy the file and update `DATA_PATH` in `index.js` accordingly.
