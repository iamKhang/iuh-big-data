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

# Đợi 30 giây để các dịch vụ khởi động
echo "Chờ các dịch vụ khởi động (30 giây)..."
sleep 30

# Kiểm tra trạng thái các service
echo "===== Kiểm tra trạng thái các service ====="
docker stack services dockercoins

# Triển khai lại stack để đảm bảo tất cả các dịch vụ được tạo
echo "Triển khai lại stack để đảm bảo tất cả các dịch vụ được tạo..."
docker stack deploy -c docker-stack.yml dockercoins

# Đợi thêm 60 giây để các dịch vụ khởi động hoàn toàn
echo "Chờ thêm 60 giây để các dịch vụ khởi động hoàn toàn..."
sleep 60

# Kiểm tra lại trạng thái các service
echo "===== Kiểm tra lại trạng thái các service ====="
docker stack services dockercoins

# Triển khai lại Nginx để đảm bảo hoạt động
echo "===== Triển khai lại Nginx ====="
./redeploy-nginx.sh

# Đợi thêm 30 giây để Nginx khởi động
echo "Chờ thêm 30 giây để Nginx khởi động..."
sleep 30

# Đảm bảo tất cả các dịch vụ đang chạy
echo "===== Đảm bảo tất cả các dịch vụ đang chạy ====="
./ensure-services.sh

# Lấy địa chỉ IP của máy
IP_ADDR=$(hostname -I | awk '{print $1}')

echo "===== THIẾT LẬP HOÀN TẤT ====="
echo "Bạn có thể truy cập các dịch vụ qua các URL sau:"
echo "- Dashboard: http://$IP_ADDR:8090/"
echo "- DockerCoins WebUI: http://$IP_ADDR:8090/webui/"
echo "- Prometheus: http://$IP_ADDR:8090/prometheus/"
echo "- Grafana: http://$IP_ADDR:8090/grafana/ (admin/admin)"
echo "- Kibana: http://$IP_ADDR:8090/kibana/"
echo "- Elasticsearch: http://$IP_ADDR:8090/elasticsearch/"
echo "- InfluxDB: http://$IP_ADDR:8090/influxdb/ (admin/adminpassword)"

echo "Để kiểm tra logs của các service:"
echo "docker service logs dockercoins_webui"
echo "docker service logs dockercoins_logstash"
echo "docker service logs dockercoins_elasticsearch"
echo "docker service logs dockercoins_kibana"
echo "docker service logs dockercoins_prometheus"
echo "docker service logs dockercoins_grafana"
echo "docker service logs dockercoins_influxdb"
echo "docker service logs dockercoins_nginx"
