/*
 * ============================================================
 *  Sistema de Gestão de Vagas — ESP32-Cam + TensorFlow.js
 *  Versão Simplificada (Apenas a placa, sem componentes extras)
 * ============================================================
 */

// ── Credenciais WiFi ─────────────────────────────────────────
const char *ssid = "iPhone";        // ← ALTERE AQUI
const char *password = "123456789"; // ← ALTERE AQUI

// ── Bibliotecas ───────────────────────────────────────────────
#include "esp_camera.h"
#include "soc/rtc_cntl_reg.h"
#include "soc/soc.h"
#include <WiFi.h>

// ── Pinout Padrão AI-Thinker ESP32-Cam ───────────────────────
#define PWDN_GPIO_NUM 32
#define RESET_GPIO_NUM -1
#define XCLK_GPIO_NUM 0
#define SIOD_GPIO_NUM 26
#define SIOC_GPIO_NUM 27
#define Y9_GPIO_NUM 35
#define Y8_GPIO_NUM 34
#define Y7_GPIO_NUM 39
#define Y6_GPIO_NUM 36
#define Y5_GPIO_NUM 21
#define Y4_GPIO_NUM 19
#define Y3_GPIO_NUM 18
#define Y2_GPIO_NUM 5
#define VSYNC_GPIO_NUM 25
#define HREF_GPIO_NUM 23
#define PCLK_GPIO_NUM 22
#define FLASH_GPIO_NUM 4 // Usado apenas para manter o flash desligado

// ── Estado do servidor ───────────────────────────────────────
String Feedback = "";
String Command = "", cmd = "", P1 = "", P2 = "", P3 = "", P4 = "";
byte ReceiveState = 0, cmdState = 1, strState = 1;
byte questionstate = 0, equalstate = 0, semicolonstate = 0;

int totalSpots = 1;
int occupiedCount = 0;

WiFiServer server(80);

// ── Protótipos ────────────────────────────────────────────────
void ExecuteCommand();
void getCommand(char c);

