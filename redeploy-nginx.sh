#!/bin/bash

# Script để triển khai lại service Nginx

echo "===== Triển khai lại service Nginx ====="

# Dừng service Nginx hiện tại
echo "Dừng service Nginx hiện tại..."
docker service rm dockercoins_nginx

# Đợi service dừng hoàn toàn
echo "Đợi service dừng hoàn toàn..."
sleep 5

# Triển khai lại service Nginx
echo "Triển khai lại service Nginx..."
docker service create \
  --name dockercoins_nginx \
  --network hoangkhang-net \
  --publish mode=host,published=80,target=80 \
  --mount type=bind,source=$(pwd)/nginx.conf,destination=/etc/nginx/nginx.conf,readonly \
  --mount type=bind,source=$(pwd)/index.html,destination=/usr/share/nginx/html/index.html,readonly \
  --constraint node.role==manager \
  nginx:latest

echo "===== Hoàn tất! ====="
echo "Kiểm tra logs của service Nginx:"
echo "docker service logs dockercoins_nginx --follow"
