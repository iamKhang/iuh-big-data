#!/bin/bash

# Hiển thị thông báo
echo "===== TRIỂN KHAI ỨNG DỤNG BIG DATA TRÊN DOCKER SWARM ====="

# Kiểm tra xem đã thiết lập môi trường chưa
if ! docker network inspect hoangkhang-net &>/dev/null; then
    echo "Mạng hoangkhang-net chưa được tạo. Đang chạy script thiết lập môi trường..."
    bash setup-environment.sh
fi

# Kiểm tra xem registry đã chạy chưa
if ! docker ps | grep -q registry; then
    echo "Registry chưa chạy. Đang khởi động registry..."
    docker run -d -p 5000:5000 --restart=always --name registry registry:2
fi

# Sử dụng địa chỉ IP cố định của manager node
MANAGER_IP="192.168.19.10"
echo "Sử dụng địa chỉ IP cố định của manager node: $MANAGER_IP"

# Build và push các image
echo "Đang build và push các image..."

# Build và push image rng
echo "Building rng image..."
docker build -t $MANAGER_IP:5000/rng ./rng
docker push $MANAGER_IP:5000/rng

# Build và push image hasher
echo "Building hasher image..."
docker build -t $MANAGER_IP:5000/hasher ./hasher
docker push $MANAGER_IP:5000/hasher

# Build và push image webui
echo "Building webui image..."
docker build -t $MANAGER_IP:5000/webui ./webui
docker push $MANAGER_IP:5000/webui

# Build và push image worker
echo "Building worker image..."
docker build -t $MANAGER_IP:5000/worker ./worker
docker push $MANAGER_IP:5000/worker

# Đảm bảo file docker-stack.yml sử dụng địa chỉ IP cố định
echo "Kiểm tra file docker-stack.yml để đảm bảo sử dụng địa chỉ IP cố định..."
# Đã sử dụng địa chỉ IP cố định trong file docker-stack.yml

# Triển khai stack
echo "Đang triển khai stack..."
docker stack deploy -c docker-stack.yml dockercoins

# Hiển thị thông báo hoàn thành
echo "===== TRIỂN KHAI HOÀN TẤT ====="
echo "Các dịch vụ đang được khởi động. Vui lòng đợi vài phút để tất cả các dịch vụ khởi động hoàn tất."
echo "Bạn có thể kiểm tra trạng thái của các dịch vụ bằng lệnh: docker service ls"
echo ""
echo "Các dịch vụ có thể truy cập qua địa chỉ IP của node manager ($MANAGER_IP):"
echo "- DockerCoins WebUI: http://$MANAGER_IP/"
echo "- Kibana: http://$MANAGER_IP/kibana/"
echo "- Grafana: http://$MANAGER_IP/grafana/ (username: admin, password: admin)"
echo "- Prometheus: http://$MANAGER_IP/prometheus/"
echo "- Elasticsearch: http://$MANAGER_IP/elasticsearch/"
echo "- InfluxDB: http://$MANAGER_IP/influxdb/"
echo ""
echo "Lưu ý: Một số dịch vụ như cAdvisor đã bị tắt vì không tương thích với kiến trúc ARM."
echo "Nếu gặp vấn đề với các dịch vụ khác, hãy kiểm tra logs bằng lệnh: docker service logs dockercoins_<tên_dịch_vụ>"
