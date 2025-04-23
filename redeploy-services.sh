#!/bin/bash

# Script để triển khai lại các dịch vụ sau khi thay đổi cấu hình

echo "===== TRIỂN KHAI LẠI CÁC DỊCH VỤ ====="

# Triển khai lại stack
echo "Triển khai lại stack..."
docker stack deploy -c docker-stack.yml dockercoins

# Đợi 30 giây để các dịch vụ khởi động
echo "Đợi 30 giây để các dịch vụ khởi động..."
sleep 30

# Kiểm tra trạng thái các service
echo "===== Kiểm tra trạng thái các service ====="
docker stack services dockercoins

# Triển khai lại Nginx
echo "===== Triển khai lại Nginx ====="
./redeploy-nginx.sh

# Đợi 30 giây để Nginx khởi động
echo "Đợi 30 giây để Nginx khởi động..."
sleep 30

# Kiểm tra kết nối đến Nginx
echo "Kiểm tra kết nối đến Nginx..."
curl -s -o /dev/null -w "%{http_code}" http://192.168.19.10:8090/ || echo "Không thể kết nối đến Nginx"

# Sử dụng địa chỉ IP cố định của node manager
IP_ADDR="192.168.19.10"

echo "===== TRIỂN KHAI HOÀN TẤT ====="
echo "Bạn có thể truy cập các dịch vụ qua các URL sau:"
echo "- Dashboard: http://$IP_ADDR:8090/"
echo "- DockerCoins WebUI: http://$IP_ADDR:8090/webui/"
echo "- Prometheus: http://$IP_ADDR:8090/prometheus/"
echo "- Grafana: http://$IP_ADDR:8090/grafana/ (admin/admin)"
echo "- Kibana: http://$IP_ADDR:8090/kibana/"
echo "- Elasticsearch: http://$IP_ADDR:8090/elasticsearch/"
echo "- InfluxDB: http://$IP_ADDR:8090/influxdb/ (admin/adminpassword)"
