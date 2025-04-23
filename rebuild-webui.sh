#!/bin/bash

# Script để rebuild và redeploy webui service

# Đặt địa chỉ registry là IP của node manager
REGISTRY=192.168.19.10:5000

echo "===== Rebuild và redeploy webui service ====="

# Build image webui
echo "Building webui image..."
docker build -t $REGISTRY/dockercoins_webui:latest ./webui

# Push image lên registry
echo "Pushing webui image to registry..."
docker push $REGISTRY/dockercoins_webui:latest

# Update service
echo "Updating webui service..."
docker service update --force dockercoins_webui

echo "===== Hoàn tất! ====="
echo "Kiểm tra logs với lệnh: docker service logs dockercoins_webui"