// ============================================================
//  PÁGINA HTML COMPLETA (Fica salva na memória da placa)
// ============================================================
static const char PROGMEM INDEX_HTML[] = R"rawliteral(
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>Parking Monitor — ESP32-Cam</title>
 
  <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.8.0/jquery.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/@tensorflow/tfjs@1.3.1/dist/tf.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/@tensorflow-models/coco-ssd@2.1.0"></script>
 
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    :root {
      --bg: #0a0e1a; --surface: #111827; --card: #1a2235; --border: #1f2d45;
      --accent: #3b82f6; --accent2: #06b6d4; --green: #22c55e; --red: #ef4444;
      --yellow: #f59e0b; --text: #e2e8f0; --muted: #64748b; --radius: 12px;
    }
    body { background: var(--bg); color: var(--text); font-family: system-ui, sans-serif; min-height: 100vh; display: flex; flex-direction: column; }
    header { background: var(--surface); border-bottom: 1px solid var(--border); padding: 14px 24px; display: flex; align-items: center; justify-content: space-between; }
    .logo { display: flex; align-items: center; gap: 10px; font-weight: 700; font-size: 1.15rem; }
    .status-badge { display: flex; align-items: center; gap: 8px; padding: 6px 14px; border-radius: 99px; font-size: .8rem; font-weight: 600; background: var(--card); border: 1px solid var(--border); }
    .dot { width: 8px; height: 8px; border-radius: 50%; background: var(--muted); transition: .4s; }
    .dot.live { background: var(--green); animation: pulse 1.5s infinite; }
    .dot.alert { background: var(--red); animation: pulse .8s infinite; }
    @keyframes pulse { 0%,100% { opacity:1; } 50% { opacity:.4; } }
    main { display: grid; grid-template-columns: 1fr 340px; flex: 1; }
    @media (max-width: 900px) { main { grid-template-columns: 1fr; } }
    .camera-panel, .side-panel { padding: 20px; display: flex; flex-direction: column; gap: 14px; }
    .side-panel { background: var(--surface); border-left: 1px solid var(--border); overflow-y: auto; }
    .canvas-wrap { position: relative; background: #000; border-radius: var(--radius); border: 1px solid var(--border); min-height: 260px; display: flex; align-items: center; justify-content: center; overflow: hidden;}
    #canvas { display: block; max-width: 100%; border-radius: var(--radius); }
    .canvas-overlay { position: absolute; inset: 0; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 10px; color: var(--muted); font-size: .9rem; }
    #canvas[data-active] + .canvas-overlay { display: none; }
    #detection-log { background: var(--card); border: 1px solid var(--border); border-radius: var(--radius); padding: 12px; font-size: .78rem; font-family: monospace; color: var(--accent2); max-height: 120px; overflow-y: auto; }
    .stats-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }
    .stat-card { background: var(--card); border: 1px solid var(--border); border-radius: var(--radius); padding: 14px; }
    .stat-label { font-size: .7rem; color: var(--muted); text-transform: uppercase; }
    .stat-value { font-size: 1.8rem; font-weight: 700; }
    .stat-value.green { color: var(--green); } .stat-value.red { color: var(--red); } .stat-value.blue { color: var(--accent); } .stat-value.yellow { color: var(--yellow); }
    .occupancy-bar-wrap { background: var(--card); border: 1px solid var(--border); border-radius: var(--radius); padding: 14px; }
    .bar-track { background: var(--bg); border-radius: 99px; height: 10px; margin: 8px 0; }
    .bar-fill { height: 100%; border-radius: 99px; background: linear-gradient(90deg, var(--green), var(--accent)); width: 0%; transition: width .6s; }
    .bar-fill.high { background: linear-gradient(90deg, var(--yellow), var(--red)); }
    .spots-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(64px, 1fr)); gap: 8px; margin-top: 10px; }
    .spot { aspect-ratio: 1; border-radius: 8px; border: 2px solid; display: flex; flex-direction: column; align-items: center; justify-content: center; font-size: .65rem; font-weight: 600; }
    .spot.free { border-color: var(--green); background: rgba(34,197,94,.1); color: var(--green); }
    .spot.occupied { border-color: var(--red); background: rgba(239,68,68,.1); color: var(--red); }
    .spot-icon { font-size: 1.3rem; }
    .controls-section { background: var(--card); border: 1px solid var(--border); border-radius: var(--radius); padding: 14px; }
    .control-row { display: flex; justify-content: space-between; padding: 7px 0; border-bottom: 1px solid var(--border); align-items: center;}
    .control-row:last-child { border-bottom: none; }
    .control-row select, .control-row input { flex: 1; background: var(--bg); color: var(--text); border: 1px solid var(--border); border-radius: 6px; padding: 4px; font-size: .8rem; margin-left: 10px;}
    .control-row input[type=range] { accent-color: var(--accent); }
    .btn { padding: 8px 16px; border-radius: 8px; font-weight: 600; border: none; cursor: pointer; color: #fff; background: var(--accent); }
    .btn:disabled { opacity: .5; }
    .btn-ghost { background: var(--card); color: var(--text); border: 1px solid var(--border); }
    #ShowImage { display: none; }
  </style>
</head>
<body>
 
<header>
  <div class="logo">🅿 Parking Monitor <span style="color:var(--muted);font-weight:400;font-size:.85rem">/ ESP32</span></div>
  <div style="display:flex;gap:10px;align-items:center">
    <div class="status-badge"><div class="dot" id="liveDot"></div><span id="liveLabel">Aguardando...</span></div>
    <button class="btn btn-ghost" onclick="doRestart()">↺ Restart ESP32</button>
  </div>
</header>
 
<img id="ShowImage" src="">
 
<main>
  <div class="camera-panel">
    <div style="display:flex;justify-content:space-between;align-items:center;">
      <span style="font-size:.9rem;color:var(--muted);font-weight:bold;">📷 Feed da Câmera (IA)</span>
      <div style="display:flex;gap:8px;">
        <button class="btn" id="getStill" onclick="startDetect()" disabled>▶ Iniciar Detecção</button>
        <button class="btn btn-ghost" onclick="stopDetect()">⏹ Parar</button>
      </div>
    </div>
    <div class="canvas-wrap">
      <canvas id="canvas" width="0" height="0"></canvas>
      <div class="canvas-overlay" id="canvasOverlay">
        <span id="overlayMsg">Carregando modelo de IA... aguarde.</span>
      </div>
    </div>
    <div id="detection-log">[ aguardando detecções... ]</div>
  </div>
 
  <div class="side-panel">
    <div>
      <div style="font-size:.8rem;color:var(--muted);font-weight:bold;margin-bottom:8px;">RESUMO</div>
      <div class="stats-grid">
        <div class="stat-card"><span class="stat-label">Livres</span><span class="stat-value green" id="statFree">-</span></div>
        <div class="stat-card"><span class="stat-label">Ocupadas</span><span class="stat-value red" id="statOcc">-</span></div>
        <div class="stat-card"><span class="stat-label">Total Vagas</span><span class="stat-value blue" id="statTotal">-</span></div>
        <div class="stat-card"><span class="stat-label">Confiança IA</span><span class="stat-value yellow" id="statConf">-</span></div>
      </div>
    </div>
 
    <div>
      <div style="font-size:.8rem;color:var(--muted);font-weight:bold;margin-bottom:8px;">VAGAS (Visualização)</div>
      <div style="background:var(--card);border:1px solid var(--border);border-radius:12px;padding:14px;">
        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:10px;">
          <span style="font-size:.8rem;">Configurar total:</span>
          <input type="number" id="totalSpotsInput" min="1" max="8" value="1" onchange="updateTotalSpots(this.value)" style="width:60px;background:var(--bg);color:white;border:1px solid var(--border);border-radius:6px;text-align:center;">
        </div>
        <div class="spots-grid" id="spotsGrid"></div>
      </div>
    </div>
 
    <div class="controls-section">
      <div style="font-size:.8rem;color:var(--muted);font-weight:bold;margin-bottom:8px;">CONFIGURAÇÕES DA CÂMERA</div>
      <div class="control-row">
        <span>Resolução</span>
        <select onchange="sendCmd('framesize='+this.value+';stop')">
          <option value="SVGA">SVGA 800×600</option>
          <option value="VGA">VGA 640×480</option>
          <option value="QVGA" selected>QVGA 320×240 (Rápido)</option>
        </select>
      </div>
      <div class="control-row">
        <span>Brilho</span>
        <input type="range" min="-2" max="2" value="0" onchange="sendCmd('brightness='+this.value+';stop')">
      </div>
      <div class="control-row">
        <span>Espelhar</span>
        <select id="mirrorimage"><option value="0">Não</option><option value="1">Sim</option></select>
      </div>
      <div class="control-row">
        <span>Filtro de Confiança</span>
        <select id="scoreLimit">
          <option value="0.7">Alto (70%)</option>
          <option value="0.5" selected>Médio (50%)</option>
          <option value="0.3">Baixo (30%)</option>
        </select>
      </div>
    </div>
  </div>
</main>
 
<script>
// ── Configuração da API Parkiei ───────────────────────────────
const PARKIEI_API   = 'http://172.20.10.2:3000'; // IP do backend na rede do hotspot
const PARKING_ID    = 1;                                // ← ID do seu estacionamento de teste

const ShowImage = document.getElementById('ShowImage');
const canvas = document.getElementById('canvas');
const ctx = canvas.getContext('2d');
const logEl = document.getElementById('detection-log');
const liveDot = document.getElementById('liveDot');
const liveLabel = document.getElementById('liveLabel');

let Model = null, running = false, myTimer = null, totalSpots = 1;
let spotsOccupied = new Array(8).fill(false), lastConf = 0;
let lastOccupiedCount = -1;
// Pipeline: enquanto a IA processa frame N, já buscamos frame N+1 da câmera.
let inferring = false, nextFrameReady = false;

window.onload = () => {
  updateTotalSpots(1);
  cocoSsd.load().then(model => {
    Model = model;
    document.getElementById('getStill').disabled = false;
    document.getElementById('overlayMsg').textContent = 'Modelo Pronto! Clique em Iniciar.';
  });
};

function startDetect() {
  if (!Model) return;
  running = true;
  inferring = false;
  nextFrameReady = false;
  fetchFrame();
}

function stopDetect() {
  running = false;
  inferring = false;
  nextFrameReady = false;
  clearTimeout(myTimer);
  liveDot.className = 'dot';
  liveLabel.textContent = 'Parado';
}

function fetchFrame() {
  if (!running) return;
  clearTimeout(myTimer);
  // Timeout de segurança: reinicia ciclo caso a placa trave (1,5s)
  myTimer = setTimeout(fetchFrame, 1500);
  ShowImage.src = location.origin + '/?getstill=' + Math.random();
}

// Chamado quando um frame está no canvas e pronto para inferência
function drawAndDetect() {
  nextFrameReady = false;
  canvas.width = ShowImage.width; canvas.height = ShowImage.height;
  if (document.getElementById('mirrorimage').value === '1') {
    ctx.translate(canvas.width, 0); ctx.scale(-1, 1);
  }
  ctx.drawImage(ShowImage, 0, 0); // copia para canvas ANTES de trocar src
  ctx.setTransform(1, 0, 0, 1, 0, 0);
  canvas.setAttribute('data-active', '1');
  if (Model && running) {
    fetchFrame();   // pipeline: já busca o próximo frame enquanto infere o atual
    inferring = true;
    detectImage();
  }
}

ShowImage.onload = () => {
  clearTimeout(myTimer);
  if (inferring) {
    // Frame chegou cedo demais; guarda o sinal e processa após a inferência atual
    nextFrameReady = true;
    return;
  }
  drawAndDetect();
};

function detectImage() {
  const scoreMin = parseFloat(document.getElementById('scoreLimit').value);

  Model.detect(canvas).then(predictions => {
    inferring = false;
    let vehicleCount = 0, maxConf = 0;
    logEl.innerHTML = '';

    predictions.forEach(p => {
      const isVehicle = ['car','truck','bus','motorcycle'].includes(p.class);
      ctx.lineWidth = 2; ctx.strokeStyle = isVehicle ? '#00FFFF' : '#444';
      ctx.strokeRect(...p.bbox);
      ctx.fillStyle = isVehicle ? '#00FFFF' : '#666';
      ctx.font = '14px monospace';
      ctx.fillText(`${p.class} ${Math.round(p.score*100)}%`, p.bbox[0], p.bbox[1] > 15 ? p.bbox[1]-5 : p.bbox[1]+15);

      logEl.innerHTML += `<span style="color:${isVehicle?'#22c55e':'#64748b'}">${p.class}</span> ${Math.round(p.score*100)}%<br>`;

      if (isVehicle && p.score >= scoreMin) {
        vehicleCount++;
        if (p.score > maxConf) maxConf = p.score;
      }
    });

    if (!predictions.length) logEl.innerHTML = '[ nenhum objeto ]';

    lastConf = maxConf;
    updateParkingState(vehicleCount, maxConf);

    const cmd = vehicleCount > 0 ? `vehicle;${vehicleCount};${Math.round(maxConf*100)}` : `empty;0;0`;
    fetch(`/?detectCount=${cmd};stop`).catch(()=>{});

    if (vehicleCount !== lastOccupiedCount) {
      lastOccupiedCount = vehicleCount;
      notifyBackend(vehicleCount);
    }

    if (running) {
      if (nextFrameReady) {
        drawAndDetect(); // próximo frame já chegou durante a inferência — processa já
      }
      // se não: o fetchFrame() acima já está em andamento, onload vai disparar
    }
  });
}
 
function notifyBackend(occupiedSpots) {
  fetch(`${PARKIEI_API}/parkings/${PARKING_ID}/occupancy`, {
    method: 'PATCH',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ occupiedSpots })
  }).catch(() => {});
}

