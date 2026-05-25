#!/bin/bash
set -e

echo "=== SYSTEM UPDATE ==="
sudo apt install -y nginx nodejs npm

echo "=== BUILD FRONTEND (from dist source if needed) ==="
cd /home/ubuntu/dist

cd /home/ubuntu

echo "=== NGINX CONFIG ==="
sudo tee /etc/nginx/sites-available/openqueri > /dev/null <<'EOF'
server {
    listen 80;
    server_name _;

    root /home/ubuntu/dist;
    index index.html;

    location / {
        try_files $uri /index.html;
    }

    location /api/ {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOF

sudo ln -sf /etc/nginx/sites-available/openqueri /etc/nginx/sites-enabled/openqueri
sudo nginx -t
sudo systemctl restart nginx

echo "=== BUILD BACKEND ==="
cd /home/ubuntu/OpenQueri-backend
cargo build --release

echo "=== SYSTEMD SERVICE ==="
sudo tee /etc/systemd/system/openqueri.service > /dev/null <<EOF
[Unit]
Description=OpenQueri Backend
After=network.target

[Service]
Type=simple
WorkingDirectory=/home/ubuntu/OpenQueri-backend
ExecStart=/home/ubuntu/OpenQueri-backend/target/release/OpenQueri-backend
Restart=always
RestartSec=5
EnvironmentFile=/home/ubuntu/OpenQueri-backend/.env

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable openqueri
sudo systemctl restart openqueri

echo "=== DONE ==="
echo "Frontend: http://YOUR_VPS_IP/"
echo "Backend running on :3000 (internal)"