#!/bin/bash

sudo apt update
sudo apt install -y make

make all

make -j$(nproc) install

make -j$(nproc) download-ai

make -j$(nproc) download-backend

make -j$(nproc) download-frontend

sudo usermod -aG docker $USER



sudo docker compose up -d

make -j$(nproc) compil-frontend

make -j$(nproc) compil-backend


сd ..

pwd

echo "DATABASE_URL=postgres://user:password@127.0.0.1:5432/open_queri" > .env

make -j$(nproc) nigix

make -j$(nproc) backend-background
