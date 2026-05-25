sudo tee /etc/systemd/system/openqueri-backend.service << 'EOF'
[Unit]
Description=OpenQueri Backend Service
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu
ExecStart=/home/ubuntu/OpenQueri-backend
Restart=always

[Install]
WantedBy=multi-user.target
EOF

chmod +x /home/ubuntu/OpenQueri-backend
sudo systemctl daemon-reload
sudo systemctl start openqueri-backend
sudo systemctl enable openqueri-backend