function updateParkingState(vehicleCount, conf) {
  for (let i=0; i<totalSpots; i++) spotsOccupied[i] = (i < vehicleCount);
  
  const occ = spotsOccupied.slice(0, totalSpots).filter(Boolean).length;
  const free = totalSpots - occ;
  
  document.getElementById('statFree').textContent = free;
  document.getElementById('statOcc').textContent = occ;
  document.getElementById('statTotal').textContent = totalSpots;
  document.getElementById('statConf').textContent = conf > 0 ? Math.round(conf*100)+'%' : '-';
 
  if (occ === totalSpots) { liveDot.className='dot alert'; liveLabel.textContent='🔴 Lotado'; }
  else if (occ > 0) { liveDot.className='dot live'; liveLabel.textContent=`🟡 ${occ} vaga(s) ocupada(s)`; }
  else { liveDot.className='dot live'; liveLabel.textContent='🟢 Tudo Livre'; }
 
  const grid = document.getElementById('spotsGrid');
  grid.innerHTML = '';
  for (let i=0; i<totalSpots; i++) {
    const isOcc = spotsOccupied[i];
    grid.innerHTML += `<div class="spot ${isOcc?'occupied':'free'}"><span class="spot-icon">${isOcc?'🚗':'⬜'}</span><span>V${i+1}</span></div>`;
  }
}
 
