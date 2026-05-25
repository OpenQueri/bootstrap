#!/bin/bash

sudo apt update
sudo apt install -y make

make all

make -j$(nproc) install

make -j$(nproc) download-ai

make -j$(nproc) download-backend

make -j$(nproc) download-frontend

docker-compose up -d

make -j$(nproc) compil-frontend

make -j$(nproc) compil-backend