#!/bin/bash

set -e

sudo apt update
sudo apt install -y nginx

sudo mkdir -p /var/www/openqueri

sudo cp -r /home/ubuntu/dist/* /var/www/openqueri/
sudo chown -R www-data:www-data /var/www/openqueri
sudo chmod -R 755 /var/www/openqueri

sudo tee /etc/nginx/sites-available/openqueri << 'EOF'
server {
    listen 80;
    server_name _;

    root /var/www/openqueri;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }
    
    location /api/ {
        proxy_pass http://127.0.0.1:8000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

sudo ln -sf /etc/nginx/sites-available/openqueri /etc/nginx/sites-enabled/

if [ -f /etc/nginx/sites-enabled/default ]; then
    sudo rm /etc/nginx/sites-enabled/default
fi

sudo nginx -t
sudo systemctl restart nginx
sudo systemctl enable nginx