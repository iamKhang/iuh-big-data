#!/bin/bash

# Script để build và push các images lên registry

# Đặt địa chỉ registry là IP của node manager
REGISTRY=192.168.19.10:5000
REGISTRY_IP=192.168.19.10

# Đảm bảo registry đang chạy
if ! docker ps | grep -q registry; then
  echo "Khởi động Docker registry..."
  docker run -d -p 5000:5000 --restart=always --name registry registry:2
else
  echo "Docker registry đã đang chạy."
fi

# Kiểm tra kết nối đến registry
echo "Kiểm tra kết nối đến registry..."
if ! curl -s http://$REGISTRY_IP:5000/v2/ > /dev/null; then
  echo "Cảnh báo: Không thể kết nối đến registry. Hãy chạy 'sudo ./setup-registry.sh' trên tất cả các node."
  echo "Tiếp tục build nhưng có thể sẽ gặp lỗi khi push..."
fi

# Build và push các images
echo "Building và pushing images lên $REGISTRY..."

# Build và push rng
echo "Building và pushing rng..."
docker build -t $REGISTRY/dockercoins_rng:latest ./rng
docker push $REGISTRY/dockercoins_rng:latest || echo "Lỗi khi push rng image. Hãy kiểm tra kết nối đến registry."

# Build và push hasher
echo "Building và pushing hasher..."
docker build -t $REGISTRY/dockercoins_hasher:latest ./hasher
docker push $REGISTRY/dockercoins_hasher:latest || echo "Lỗi khi push hasher image. Hãy kiểm tra kết nối đến registry."

# Build và push webui
echo "Building và pushing webui..."
docker build -t $REGISTRY/dockercoins_webui:latest ./webui
docker push $REGISTRY/dockercoins_webui:latest || echo "Lỗi khi push webui image. Hãy kiểm tra kết nối đến registry."

# Build và push worker
echo "Building và pushing worker..."
docker build -t $REGISTRY/dockercoins_worker:latest ./worker
docker push $REGISTRY/dockercoins_worker:latest || echo "Lỗi khi push worker image. Hãy kiểm tra kết nối đến registry."

echo "Tất cả images đã được build và push lên $REGISTRY"
echo "Bạn có thể triển khai stack bằng lệnh: ./deploy-stack.sh"
