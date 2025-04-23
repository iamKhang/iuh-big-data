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
  --dns 127.0.0.11 \
  nginx:latest

# Kiểm tra trạng thái service
echo "Kiểm tra trạng thái service Nginx..."
sleep 5
docker service ls | grep nginx

# Kiểm tra logs của Nginx
echo "Kiểm tra logs của Nginx..."
sleep 5
docker service logs dockercoins_nginx --tail 10

# Lấy địa chỉ IP của máy
IP_ADDR=$(hostname -I | awk '{print $1}')

echo "===== Hoàn tất! ====="
echo "Bạn có thể truy cập Nginx qua: http://$IP_ADDR/"
echo "Kiểm tra logs của service Nginx:"
echo "docker service logs dockercoins_nginx --follow"
