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

# Build và push các image
echo "Đang build và push các image..."

# Build và push image rng
echo "Building rng image..."
docker build -t 127.0.0.1:5000/rng ./rng
docker push 127.0.0.1:5000/rng

# Build và push image hasher
echo "Building hasher image..."
docker build -t 127.0.0.1:5000/hasher ./hasher
docker push 127.0.0.1:5000/hasher

# Build và push image webui
echo "Building webui image..."
docker build -t 127.0.0.1:5000/webui ./webui
docker push 127.0.0.1:5000/webui

# Build và push image worker
echo "Building worker image..."
docker build -t 127.0.0.1:5000/worker ./worker
docker push 127.0.0.1:5000/worker

# Triển khai stack
echo "Đang triển khai stack..."
docker stack deploy -c docker-stack.yml dockercoins

# Hiển thị thông báo hoàn thành
echo "===== TRIỂN KHAI HOÀN TẤT ====="
echo "Các dịch vụ đang được khởi động. Vui lòng đợi vài phút để tất cả các dịch vụ khởi động hoàn tất."
echo "Bạn có thể kiểm tra trạng thái của các dịch vụ bằng lệnh: docker service ls"
echo ""
echo "Các dịch vụ có thể truy cập qua địa chỉ IP của node manager (192.168.19.10):"
echo "- DockerCoins WebUI: http://192.168.19.10/"
echo "- Kibana: http://192.168.19.10/kibana/"
echo "- Grafana: http://192.168.19.10/grafana/ (username: admin, password: admin)"
echo "- Prometheus: http://192.168.19.10/prometheus/"
echo "- Elasticsearch: http://192.168.19.10/elasticsearch/"
echo "- InfluxDB: http://192.168.19.10/influxdb/"
