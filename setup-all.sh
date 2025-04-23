#!/bin/bash

# Script để thiết lập toàn bộ hệ thống Docker Swarm với ELK Stack, Prometheus-Grafana-InfluxDB và Nginx

echo "===== THIẾT LẬP HỆ THỐNG DOCKER SWARM ====="

# Cấp quyền thực thi cho tất cả các script
echo "Cấp quyền thực thi cho tất cả các script..."
chmod +x *.sh

# Dọn dẹp Docker nếu cần
echo "Bạn có muốn dọn dẹp Docker trước khi bắt đầu? (y/n)"
read clean_docker
if [[ "$clean_docker" == "y" || "$clean_docker" == "Y" ]]; then
  echo "===== Dọn dẹp Docker ====="
  ./clean-docker.sh
fi

# Thiết lập registry
echo "===== Thiết lập Docker Registry ====="
sudo ./setup-registry.sh
./start-registry.sh

# Thiết lập mạng
echo "===== Thiết lập mạng Docker Swarm ====="
./setup-network.sh

# Cập nhật cấu hình DNS
echo "===== Cập nhật cấu hình DNS ====="
sudo ./update-dns.sh

# Xử lý vấn đề tương thích ARM nếu cần
ARCH=$(uname -m)
if [[ "$ARCH" == "arm64" || "$ARCH" == "aarch64" ]]; then
  echo "===== Xử lý vấn đề tương thích ARM ====="
  sudo ./fix-arm-compatibility.sh
fi

# Build và push các images
echo "===== Build và push các images ====="
./build-push-images.sh

# Nếu gặp lỗi với webui, sửa lỗi
if [ $? -ne 0 ] || [[ "$ARCH" == "arm64" || "$ARCH" == "aarch64" ]]; then
  echo "===== Sửa lỗi webui cho ARM ====="
  ./fix-webui.sh
fi

# Triển khai stack
echo "===== Triển khai Docker Stack ====="
./deploy-stack.sh

# Kiểm tra trạng thái các service
echo "===== Kiểm tra trạng thái các service ====="
sleep 10
docker stack services dockercoins

# Triển khai lại Nginx để đảm bảo hoạt động
echo "===== Triển khai lại Nginx ====="
./redeploy-nginx.sh

# Lấy địa chỉ IP của máy
IP_ADDR=$(hostname -I | awk '{print $1}')

echo "===== THIẾT LẬP HOÀN TẤT ====="
echo "Bạn có thể truy cập các dịch vụ qua các URL sau:"
echo "- Dashboard: http://$IP_ADDR/"
echo "- DockerCoins WebUI: http://$IP_ADDR/webui/"
echo "- Prometheus: http://$IP_ADDR/prometheus/"
echo "- Grafana: http://$IP_ADDR/grafana/ (admin/admin)"
echo "- Kibana: http://$IP_ADDR/kibana/"
echo "- Elasticsearch: http://$IP_ADDR/elasticsearch/"
echo "- InfluxDB: http://$IP_ADDR/influxdb/ (admin/adminpassword)"

echo "Để kiểm tra logs của các service:"
echo "docker service logs dockercoins_webui"
echo "docker service logs dockercoins_logstash"
echo "docker service logs dockercoins_elasticsearch"
echo "docker service logs dockercoins_kibana"
echo "docker service logs dockercoins_prometheus"
echo "docker service logs dockercoins_grafana"
echo "docker service logs dockercoins_influxdb"
echo "docker service logs dockercoins_nginx"