function updateTotalSpots(n) {
  totalSpots = Math.max(1, Math.min(8, parseInt(n)||1));
  updateParkingState(spotsOccupied.filter(Boolean).length, lastConf);
}
 
function sendCmd(cmd) { fetch('/?' + cmd); }
function doRestart() { if(confirm('Reiniciar ESP32?')) fetch('/?restart=stop'); }
</script>
</body>
</html>
)rawliteral";

// ============================================================
//  Execução de Comandos do Servidor
// ============================================================
void ExecuteCommand() {
  if (cmd == "restart") {
    ESP.restart();
  } else if (cmd == "framesize") {
    sensor_t *s = esp_camera_sensor_get();
    if (P1 == "SVGA")
      s->set_framesize(s, FRAMESIZE_SVGA);
    else if (P1 == "VGA")
      s->set_framesize(s, FRAMESIZE_VGA);
    else
      s->set_framesize(s, FRAMESIZE_QVGA);
  } else if (cmd == "brightness") {
    sensor_t *s = esp_camera_sensor_get();
    s->set_brightness(s, P1.toInt());
  } else if (cmd == "detectCount") {
    String cls = P1;
    int count = P2.toInt();

    if (cls == "vehicle") {
      occupiedCount = count;
      Serial.printf("[VAGA OCUPADA] %d veiculo(s) detectado(s)\n", count);
    } else {
      occupiedCount = 0;
    }
  }

  Feedback = Command;
}

