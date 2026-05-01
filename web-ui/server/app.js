const express = require('express');
const http = require('http');
const WebSocket = require('ws');
const pty = require('node-pty');
const path = require('path');
const fs = require('fs');

const app = express();
const server = http.createServer(app);
const wss = new WebSocket.Server({ server });

const PORT = process.env.PORT || 3000;
const COURSE_ROOT = path.join(__dirname, '..');

// Serve static files
app.use(express.static(path.join(__dirname, '../public')));

// API: Get list of guides
app.get('/api/guides', (req, res) => {
  const guides = [];
  const docsPath = path.join(COURSE_ROOT, '..', 'docs');

  // Getting started
  guides.push({
    id: 'getting-started',
    title: 'Getting Started',
    path: path.join(docsPath, 'getting-started/README.md'),
    section: 'Getting Started',
    order: 0
  });

  // Module 1
  for (let day = 1; day <= 4; day++) {
    const dayNames = ['architecture', 'metrics-model', 'scraping-basics', 'review'];
    guides.push({
      id: `day-${day}`,
      title: `Day ${day}`,
      path: path.join(docsPath, `module-1-fundamentals/day-${day}-${dayNames[day-1]}.md`),
      section: 'Module 1: Fundamentals',
      order: day
    });
  }

  // Module 2
  for (let day = 5; day <= 8; day++) {
    const dayNames = ['go-instrumentation', 'http-metrics', 'custom-metrics', 'best-practices'];
    guides.push({
      id: `day-${day}`,
      title: `Day ${day}`,
      path: path.join(docsPath, `module-2-instrumentation/day-${day}-${dayNames[day-5]}.md`),
      section: 'Module 2: Instrumentation',
      order: day
    });
  }

  // Module 3
  for (let day = 9; day <= 15; day++) {
    const dayNames = ['instant-range-vectors', 'aggregation', 'rate-increase', 'joins', 'functions', 'histograms', 'capstone'];
    guides.push({
      id: `day-${day}`,
      title: `Day ${day}`,
      path: path.join(docsPath, `module-3-promql/day-${day}-${dayNames[day-9]}.md`),
      section: 'Module 3: PromQL',
      order: day
    });
  }

  res.json(guides);
});

// API: Get guide content
app.get('/api/guides/:id', (req, res) => {
  const { id } = req.params;
  const docsPath = path.join(COURSE_ROOT, '..', 'docs');

  // Special case for getting-started
  if (id === 'getting-started') {
    const filePath = path.join(docsPath, 'getting-started/README.md');
    if (fs.existsSync(filePath)) {
      const content = fs.readFileSync(filePath, 'utf-8');
      return res.json({ content, path: filePath });
    }
  }

  // Find day-X files by walking the directory
  let filePath = null;
  const walk = (dir) => {
    try {
      const files = fs.readdirSync(dir);
      for (const file of files) {
        const fullPath = path.join(dir, file);
        const stat = fs.statSync(fullPath);
        if (stat.isDirectory()) {
          walk(fullPath);
        } else if (file.startsWith(`${id}-`) && file.endsWith('.md')) {
          filePath = fullPath;
          return;
        }
      }
    } catch (e) {
      // ignore read errors
    }
  };

  walk(docsPath);

  if (!filePath || !fs.existsSync(filePath)) {
    return res.status(404).json({ error: `Guide not found: ${id}` });
  }

  const content = fs.readFileSync(filePath, 'utf-8');
  res.json({ content, path: filePath });
});

// WebSocket: Terminal connection
wss.on('connection', (ws) => {
  const courseDir = path.join(COURSE_ROOT, '..');

  // Create pseudo-terminal shell
  const shell = pty.spawn('bash', [], {
    name: 'xterm-color',
    cols: 80,
    rows: 24,
    cwd: courseDir
  });

  // Send terminal output to client
  shell.on('data', (data) => {
    ws.send(JSON.stringify({ type: 'output', data: data.toString() }));
  });

  // Receive input from client
  ws.on('message', (message) => {
    try {
      const msg = JSON.parse(message);
      if (msg.type === 'input') {
        shell.write(msg.data);
      }
    } catch (e) {
      console.error('WebSocket message error:', e);
    }
  });

  // Handle disconnect
  ws.on('close', () => {
    shell.kill();
  });

  // Handle errors
  shell.on('error', (err) => {
    console.error('Shell error:', err);
  });
});

server.listen(PORT, () => {
  console.log(`Prometheus Course UI running on http://localhost:${PORT}`);
});
