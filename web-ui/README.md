# Prometheus Course Web UI

Browser-based learning interface. Left: guides, Right: terminal.

## Setup

```bash
cd web-ui
npm install
npm start
```

Open http://localhost:3000

## Features

- Course guides in sidebar
- Markdown viewer (center)
- Live bash terminal (right)
- Real-time WebSocket I/O

## Stack

- Backend: Node.js + Express + WebSocket + node-pty
- Frontend: HTML + xterm.js + marked.js