// ============================================================
//  Tratamento da URL HTTP
// ============================================================
void getCommand(char c) {
  if (c == '?')
    ReceiveState = 1;
  if ((c == ' ') || (c == '\r') || (c == '\n'))
    ReceiveState = 0;

  if (ReceiveState == 1) {
    Command = Command + String(c);
    if (c == '=')
      cmdState = 0;
    if (c == ';')
      strState++;

    if ((cmdState == 1) && ((c != '?') || (questionstate == 1)))
      cmd = cmd + String(c);
    if ((cmdState == 0) && (strState == 1) && ((c != '=') || (equalstate == 1)))
      P1 = P1 + String(c);
    if ((cmdState == 0) && (strState == 2) && (c != ';'))
      P2 = P2 + String(c);
    if ((cmdState == 0) && (strState == 3) && (c != ';'))
      P3 = P3 + String(c);

    if (c == '?')
      questionstate = 1;
    if (c == '=')
      equalstate = 1;
  }
}

// ============================================================
//  Configuração Inicial (Setup)
// ============================================================
void setup() {
  WRITE_PERI_REG(RTC_CNTL_BROWN_OUT_REG,
                 0); // Desativa brown-out (evita resets)

  Serial.begin(115200);
  Serial.println("\n--- Iniciando ESP32-Cam Parking ---");

  // Garante que o Flash do ESP32-Cam fique totalmente apagado
  pinMode(FLASH_GPIO_NUM, OUTPUT);
  digitalWrite(FLASH_GPIO_NUM, LOW);

  // Configuração da Câmera
  camera_config_t config;
  config.ledc_channel = LEDC_CHANNEL_0;
  config.ledc_timer = LEDC_TIMER_0;
  config.pin_d0 = Y2_GPIO_NUM;
  config.pin_d1 = Y3_GPIO_NUM;
  config.pin_d2 = Y4_GPIO_NUM;
  config.pin_d3 = Y5_GPIO_NUM;
  config.pin_d4 = Y6_GPIO_NUM;
  config.pin_d5 = Y7_GPIO_NUM;
  config.pin_d6 = Y8_GPIO_NUM;
  config.pin_d7 = Y9_GPIO_NUM;
  config.pin_xclk = XCLK_GPIO_NUM;
  config.pin_pclk = PCLK_GPIO_NUM;
  config.pin_vsync = VSYNC_GPIO_NUM;
  config.pin_href = HREF_GPIO_NUM;
  config.pin_sscb_sda = SIOD_GPIO_NUM;
  config.pin_sscb_scl = SIOC_GPIO_NUM;
  config.pin_pwdn = PWDN_GPIO_NUM;
  config.pin_reset = -1;
  config.xclk_freq_hz = 20000000;
  config.pixel_format = PIXFORMAT_JPEG;

  // QVGA (320x240): suficiente para COCO-SSD, reduz drasticamente o tamanho do
  // frame. quality=20: arquivo ~40% menor que quality=12, sem perda relevante
  // para IA. fb_count=2 com PSRAM: captura contínua dupla-bufferizada, menos
  // stall de sensor.
  config.frame_size = FRAMESIZE_QVGA;
  config.jpeg_quality = 20;
  config.fb_count = psramFound() ? 2 : 1;

  if (esp_camera_init(&config) != ESP_OK) {
    Serial.println("Erro ao iniciar a câmera! Reiniciando...");
    delay(1000);
    ESP.restart();
  }

  // Conectar ao WiFi
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);
  Serial.print("Conectando ao WiFi: ");

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println();
  Serial.print("✅ Conectado! Acesse no navegador: http://");
  Serial.println(WiFi.localIP());

  server.begin();
}

