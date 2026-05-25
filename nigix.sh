#!/bin/bash
set -e

echo "=== SYSTEM UPDATE ==="
sudo apt update
sudo apt install -y nginx nodejs npm

echo "=== FIND FRONTEND DIST ==="
FRONTEND_DIST=$(find /home/ubuntu -type d -name "dist" | head -n 1)

if [ -z "$FRONTEND_DIST" ]; then
  echo "❌ dist not found"
  exit 1
fi

echo "Frontend dist found: $FRONTEND_DIST"

echo "=== FIND BACKEND ==="
BACKEND_DIR=$(find /home/ubuntu -type f -name "Cargo.toml" | grep OpenQueri-backend | head -n 1 | xargs dirname)

if [ -z "$BACKEND_DIR" ]; then
  echo "❌ backend not found"
  exit 1
fi

echo "Backend found: $BACKEND_DIR"

echo "=== BUILD BACKEND ==="
cd "$BACKEND_DIR"
cargo build --release

BACKEND_BIN="$BACKEND_DIR/target/release/OpenQueri-backend"

if [ ! -f "$BACKEND_BIN" ]; then
  echo "❌ backend binary not found"
  exit 1
fi

echo "=== CONFIGURE NGINX ==="
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

echo "=== SYSTEMD BACKEND SERVICE ==="
sudo tee /etc/systemd/system/openqueri.service > /dev/null <<EOF
[Unit]
Description=OpenQueri Backend
After=network.target

[Service]
Type=simple
WorkingDirectory=$BACKEND_DIR
ExecStart=$BACKEND_BIN
Restart=always
RestartSec=5
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