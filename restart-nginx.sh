#!/bin/bash

# Script để kiểm tra và khởi động lại Nginx nếu cần

echo "===== KIỂM TRA VÀ KHỞI ĐỘNG LẠI NGINX ====="

# Kiểm tra trạng thái của service Nginx
NGINX_STATUS=$(docker service ps dockercoins_nginx --format "{{.CurrentState}}" | head -n1)
echo "Trạng thái hiện tại của Nginx: $NGINX_STATUS"

# Kiểm tra xem có container Nginx nào đang chạy không
NGINX_CONTAINER=$(docker ps | grep nginx | head -n1 | awk '{print $1}')

if [ -z "$NGINX_CONTAINER" ]; then
  echo "Không tìm thấy container Nginx đang chạy. Đang khởi động lại service..."
  docker service update --force dockercoins_nginx
else
  echo "Container Nginx đang chạy: $NGINX_CONTAINER"

  # Kiểm tra kết nối đến Nginx
  echo "Kiểm tra kết nối đến Nginx từ máy host..."
  RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8090/)

  if [ "$RESPONSE" = "200" ]; then
    echo "Nginx đang hoạt động bình thường (HTTP 200 OK)"
  else
    echo "Nginx không phản hồi đúng (HTTP $RESPONSE). Đang khởi động lại service..."
    docker service update --force dockercoins_nginx
  fi

  # Kiểm tra logs của Nginx
  echo -e "\nLogs gần đây của Nginx:"
  docker service logs --tail 20 dockercoins_nginx
fi

echo -e "\n===== HOÀN TẤT ====="
