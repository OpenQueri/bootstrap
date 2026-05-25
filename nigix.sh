#!/bin/bash
set -e

BASE="/home/ubuntu"

echo "=== SYSTEM UPDATE ==="
sudo apt update
sudo apt install -y nginx nodejs npm

echo "=== FIX PERMISSIONS (IMPORTANT) ==="
sudo chown -R ubuntu:ubuntu $BASE

echo "=== FRONTEND PATH ==="
FRONTEND_DIST="$BASE/dist"

if [ ! -d "$FRONTEND_DIST" ]; then
  echo "❌ Frontend dist not found at $FRONTEND_DIST"
  exit 1
fi

echo "=== BACKEND PATH ==="
BACKEND_DIR="$BASE/bootstrap/Engine/OpenQueri-backend"

if [ ! -d "$BACKEND_DIR" ]; then
  echo "❌ Backend not found at $BACKEND_DIR"
  exit 1
fi

echo "=== BUILD BACKEND ==="
cd "$BACKEND_DIR"
cargo clean
cargo build --release

BACKEND_BIN="$BACKEND_DIR/target/release/OpenQueri-backend"

if [ ! -f "$BACKEND_BIN" ]; then
  echo "❌ Backend binary not found"
  exit 1
fi

echo "=== NGINX CONFIG ==="
sudo rm -f /etc/nginx/sites-enabled/default || true

sudo tee /etc/nginx/sites-available/openqueri > /dev/null <<EOF
server {
    listen 80;
    server_name _;

    root $FRONTEND_DIST;
    index index.html;

    location / {
        try_files \$uri /index.html;
    }

    location /api/ {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

sudo ln -sf /etc/nginx/sites-available/openqueri /etc/nginx/sites-enabled/openqueri
sudo nginx -t
sudo systemctl restart nginx

echo "=== SYSTEMD BACKEND ==="
sudo tee /etc/systemd/system/openqueri.service > /dev/null <<EOF
[Unit]
Description=OpenQueri Backend
After=network.target

[Service]
Type=simple
WorkingDirectory=$BACKEND_DIR
ExecStart=$BACKEND_BIN
Restart=always
RestartSec=3
EnvironmentFile=$BACKEND_DIR/.env

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable openqueri
sudo systemctl restart openqueri

echo "=== DONE ==="
echo "Frontend: http://YOUR_VPS_IP/"
echo "Backend: running on 127.0.0.1:3000"