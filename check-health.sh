#!/bin/bash

# Script để kiểm tra sức khỏe của tất cả các dịch vụ trong Docker Swarm

echo "===== KIỂM TRA SỨC KHỎE CÁC DỊCH VỤ ====="

# Kiểm tra các service đang chạy
echo "===== Kiểm tra các service đang chạy ====="
docker stack services dockercoins

# Kiểm tra logs của các service chính
echo -e "\n===== Kiểm tra logs của Elasticsearch ====="
docker service logs --tail 10 dockercoins_elasticsearch

echo -e "\n===== Kiểm tra logs của Logstash ====="
docker service logs --tail 10 dockercoins_logstash

echo -e "\n===== Kiểm tra logs của Kibana ====="
docker service logs --tail 10 dockercoins_kibana

echo -e "\n===== Kiểm tra logs của Prometheus ====="
docker service logs --tail 10 dockercoins_prometheus

echo -e "\n===== Kiểm tra logs của Grafana ====="
docker service logs --tail 10 dockercoins_grafana

echo -e "\n===== Kiểm tra logs của InfluxDB ====="
docker service logs --tail 10 dockercoins_influxdb

echo -e "\n===== Kiểm tra logs của Nginx ====="
docker service logs --tail 10 dockercoins_nginx

# Kiểm tra kết nối đến các dịch vụ
echo -e "\n===== Kiểm tra kết nối đến các dịch vụ ====="

# Lấy ID của container Nginx
NGINX_CONTAINER=$(docker ps | grep nginx | head -n1 | awk '{print $1}')

if [ -n "$NGINX_CONTAINER" ]; then
  echo "Kiểm tra kết nối từ Nginx đến các dịch vụ khác..."
  
  echo -e "\nKiểm tra kết nối đến Elasticsearch:"
  docker exec $NGINX_CONTAINER curl -s -o /dev/null -w "%{http_code}" http://elasticsearch:9200/
  
  echo -e "\nKiểm tra kết nối đến Kibana:"
  docker exec $NGINX_CONTAINER curl -s -o /dev/null -w "%{http_code}" http://kibana:5601/api/status
  
  echo -e "\nKiểm tra kết nối đến Prometheus:"
  docker exec $NGINX_CONTAINER curl -s -o /dev/null -w "%{http_code}" http://prometheus:9090/-/healthy
  
  echo -e "\nKiểm tra kết nối đến Grafana:"
  docker exec $NGINX_CONTAINER curl -s -o /dev/null -w "%{http_code}" http://grafana:3000/api/health
  
  echo -e "\nKiểm tra kết nối đến InfluxDB:"
  docker exec $NGINX_CONTAINER curl -s -o /dev/null -w "%{http_code}" http://influxdb:8086/health
  
  echo -e "\nKiểm tra kết nối đến WebUI:"
  docker exec $NGINX_CONTAINER curl -s -o /dev/null -w "%{http_code}" http://webui:80/
  
  echo -e "\nKiểm tra kết nối đến RNG:"
  docker exec $NGINX_CONTAINER curl -s -o /dev/null -w "%{http_code}" http://rng:80/
  
  echo -e "\nKiểm tra kết nối đến Hasher:"
  docker exec $NGINX_CONTAINER curl -s -o /dev/null -w "%{http_code}" http://hasher:80/
else
  echo "Không tìm thấy container Nginx đang chạy."
fi

echo -e "\n===== KIỂM TRA HOÀN TẤT ====="
