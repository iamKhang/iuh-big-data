#!/bin/bash

# Script để đảm bảo tất cả các dịch vụ đang chạy
# Script này sẽ kiểm tra trạng thái của tất cả các dịch vụ và khởi động lại các dịch vụ không hoạt động

echo "===== KIỂM TRA VÀ ĐẢM BẢO CÁC DỊCH VỤ ĐANG CHẠY ====="

# Kiểm tra trạng thái của tất cả các dịch vụ
echo "Kiểm tra trạng thái của tất cả các dịch vụ..."
SERVICES_STATUS=$(docker stack services dockercoins --format "{{.Name}} {{.Replicas}}")
echo "$SERVICES_STATUS"

# Kiểm tra và khởi động lại các dịch vụ không hoạt động
echo -e "\nKiểm tra và khởi động lại các dịch vụ không hoạt động..."

# Elasticsearch
if echo "$SERVICES_STATUS" | grep -q "dockercoins_elasticsearch 0/"; then
  echo "Elasticsearch không hoạt động. Đang khởi động lại..."
  docker service update --force dockercoins_elasticsearch
  echo "Đợi 60 giây để Elasticsearch khởi động..."
  sleep 60
fi

# Kibana
if echo "$SERVICES_STATUS" | grep -q "dockercoins_kibana 0/"; then
  echo "Kibana không hoạt động. Đang khởi động lại..."
  docker service update --force dockercoins_kibana
  echo "Đợi 30 giây để Kibana khởi động..."
  sleep 30
fi

# InfluxDB
if echo "$SERVICES_STATUS" | grep -q "dockercoins_influxdb 0/"; then
  echo "InfluxDB không hoạt động. Đang khởi động lại..."
  docker service update --force dockercoins_influxdb
  echo "Đợi 60 giây để InfluxDB khởi động..."
  sleep 60
fi

# Grafana
if echo "$SERVICES_STATUS" | grep -q "dockercoins_grafana 0/"; then
  echo "Grafana không hoạt động. Đang khởi động lại..."
  docker service update --force dockercoins_grafana
  echo "Đợi 30 giây để Grafana khởi động..."
  sleep 30
fi

# Prometheus
if echo "$SERVICES_STATUS" | grep -q "dockercoins_prometheus 0/"; then
  echo "Prometheus không hoạt động. Đang khởi động lại..."
  docker service update --force dockercoins_prometheus
  echo "Đợi 30 giây để Prometheus khởi động..."
  sleep 30
fi

# Logstash
if echo "$SERVICES_STATUS" | grep -q "dockercoins_logstash 0/"; then
  echo "Logstash không hoạt động. Đang khởi động lại..."
  docker service update --force dockercoins_logstash
  echo "Đợi 30 giây để Logstash khởi động..."
  sleep 30
fi

# Nginx
if echo "$SERVICES_STATUS" | grep -q "dockercoins_nginx 0/"; then
  echo "Nginx không hoạt động. Đang khởi động lại..."
  ./redeploy-nginx.sh
  echo "Đợi 30 giây để Nginx khởi động..."
  sleep 30
fi

# Kiểm tra lại trạng thái của tất cả các dịch vụ
echo -e "\nKiểm tra lại trạng thái của tất cả các dịch vụ..."
docker stack services dockercoins

# Kiểm tra kết nối đến Nginx
echo -e "\nKiểm tra kết nối đến Nginx..."
curl -s -o /dev/null -w "%{http_code}" http://localhost:8090/ || echo "Không thể kết nối đến Nginx"

# Lấy địa chỉ IP của máy
IP_ADDR=$(hostname -I | awk '{print $1}')

echo -e "\n===== HOÀN TẤT ====="
echo "Bạn có thể truy cập các dịch vụ qua các URL sau:"
echo "- Dashboard: http://$IP_ADDR:8090/"
echo "- DockerCoins WebUI: http://$IP_ADDR:8090/webui/"
echo "- Prometheus: http://$IP_ADDR:8090/prometheus/"
echo "- Grafana: http://$IP_ADDR:8090/grafana/ (admin/admin)"
echo "- Kibana: http://$IP_ADDR:8090/kibana/"
echo "- Elasticsearch: http://$IP_ADDR:8090/elasticsearch/"
echo "- InfluxDB: http://$IP_ADDR:8090/influxdb/ (admin/adminpassword)"
