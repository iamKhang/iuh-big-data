#!/bin/bash

# Script để sửa lỗi build webui image

echo "===== Sửa lỗi build webui image ====="

# Dừng và xóa container registry nếu đang chạy
echo "Dừng và khởi động lại registry..."
docker rm -f registry 2>/dev/null || true
docker run -d -p 5000:5000 --restart=always --name registry registry:2

# Xóa image webui cũ nếu có
echo "Xóa image webui cũ nếu có..."
docker rmi 192.168.19.10:5000/dockercoins_webui:latest 2>/dev/null || true

# Xóa các container npm cache
echo "Xóa các container npm cache..."
docker ps -a | grep npm | awk '{print $1}' | xargs docker rm -f 2>/dev/null || true

# Xóa các volume không sử dụng
echo "Xóa các volume không sử dụng..."
docker volume prune -f

# Build lại image webui
echo "Build lại image webui..."
docker build -t 192.168.19.10:5000/dockercoins_webui:latest ./webui

# Push image lên registry
echo "Push image lên registry..."
docker push 192.168.19.10:5000/dockercoins_webui:latest

echo "===== Hoàn tất! ====="
echo "Nếu thành công, bạn có thể triển khai stack với: ./deploy-stack.sh"
echo "Hoặc cập nhật service webui với: docker service update --force dockercoins_webui"
