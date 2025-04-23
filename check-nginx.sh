#!/bin/bash

# Script để kiểm tra kết nối Nginx đến các dịch vụ

echo "===== KIỂM TRA KẾT NỐI NGINX ====="

# Lấy container ID của Nginx
NGINX_CONTAINER=$(docker ps | grep nginx | head -n1 | awk '{print $1}')

if [ -z "$NGINX_CONTAINER" ]; then
  echo "Không tìm thấy container Nginx đang chạy!"
  echo "Kiểm tra trạng thái service Nginx:"
  docker service ls | grep nginx
  exit 1
fi

echo "Container Nginx ID: $NGINX_CONTAINER"

# Kiểm tra cấu hình Nginx
echo -e "\n===== Kiểm tra cấu hình Nginx ====="
docker exec $NGINX_CONTAINER nginx -t

# Kiểm tra kết nối đến các dịch vụ
echo -e "\n===== Kiểm tra kết nối đến các dịch vụ ====="

check_service() {
  local service=$1
  local port=$2
  echo -e "\nKiểm tra kết nối đến $service:$port..."
  docker exec $NGINX_CONTAINER curl -s -o /dev/null -w "%{http_code}" $service:$port || echo "Lỗi kết nối"
}

# Kiểm tra các dịch vụ chính
check_service "dockercoins_webui" "80"
check_service "dockercoins_rng" "80"
check_service "dockercoins_hasher" "80"
check_service "dockercoins_prometheus" "9090"
check_service "dockercoins_grafana" "3000"
check_service "dockercoins_kibana" "5601"
check_service "dockercoins_elasticsearch" "9200"
check_service "dockercoins_influxdb" "8086"

# Kiểm tra các biến trong nginx.conf
echo -e "\n===== Kiểm tra các biến trong nginx.conf ====="
docker exec $NGINX_CONTAINER grep -A 2 "set \$upstream" /etc/nginx/nginx.conf

# Kiểm tra DNS resolution
echo -e "\n===== Kiểm tra DNS resolution ====="
docker exec $NGINX_CONTAINER cat /etc/resolv.conf

# Kiểm tra logs của Nginx
echo -e "\n===== Kiểm tra logs của Nginx ====="
docker exec $NGINX_CONTAINER tail -n 20 /var/log/nginx/error.log

echo -e "\n===== KIỂM TRA HOÀN TẤT ====="
echo "Nếu có lỗi kết nối, hãy kiểm tra:"
echo "1. Các dịch vụ đã chạy chưa: docker service ls"
echo "2. Mạng Docker Swarm: docker network inspect hoangkhang-net"
echo "3. Cấu hình Nginx: docker exec $NGINX_CONTAINER cat /etc/nginx/nginx.conf"