// ============================================================
//  Loop de Servidor Web
// ============================================================
void loop() {
  Feedback = "";
  Command = "";
  cmd = "";
  P1 = "";
  P2 = "";
  P3 = "";
  P4 = "";
  ReceiveState = 0;
  cmdState = 1;
  strState = 1;
  questionstate = 0;
  equalstate = 0;
  semicolonstate = 0;

  WiFiClient client = server.available();
  if (!client)
    return;

  String currentLine = "";
  while (client.connected()) {
    if (!client.available())
      continue;

    char c = client.read();
    getCommand(c);

    if (c == '\n') {
      if (currentLine.length() == 0) {

        // 1. O navegador pediu a imagem da câmera
        if (cmd == "getstill") {
          camera_fb_t *fb = esp_camera_fb_get();
          if (!fb) {
            ESP.restart(); // Trava de segurança
          }

          client.println("HTTP/1.1 200 OK");
          client.println("Access-Control-Allow-Origin: *");
          client.println("Content-Type: image/jpeg");
          client.println("Content-Length: " + String(fb->len));
          client.println("Connection: close");
          client.println();

          // 1460 = payload máximo de um pacote TCP (MTU Ethernet - headers)
          size_t sent = 0, imgLen = fb->len;
          while (sent < imgLen) {
            size_t chunk = min(imgLen - sent, (size_t)1460);
            client.write(fb->buf + sent, chunk);
            sent += chunk;
          }
          esp_camera_fb_return(fb);
        }
        // 2. Flutter/app pediu o status de ocupação em JSON
        else if (cmd == "getstatus") {
          int free = totalSpots - occupiedCount;
          if (free < 0)
            free = 0;
          String json = "{\"total\":" + String(totalSpots) +
                        ",\"occupied\":" + String(occupiedCount) +
                        ",\"free\":" + String(free) + "}";
          client.println("HTTP/1.1 200 OK");
          client.println("Access-Control-Allow-Origin: *");
          client.println("Content-Type: application/json");
          client.println("Content-Length: " + String(json.length()));
          client.println("Connection: close");
          client.println();
          client.print(json);
        }
        // 3. O navegador pediu a página HTML ou enviou um comando
        else {
          ExecuteCommand();
          client.println("HTTP/1.1 200 OK");
          client.println("Content-Type: text/html; charset=utf-8");
          client.println("Connection: close");
          client.println();

          if (cmd != "") {
            client.print(Feedback);
          } else {
            // Lê diretamente da flash (PROGMEM) sem alocar cópia no heap
            const uint8_t *p = (const uint8_t *)INDEX_HTML;
            size_t rem = strlen(INDEX_HTML);
            while (rem > 0) {
              size_t chunk = min(rem, (size_t)512);
              client.write(p, chunk);
              p += chunk;
              rem -= chunk;
            }
          }
          client.println();
        }
        break;
      } else {
        currentLine = "";
      }
    } else if (c != '\r') {
      currentLine += c;
    }

    if ((currentLine.indexOf("/?") != -1) &&
        (currentLine.indexOf(" HTTP") != -1)) {
      if (Command.indexOf("stop") != -1) {
        client.println();
        client.println();
        client.stop();
      }
      currentLine = "";
      ExecuteCommand();
    }
  }
  delay(1);
  client.stop();
}
