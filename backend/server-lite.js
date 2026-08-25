/**
 * Parkiei Lite — sem MySQL, estado em memória + WebSocket push
 * Rode com: node server-lite.js
 */
const http = require('http');
const express = require('express');
const cors = require('cors');
const { WebSocketServer } = require('ws');

const app = express();
app.use(cors());
app.use(express.json());

// Estado único em memória (sincronizado via WS para todos os clientes)
const parking = {
  id: 1,
  name: 'Estacionamento Principal',
  location: 'Joinville, SC',
  vacancies: 1,
  occupiedSpots: 0,
};

// ── REST ──────────────────────────────────────────────────────
app.get('/parkings', (_req, res) => res.json([parking]));
app.get('/parkings/:id', (_req, res) => res.json(parking));

app.patch('/parkings/:id/occupancy', (req, res) => {
  const { occupiedSpots } = req.body;
  if (typeof occupiedSpots === 'number' && occupiedSpots >= 0) {
    parking.occupiedSpots = Math.min(occupiedSpots, parking.vacancies);
    const status = parking.occupiedSpots > 0 ? '🔴 OCUPADA' : '🟢 LIVRE';
    console.log(`[${new Date().toLocaleTimeString()}] Vaga ${status}`);
    broadcast(parking);
  }
  res.json(parking);
});

// ── WebSocket ─────────────────────────────────────────────────
const server = http.createServer(app);
const wss = new WebSocketServer({ server, path: '/ws' });

function broadcast(data) {
  const msg = JSON.stringify(data);
  wss.clients.forEach((client) => {
    if (client.readyState === 1) client.send(msg);
  });
}

wss.on('connection', (ws) => {
  ws.send(JSON.stringify(parking)); // estado atual ao conectar
  console.log(`[WS] cliente conectado (total: ${wss.clients.size})`);
  ws.on('close', () =>
    console.log(`[WS] cliente desconectado (total: ${wss.clients.size})`)
  );
});

// ── Start ─────────────────────────────────────────────────────
const PORT = 3000;
server.listen(PORT, '0.0.0.0', () => {
  console.log(`\nParkiei Lite rodando em http://172.20.10.2:${PORT}`);
  console.log(`WebSocket em       ws://172.20.10.2:${PORT}/ws\n`);
});
